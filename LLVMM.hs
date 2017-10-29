module LLVMM where

import qualified AST as H
import Util

import LLVM.AST
import LLVM.AST.Global
import LLVM.AST.Instruction
import LLVM.AST.Operand

import qualified LLVM.AST.IntegerPredicate as I
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.Linkage as L
import qualified LLVM.AST.Type as T
import qualified LLVM.AST.Float as F
import qualified LLVM.AST.FloatingPointPredicate as FP

import Control.Monad.State

import Data.Word
import qualified Data.ByteString.Short as SBS
import qualified Data.ByteString.Char8 as BS

--datatypes
data CompilerState =
  CompilerState {
    workingMod :: Module,
    nameCounter :: Int
  }

data FnState =
  FnState {
    currentBlock :: Name,
    blocks :: [(Name,BlockState)],
    scope :: [[(String,Operand)]],
    ctr :: Int
  }

data BlockState =
  BlockState {
    instructions :: [Named Instruction],
    terminator :: Named Terminator
  }

type Codegen a = State FnState a
type LLVMM a = State CompilerState a

--conversion util
tosbs = SBS.toShort . BS.pack
strtoname = Name . tosbs

--llvm types
llint = T.IntegerType (fromIntegral 32)
llbool = T.IntegerType (fromIntegral 1)
llfloat = T.FloatingPointType T.FloatFP
constint = ConstantOperand . C.Int (fromIntegral 32)
constb b = ConstantOperand . C.Int (fromIntegral 1) $ if b then 1 else 0
constf = ConstantOperand . C.Float . F.Single

--monad utils
genCompilerState modName sourceName =
  CompilerState
    (defaultModule {moduleName = tosbs modName, moduleSourceFileName = tosbs sourceName})
    0

defaultBlockState = BlockState [] (error "Missing terminator")

defaultFnState ct = FnState (error "Missing name") [] [[]] ct

modifyKey :: (Eq k) => k -> (v -> v) -> [(k,v)] -> [(k,v)]
modifyKey k f [] = error "key doesn't exist"
modifyKey k f ((k',v):kvs) = if k == k' then (k,f v):kvs else (k',v):(modifyKey k f kvs)

--general internal helpers
addGlobal :: Definition -> LLVMM ()
addGlobal d = do
  wmod <- gets workingMod
  modify $ \st -> st {workingMod = wmod {moduleDefinitions = moduleDefinitions wmod ++ [d]} }

genFunction :: Type -> Name -> [(Type,Name)] -> Global
genFunction returnt nm params =
  functionDefaults {
    returnType = returnt,
    name = nm,
    parameters = (params',False)}
  where
    params' = map (\(t,n) -> Parameter t n []) params

llmain :: Global
llmain = genFunction llint (mkName "main") []

runCodegen :: Global -> Codegen () -> LLVMM ()
runCodegen def cdg = do
  ct <- gets nameCounter
  let st = execState cdg $ defaultFnState ct
      blks = map (\(n,BlockState inss term) -> BasicBlock n inss term) (blocks st)
      def' = def {basicBlocks = blks}
  modify $ \st' -> st' {nameCounter = ctr st}
  addGlobal $ GlobalDefinition def'

fresh :: Codegen Name
fresh = do
  count <- gets ctr
  modify $ \st -> st {ctr = count + 1}
  return $ UnName (fromIntegral $ count + 1)

newBlock :: Codegen Name
newBlock = do
  name <- fresh
  modify $ \st -> st {blocks = blocks st ++ [(name,defaultBlockState)]}
  return name

useBlock :: Name -> Codegen ()
useBlock n = do
  modify $ \st -> st {currentBlock = n}

modifyCurrentBlock :: (BlockState -> BlockState) -> Codegen ()
modifyCurrentBlock f = do
  blk <- gets currentBlock
  modify $ \st -> st {blocks = modifyKey blk f (blocks st)}

pushScope :: [(String,Operand)] -> Codegen ()
pushScope ex = modify $ \st -> st {scope = ex:scope st}

popScope :: Codegen ()
popScope = modify $ \st -> st { scope = tail $ scope st}

find :: String -> Codegen Operand
find s = do
    st <- get
    return $ resolve (scope st) s

--adding instructions
addIns :: Named Instruction -> Codegen ()
addIns i = modifyCurrentBlock (\bst -> bst {instructions = instructions bst ++ [i]})

addTerm :: Terminator -> Codegen ()
addTerm t = modifyCurrentBlock (\bst -> bst {terminator = Do t})

local = LocalReference (error "WHAT?")

ins :: Instruction -> Codegen Operand
ins instr = do
  nm <- fresh
  addIns $ nm := instr
  return $ local nm

mkiBinary bin l r = ins $ bin False False l r []

iadd = mkiBinary Add
imul = mkiBinary Mul
isub = mkiBinary Sub

icmp predi l r = ins $ ICmp predi l r []
fcmp predi l r = ins $ FCmp predi l r []

mkfBinary bin l r = ins $ bin NoFastMathFlags l r []

fadd = mkfBinary FAdd
fsub = mkfBinary FSub
fmul = mkfBinary FMul
fdiv = mkfBinary FDiv

floattoint x = ins $ FPToSI x llint []
inttofloat x = ins $ SIToFP x llfloat []
booltoint x = ins $ ZExt x llint []

phi tp branches = ins $ Phi tp branches []

br lbl = addTerm $ Br lbl []
cbr b t f = addTerm $ CondBr b t f []
ret val = addTerm $ Ret (Just val) []

--actual codegen
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

exprCodegen (H.Binary op l r) = do
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
                  H.Less -> I.SLT) l' r'
              else
                fcmp (case op of
                  H.Equal -> FP.OEQ
                  H.Inequal -> FP.ONE
                  H.Greater -> FP.OGT
                  H.Less -> FP.OLT) l' r'
          else
            error "Can't compare different types"
        else
          error "What?"

declCodegen :: H.Declaration -> LLVMM ()
declCodegen (H.FuncDef name args expr) = do
    let glb = genFunction (htoll $ H.typeOf expr) (strtoname name) [(htoll ty,strtoname name) | (name,ty) <- args]
    runCodegen glb (
      do
        pushScope $ [(name,local $ strtoname name) | (name,ty) <- args]
        new <- newBlock
        useBlock new
        result <- exprCodegen expr
        ret result)


--typey operations

--     from       to      input      casted output
cast :: H.Type -> H.Type -> Operand -> Codegen Operand
cast H.HFloat H.HInt op = floattoint op
cast H.HInt H.HFloat op = inttofloat op
cast H.HBool H.HInt op = booltoint op
cast x y o = if x == y then return o else error "Not Implemented"

htoll :: H.Type -> Type
htoll H.HBool = llbool
htoll H.HInt = llint
htol H.HFloat = llfloat
