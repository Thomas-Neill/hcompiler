module LLVMM where

import qualified AST as H
import Util

import LLVM.AST
import LLVM.AST.Global as G
import LLVM.AST.Instruction
import LLVM.AST.Operand

import qualified LLVM.AST.CallingConvention as CC
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.Linkage as L
import qualified LLVM.AST.Type as T
import LLVM.AST.Type (i32,i1,float,i8)
import qualified LLVM.AST.Float as F
import qualified LLVM.AST.AddrSpace as AS

import Control.Monad.State

import Data.Word
import qualified Data.ByteString.Short as SBS
import qualified Data.ByteString.Char8 as BS

--datatypes
data CompilerState =
  CompilerState {
    workingMod :: Module,
    nameCounter :: Int,
    globals :: [(String,Operand)]
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
constint = ConstantOperand . C.Int (fromIntegral 32)
constb b = ConstantOperand . C.Int (fromIntegral 1) $ if b then 1 else 0
constf = ConstantOperand . C.Float . F.Single

--monad utils
genCompilerState modName sourceName =
  CompilerState
    (defaultModule {moduleName = tosbs modName, moduleSourceFileName = tosbs sourceName})
    0
    []

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

defineGlobal :: (String,Operand) -> LLVMM ()
defineGlobal what = modify $ \st -> st {globals = what:globals st}

genFunction :: Type -> Name -> [(Type,Name)] -> Global
genFunction returnt nm params =
  functionDefaults {
    returnType = returnt,
    name = nm,
    parameters = (params',False)}
  where
    params' = map (\(t,n) -> Parameter t n []) params

genExternVar :: Name -> Type -> Global
genExternVar nm ty = globalVariableDefaults
          {
            linkage = L.External,
            name = nm,
            G.type' = ty
          }

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

local = LocalReference $
  error "If you are reading this, the horrible hack you used to avoid typing the local references gave out."

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

gep add indices = ins $ GetElementPtr False add indices []

gep' add indices = gep add (map constint indices)

malloc ty = do
  sz <- gep' (ConstantOperand $ C.Null $ pointerto ty) [1]
  size <- ins $ PtrToInt sz i32 []
  ptr <- call (ConstantOperand $ C.GlobalReference mallocType (strtoname "malloc")) [size]
  ins $ BitCast ptr (pointerto ty) []
  where
    mallocType = FunctionType (pointerto i8) [pointerto i8] False

free ptr = do
  ptr' <- ins $ BitCast ptr (pointerto i8) []
  call (ConstantOperand $ C.GlobalReference freeType $ strtoname "free") [ptr']
  where
    freeType = FunctionType VoidType [pointerto i8] False
load add = ins $ Load False add Nothing 0 []
store add val = ins $ Store False add val Nothing 0 []

floattoint x = ins $ FPToSI x i32 []
inttofloat x = ins $ SIToFP x float []
booltoint x = ins $ ZExt x i32 []
call f args = ins $
  Call Nothing CC.C [] (Right f) [(x,[]) | x <- args] [] []

phi tp branches = ins $ Phi tp branches []

br lbl = addTerm $ Br lbl []
cbr b t f = addTerm $ CondBr b t f []
ret val = addTerm $ Ret (Just val) []

cast :: H.Type -> H.Type -> Operand -> Codegen Operand
cast H.HFloat H.HInt op = floattoint op
cast H.HInt H.HFloat op = inttofloat op
cast H.HBool H.HInt op = booltoint op
cast x y o = if x == y then return o else error "Not Implemented"

htoll :: H.Type -> Type
htoll H.HBool = i1
htoll H.HInt = i32
htoll H.HFloat = float
htoll (H.Func args rett) = FunctionType (htoll rett) (map htoll args) False
htoll (H.Curry args rett applied) =
  pointerto $
    StructureType False $ (pointerto . htoll $ H.Func args rett):(map htoll $ take applied args)

deref (PointerType ty _) = ty
pointerto ty = PointerType ty (AS.AddrSpace 0)

requiredDefns = do
  let
    mallocGlobal = (genFunction (pointerto i8) (strtoname "malloc") [(i32,strtoname "size")])
    freeGlobal = (genFunction VoidType (strtoname "free") [(pointerto i8,strtoname "target")])
  addGlobal $ GlobalDefinition mallocGlobal
  addGlobal $ GlobalDefinition freeGlobal
