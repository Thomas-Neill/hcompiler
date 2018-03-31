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
exprCodegen (H.ILit i) = pointerize (pointerto i32) (constint i)
exprCodegen (H.FLit f) = pointerize (pointerto float) (constf f)
exprCodegen (H.BLit b) = pointerize (pointerto i1) (constb b)
exprCodegen (H.CLit c) = pointerize (pointerto i8) (constc c)
exprCodegen (H.VLit) = return $ ConstantOperand $ C.Null (pointerto i8)
exprCodegen (H.Var _ v) = find v
exprCodegen whole@(H.If c t e) = do
  let rt = H.typeOf whole --resulting type

  then' <- newBlock
  else' <- newBlock
  done <- newBlock

  c' <- exprCodegen c >>= load
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
  struct <- alloc (pointerReferent $ htoll $ H.typeOf whole)
  flip mapM_ (zip props [0..]) $ \((_,ex),n) -> do
    ex' <- exprCodegen ex
    ptr <- gep' (pointerto $ htoll $ H.typeOf ex) struct [0,n]
    store ptr ex'
    alloc_depends struct ex'
  return struct

exprCodegen w@(H.Access struct prop) = do
  let (H.Structure props) = H.deAlias $ H.typeOf struct
  struct' <- exprCodegen struct
  ptr <- gep' (pointerto $ htoll $ H.typeOf w) struct' [0,fromJust $ prop `L.elemIndex` (map fst props)]
  load ptr

exprCodegen whole@(H.Call func args) = do
  let (H.Func arglist _) = H.deAlias $ H.typeOf func
      twhole = H.typeOf whole
  func' <- exprCodegen func
  args' <- mapM (exprCodegen >=> flip bitcast (pointerto i8)) args
  if length args /= length arglist then do
      struct <- alloc (pointerReferent $ funcType)
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
      curries <- alloc' voidptr ncurry''
      curriesloc <- gep' (pointerto $ pointerto voidptr) struct [0,2]
      store curriesloc curries
      alloc_depends struct curries
      --get curry pointer
      oldCurries <- gep' (pointerto $ pointerto voidptr) func' [0,2] >>= load
      dests <- mapM (const newBlock) [0..15]
      done <- newBlock
      switch ncurry (zip (map (C.Int 8) [0..15]) dests) --based on value of ncurry, we load n old args before starting new ones
      flip mapM_ (zip dests [0..15]) $ \(dest,ncurry) -> do
        useBlock dest
        flip mapM_ [0..ncurry-1] $ \ind -> do
          val <- gep' (pointerto voidptr) oldCurries [ind] >>= load
          loc <- gep' (pointerto voidptr) curries [ind]
          store loc val
          alloc_depends struct val
          --copy old curries to new location
        flip mapM_ [0..length args - 1] $ \ind -> do
          loc <- gep' (pointerto voidptr) curries [ind + ncurry]
          store loc (args' !! ind)
          alloc_depends struct (args' !! ind)
          --copy new curries
        br done
      useBlock done
      return struct
    else do
      targets <- mapM (const newBlock) [0..15]
      done <- newBlock
      ncurry <- gep' (pointerto i8) func' [0,1] >>= load
      switch ncurry (zip (map (C.Int 8) [0..15]) targets)
      vals <- flip mapM (zip targets [0..15]) $ \(target,ncurry) -> do
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

exprCodegen whole@(H.Binary op l r) = do
  l' <- exprCodegen l >>= load
  r' <- exprCodegen r >>= load
  let lt = H.typeOf l
  val <- if H.isMath op then
    if lt == H.HInt then
      case op of
        H.Add -> iadd l' r'
        H.Sub -> isub l' r'
        H.Mul -> imul l' r'
        H.Div -> idiv l' r'
    else
      case op of
        H.Add -> fadd l' r'
        H.Sub -> fsub l' r'
        H.Mul -> fmul l' r'
        H.Div -> fdiv l' r'
  else
    if H.isComp op then
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
      if lt == H.HBool then
        if op == H.And then
          logicand l' r'
        else
          logicor l' r'
      else
        if op == H.And then
          bitand l' r'
        else
          bitor l' r'
  pointerize (htoll $ H.typeOf whole) val

exprCodegen whole@(H.Cast ty expr) = do
  if ty == H.typeOf expr then
    exprCodegen expr
  else do
    val <- case H.deAlias $ H.typeOf expr of
      H.HBool -> case ty of
          H.HInt -> exprCodegen expr >>= load >>= booltoint
      H.HInt -> case ty of
        H.HFloat -> exprCodegen expr >>= load >>= inttofloat
        H.HBool -> exprCodegen (H.Binary H.Equal expr (H.ILit 0))
        H.HChar -> exprCodegen expr >>= load >>= inttochar
      H.HFloat -> case ty of
        H.HInt -> exprCodegen expr >>= load >>= floattoint
      H.HChar -> case ty of
        H.HInt -> exprCodegen expr >>= load >>= chartoint
    pointerize (htoll $ H.typeOf whole) val

exprCodegen (H.Unionize ty cs expr) = do
  let
    (H.Union css) = H.deAlias ty
    index = fromJust $ cs `L.elemIndex` (map fst css)
  struct <- alloc (pointerReferent $ htoll ty)
  indexLoc <- gep' (pointerto i32) struct [0,0]
  store indexLoc (constint index)
  valLoc <- gep' (pointerto voidptr) struct [0,1]
  ex' <- exprCodegen expr
  bitcast ex' voidptr >>= store valLoc
  alloc_depends struct ex'
  return struct

exprCodegen whole@(H.Case ty' ex cases) = do
  let (H.Union types) = H.deAlias ty'
  done <- newBlock
  caseBlocks <- mapM (const newBlock) cases
  ex' <- exprCodegen ex
  ty <- gep' (pointerto i32) ex' [0,0] >>= load
  switch ty (zip (map (C.Int 32) [0..]) caseBlocks)
  let
    lk3 :: [(String,String,H.Expr)] -> String -> (String,String,H.Expr)
    lk3 [] _ = error "???"
    lk3 ((nm,cs,typ):xs) needle = if needle == cs then (nm,cs,typ) else lk3 xs needle
    cases' = map (lk3 cases . fst) types
  phis <- flip mapM (zip caseBlocks cases') $ \(blk,(nm,cs,ex)) -> do
    let ty = fromJust $ lookup cs types
    useBlock blk
    val <- gep' (pointerto voidptr) ex' [0,1] >>= load >>= flip bitcast (htoll ty)
    pushScope [(nm,return val)]
    ex' <- exprCodegen ex
    popScope
    br done
    blk' <- gets currentBlock
    return (ex',blk')
  useBlock done
  phi (htoll $ H.typeOf whole) phis

exprCodegen (H.Do (ex:exs)) = do
  result <- exprCodegen ex
  if exs == [] then
    return result
  else
    exprCodegen (H.Do exs)

declareGlobals :: [(String,H.Type)] -> LLVMM ()
declareGlobals decls = do
  mapM_ defineGlobal
    [(name,ConstantOperand (C.GlobalReference (funcPtrType ty) (strtoname $ "hask__" ++ name)))
      | (name,ty) <- decls]
  requiredDefns

declCodegen :: H.Declaration -> LLVMM ()
declCodegen (H.FuncDef name args retu expr) = do
    let glb = genFunction (htoll $ H.typeOf expr) (strtoname $ "hask__" ++ name) [(htoll ty,strtoname name) | (name,ty) <- args]
    globs <- gets globals
    let globs' = map (\(name,operand) -> (,) name $ do
        struct <- alloc (pointerReferent $ funcType)
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
        alloc_push
        let
          names = map (\(name,ty) -> (name,return $ local (htoll ty) $ strtoname name)) args
        pushScope $ globs' ++ names
        result <- exprCodegen expr
        alloc_pop_except result
        ret result)
declCodegen (H.Extern name ty') = do
   case H.deAlias $ ty' of
    (H.Func args retrn) -> do
      let glb1 = genFunction (htoll retrn) (strtoname $ "hask__" ++ name) (zipWith (,) (map htoll args) (map (\x -> strtoname $ replicate x 'a') [1..]))
          glb2 = genFunction (htoc retrn) (strtoname $ name) (zipWith (,) (map htoc args) (map (\x -> strtoname $ replicate x 'a') [1..]))
      addGlobal $ GlobalDefinition glb2
      runCodegen glb1 $ do
          newBlock >>= useBlock
          alloc_push
          newargs <- flip mapM (zip args [0..]) $ \(ty,n) -> do
            let name = local (htoll ty) $ strtoname (replicate (n+1) 'a')
            llvaltoc ty name
          let fn = ConstantOperand (C.GlobalReference (cfuncPtrType ty') (strtoname name))
          ret'' <- call fn newargs
          ret' <- cvaltoll retrn ret''
          alloc_pop_except ret'
          ret ret'
    ty -> addGlobal $ GlobalDefinition $ genExternVar (strtoname name) (htoll ty)
