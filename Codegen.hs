module Codegen where
import LLVMM
import qualified AST as H

import Control.Monad.State

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

exprCodegen (H.Call func args) = do
  func' <- exprCodegen func
  args' <- mapM exprCodegen args
  call func' args'

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
            if lt == rt then
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
            error "Can't compare different types"
        else
          error "What?"

declareGlobals :: [(String,H.Type)] -> LLVMM ()
declareGlobals decls = mapM_ defineGlobal [(name,ConstantOperand (C.GlobalReference (htoll ty) (strtoname name))) | (name,ty) <- decls]

declCodegen :: H.Declaration -> LLVMM ()
declCodegen (H.FuncDef name args retu expr) = do
    let glb = genFunction (htoll retu) (strtoname name) [(htoll ty,strtoname name) | (name,ty) <- args]
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
    (H.Func tys ty) -> genFunction (htoll ty) (strtoname name)
      (zipWith (,) (map htoll tys) (map (\x -> strtoname $ replicate x 'a') [1..]))
    ty -> genExternVar (strtoname name) (htoll ty)
