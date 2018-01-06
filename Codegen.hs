module Codegen where
import LLVMM
import qualified AST as H

import Control.Monad.State
import Debug.Trace
import qualified Data.List as L
import Data.Maybe

import LLVM.AST
import LLVM.AST.Type
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
    return (name,return o)) es
  pushScope os
  e' <- exprCodegen e
  popScope
  return e'

exprCodegen whole@(H.StructLiteral props) = do
  struct <- malloc (pointerReferent $ htoll $ H.typeOf whole)
  flip mapM_ (zip props [0..]) $ \((_,ex),n) -> do
    ex' <- exprCodegen ex
    ptr <- gep' (pointerto $ htoll $ H.typeOf ex) struct [0,n]
    store ptr ex'
  return struct

exprCodegen w@(H.Access struct prop) = do
  let (H.Structure props) = H.typeOf struct
  struct' <- exprCodegen struct
  ptr <- gep' (pointerto $ htoll $ H.typeOf w) struct' [0,fromJust $ prop `L.elemIndex` (map fst props)]
  load ptr

exprCodegen whole@(H.Call func args) = do
  let (H.Func arglist _) = H.typeOf func
      twhole = H.typeOf whole
  func' <- exprCodegen func
  args' <- flip mapM args $ \arg -> do
    arg' <- exprCodegen arg
    storage <- malloc (htoll $ H.typeOf arg)
    store storage arg'
    bitcast storage voidptr
  if length args /= length arglist then do
      struct <- malloc (pointerReferent $ funcType)
      funcptrloc <- gep' (pointerto voidptr) struct [0,0]
      funcptr <- gep' (pointerto voidptr) func' [0,0] >>= load
      --copy function pointer
      store funcptrloc funcptr
      ncurry <- gep' (pointerto i8) func' [0,1] >>= load
      ncurry' <- addi8 ncurry (ConstantOperand $ C.Int 8 $ fromIntegral $ length args)
      ncurryloc <- gep' (pointerto i8) struct [0,1]
      store ncurryloc ncurry'
      ncurry'' <- toi32 ncurry'
      --calc new curried args and store
      curries <- malloc' voidptr ncurry''
      curriesloc <- gep' (pointerto $ pointerto voidptr) struct [0,2]
      store curriesloc curries
      --get curry pointer
      oldCurries <- gep' (pointerto $ pointerto voidptr) func' [0,2] >>= load
      dests <- mapM (const newBlock) [0..1]
      done <- newBlock
      switch ncurry (zip (map (C.Int 8) [0..1]) dests) --based on value of ncurry, we load n old args before starting new ones
      flip mapM_ (zip dests [0..15]) $ \(dest,ncurry) -> do
        useBlock dest
        flip mapM_ [0..ncurry-1] $ \ind -> do
          val <- gep' (pointerto voidptr) oldCurries [ind] >>= load
          loc <- gep' (pointerto voidptr) curries [ind]
          store loc val
          --copy old curries to new location
        flip mapM_ [0..length args - 1] $ \ind -> do
          loc <- gep' (pointerto voidptr) curries [ind + ncurry]
          store loc (args' !! ind)
          --copy new curries
          br done
      useBlock done
      return struct
    else do
      targets <- mapM (const newBlock) [0..1]
      done <- newBlock
      ncurry <- gep' (pointerto i8) func' [0,1] >>= load
      switch ncurry (zip (map (C.Int 8) [0..1]) targets)
      vals <- flip mapM (zip targets [0..1]) $ \(target,ncurry) -> do
        useBlock target
        funcptr <- gep' (pointerto voidptr) func' [0,0] >>= load
        funcptr' <- bitcast funcptr (funcNargs (htoll twhole) (ncurry + length args))
        curryLoc <- gep' (pointerto $ pointerto voidptr) func' [0,2] >>= load
        curries <- flip mapM [0..ncurry-1] $ \ind ->
          gep' (pointerto voidptr) curryLoc [ind] >>= load
        result <- call funcptr' (curries ++ args')
        br done
        return result
      useBlock done
      phi (htoll twhole) (zip vals targets)



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
    [(name,ConstantOperand (C.GlobalReference (funcPtrType ty) (strtoname name)))
      | (name,ty) <- decls]
  requiredDefns

declCodegen :: H.Declaration -> LLVMM ()
declCodegen (H.FuncDef name args retu expr) = do
    let glb = genFunction (htoll $ H.typeOf expr) (strtoname name) [(voidptr,strtoname name) | (name,ty) <- args]
    globs <- gets globals
    let globs' = map (\(name,operand) -> (,) name $ do
        struct <- malloc (pointerReferent $ funcType)
        op' <- bitcast operand voidptr
        fntarget <- gep' (pointerto voidptr) struct [0,0]
        store fntarget op'
        ntarget <- gep' (pointerto i8) struct [0,1]
        store ntarget (ConstantOperand $ C.Int 8 0)
        atarget <- gep' (pointerto $ pointerto voidptr) struct [0,2]
        store atarget (ConstantOperand $ C.Null $ pointerto voidptr)
        return struct
          ) globs
    runCodegen glb (
      do
        new <- newBlock
        useBlock new
        names <- flip mapM args $ \(name,ty) -> do
          ptr' <- bitcast (local voidptr $ strtoname name) (pointerto $ htoll ty)
          val <- load ptr'
          return (name,return val)
        pushScope $ globs' ++ names
        result <- exprCodegen expr
        ret result)
declCodegen (H.Extern name ty') = do
  addGlobal $ GlobalDefinition  $ case ty' of
    (H.Func args retrn) -> genFunction (htoll retrn) (strtoname name)
      (zipWith (,) (map htoll args) (map (\x -> strtoname $ replicate x 'a') [1..]))
    ty -> genExternVar (strtoname name) (htoll ty)
