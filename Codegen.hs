module Codegen where
import LLVMM
import qualified AST as H

import Control.Monad.State
import Debug.Trace

import LLVM.AST
import qualified LLVM.AST.IntegerPredicate as I
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.FloatingPointPredicate as FP --TODO: refactor all llvm imports into llvmm

exprCodegen :: H.Expr -> Codegen Operand
exprCodegen (H.ILit i) = return $ constint i
exprCodegen (H.FLit f) = return $ constf f
exprCodegen (H.BLit b) = return $ constb b
exprCodegen (H.TypedVar _ v) = find v
exprCodegen whole@(H.If c t e) = do
  let rt = H.typeOf whole --resulting type

  then' <- newBlock
  else' <- newBlock
  done <- newBlock

  c' <- exprCodegen c
  cbr c' then' else'

  useBlock then'
  t' <- exprCodegen t
  thenblk <- gets currentBlock
  br done

  useBlock else'
  e' <- exprCodegen e
  elseblk <- gets currentBlock
  br done

  useBlock done
  phi (htoll rt) [(t',thenblk),(e',elseblk)]

exprCodegen (H.Let es e) = do
  os <- mapM (\(name,expr) -> do
    o <- exprCodegen expr
    return (name,o)) es
  pushScope os
  e' <- exprCodegen e
  popScope
  return e'

exprCodegen whole@(H.Call func args) = do
  func' <- exprCodegen func
  args' <- mapM exprCodegen args
  case H.typeOf func of
    (H.Func args1 retu) ->
      if length args == length args1 then
        call func' args'
      else do
        let twhole = H.typeOf whole
        struct <- malloc (deref $ htoll twhole)
        fptr <- gep' struct [0,0]
        store fptr func'
        flip mapM (zip args' [1..]) $ \(val,n) -> do
          ptr <- gep' struct [0,n]
          store ptr val
        return struct
    (H.Curry args1 retu applied) -> do
      if length args1 - applied == length args then do
        args1' <- flip mapM (take applied [1..]) $ \n -> do
          it <- gep' func' [0,n]
          load it
        func'' <- gep' func' [0,0]
        func''' <- load func''
        free func'
        call func''' (args1' ++ args')
      else do
        let twhole = H.typeOf whole
        struct <- malloc (deref $ htoll twhole)
        func'' <- gep' func' [0,0]
        func''' <- load func''
        fptr <- gep' struct [0,0]
        store fptr func'''
        flip mapM (take applied [1..]) $ \n -> do
          val <- gep' func' [0,n]
          val' <- load val
          vptr <- gep' struct [0,n]
          store vptr val'
        flip mapM (zip args' [applied+1..]) $ \(val,n) -> do
          vptr <- gep' struct [0,fromIntegral n]
          store vptr val
        free func'
        return struct


exprCodegen (H.Binary op l r) = do --jesus this is bad
  l' <- exprCodegen l
  r' <- exprCodegen r
  if op == H.Div then do
    l'' <- cast (H.typeOf l) H.HFloat l'
    r'' <- cast (H.typeOf r) H.HFloat r'
    fdiv l'' r''
  else let
    lt = H.typeOf l
    rt = H.typeOf r
    in if H.isMath op then do
        let castType = lt `H.binResult` rt
        l'' <- cast lt castType l'
        r'' <- cast rt castType r'
        if castType == H.HInt then
          case op of
            H.Add -> iadd l'' r''
            H.Sub -> isub l'' r''
            H.Mul -> imul l'' r''
        else
          case op of
            H.Add -> fadd l'' r''
            H.Sub -> fsub l'' r''
            H.Mul -> fmul l'' r''
      else if H.isComp op then
        if lt == H.HInt || lt == H.HBool then
          icmp (case op of
            H.Equal -> I.EQ
            H.Inequal -> I.NE
            H.Greater -> I.SGT
            H.Less -> I.SLT
            H.GrEqual -> I.SGE
            H.LEqual -> I.SLE) l' r'
        else
          fcmp (case op of
            H.Equal -> FP.OEQ
            H.Inequal -> FP.ONE
            H.Greater -> FP.OGT
            H.Less -> FP.OLT
            H.GrEqual -> FP.OGE
            H.LEqual -> FP.OLE) l' r'
        else
          error "What?"

declareGlobals :: [(String,H.Type)] -> LLVMM ()
declareGlobals decls = do
  mapM_ defineGlobal
    [(name,ConstantOperand (C.GlobalReference (htoll ty) (strtoname name)))
      | (name,ty) <- decls]
  requiredDefns

declCodegen :: H.Declaration -> LLVMM ()
declCodegen (H.FuncDef name args retu expr) = do
    let glb = genFunction (htoll $ H.typeOf expr) (strtoname name) [(htoll ty,strtoname name) | (name,ty) <- args]
    globs <- gets globals
    runCodegen glb (
      do
        pushScope $ globs ++ [(name,local $ strtoname name) | (name,ty) <- args]
        new <- newBlock
        useBlock new
        result <- exprCodegen expr
        ret result)
declCodegen (H.Extern name ty') = do
  addGlobal $ GlobalDefinition  $ case ty' of
    (H.Func args retrn) -> genFunction (htoll retrn) (strtoname name)
      (zipWith (,) (map htoll args) (map (\x -> strtoname $ replicate x 'a') [1..]))
    ty -> genExternVar (strtoname name) (htoll ty)
