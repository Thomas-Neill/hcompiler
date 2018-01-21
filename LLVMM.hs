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

import Debug.Trace
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
    scope :: [[(String,Codegen Operand)]],
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
constint :: Int -> Operand
constint = ConstantOperand . C.Int 32 . toInteger
constb b = ConstantOperand . C.Int 1 $ if b then 1 else 0
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

pushScope :: [(String,Codegen Operand)] -> Codegen ()
pushScope ex = modify $ \st -> st {scope = ex:scope st}

popScope :: Codegen ()
popScope = modify $ \st -> st { scope = tail $ scope st}

find :: String -> Codegen Operand
find s = do
    st <- get
    resolve (scope st) s

--adding instructions
addIns :: Named Instruction -> Codegen ()
addIns i = modifyCurrentBlock (\bst -> bst {instructions = instructions bst ++ [i]})

addTerm :: Terminator -> Codegen ()
addTerm t = modifyCurrentBlock (\bst -> bst {terminator = Do t})

local = LocalReference

ins ty instr = do
  nm <- fresh
  addIns $ nm := instr
  return $ local ty nm

do_ instr = do
  addIns $ Do instr

untyped_ins = ins (error "FIX THIS")

mkiBinary bin l r = ins i32 $ bin False False l r []

iadd = mkiBinary Add
imul = mkiBinary Mul
isub = mkiBinary Sub
idiv l r = ins i32 $ SDiv False l r []

bitand l r = ins i32 $ And l r []
bitor l r = ins i32 $ Or l r []
logicand l r = ins i1 $ And l r []
logicor l r = ins i1 $ Or l r []
icmp predi l r = ins i1 $ ICmp predi l r []
fcmp predi l r = ins i1 $ FCmp predi l r []

mkfBinary bin l r = ins float $ bin NoFastMathFlags l r []

fadd = mkfBinary FAdd
fsub = mkfBinary FSub
fmul = mkfBinary FMul
fdiv = mkfBinary FDiv

--type info not needed
gep ty add indices = ins ty $ GetElementPtr False add indices []

gep' ty add indices = gep ty add (map constint indices)

alloca ty = ins (pointerto ty) $ Alloca ty Nothing 0 []

alloc' ty mult = do
  sz <- gep' (pointerto ty) (ConstantOperand $ C.Null $ pointerto ty) [1]
  size <- ins i32 $ PtrToInt sz i32 []
  size' <- imul size mult
  ptr <- call (ConstantOperand $ C.GlobalReference allocType (strtoname "alloc")) [size']
  bitcast ptr (pointerto ty)
  where
    allocType = pointerto $ FunctionType voidptr [i32] False

alloc ty = alloc' ty (constint 1)

pointerize ty val = do
  body <- alloc (pointerReferent ty)
  store body val
  return body

alloc_push =
  let
    ty = pointerto $ FunctionType VoidType [] False
  in docall (ConstantOperand $ C.GlobalReference ty $ strtoname "alloc_push") []

alloc_depends dependr depende = do
  let
    ty = pointerto $ FunctionType VoidType [voidptr,voidptr] False
  depr' <- bitcast dependr voidptr
  depe' <- bitcast depende voidptr
  docall (ConstantOperand $ C.GlobalReference ty $ strtoname "alloc_depends") [depr',depe']

alloc_pop_except rt = do
  let
    ty = pointerto $ FunctionType VoidType [voidptr] False
  rt' <- bitcast rt voidptr
  docall (ConstantOperand $ C.GlobalReference ty $ strtoname "alloc_pop_except") [rt']

bitcast ptr ty = ins ty $ BitCast ptr ty []

load add = ins (pointerReferent $ inferType add) $ Load False add Nothing 0 []
store add val = do_ $ Store False add val Nothing 0 []

toi32 x = ins i32 $ ZExt x i32 []
addi8 l r = ins i8 $ Add False False l r []

floattoint x = ins i32 $ FPToSI x i32 []
inttofloat x = ins float $ SIToFP x float []
booltoint x = ins i32 $ ZExt x i32 []
call f args = ins (resultType $ pointerReferent $ inferType f) $
  Call Nothing CC.C [] (Right f) [(x,[]) | x <- args] [] []

docall f args = do_ $
  Call Nothing CC.C [] (Right f) [(x,[]) | x <- args] [] []

phi tp branches = ins tp $ Phi tp branches []

br lbl = addTerm $ Br lbl []
cbr b t f = addTerm $ CondBr b t f []
ret val = addTerm $ Ret (Just val) []

unreachable = addTerm $ Unreachable []

switch cond dests = do
  deflt <- newBlock
  addTerm $ Switch cond deflt dests []
  useBlock deflt
  unreachable

funcType = pointerto $ StructureType False $ [voidptr,i8,pointerto voidptr]

htoll :: H.Type -> Type
htoll H.HBool = pointerto i1
htoll H.HInt = pointerto i32
htoll H.HFloat = pointerto float
htoll (H.Func args ret) = funcType
htoll (H.Structure props) =
  pointerto $ StructureType False $ (map (htoll . snd) props)
htoll (H.Union _) =
  pointerto $ StructureType False $ [i32,voidptr]

htoc :: H.Type -> Type
htoc H.HInt = i32
htoc H.HFloat = float
htoc H.HBool = i8 --probably safe ...
htoc _ = error "Not defined"

llvaltoc :: H.Type -> Operand -> Codegen Operand
llvaltoc H.HInt x = load x
llvaltoc H.HFloat x = load x
llvaltoc H.HBool val = do
  val' <- load val
  ins i8 $ ZExt val' i8 []
llvaltoc _ _ = error "Undef"


cvaltoll H.HInt x = do
  re <- alloc i32
  store re x
  return re
cvaltoll H.HFloat x = do
  re <- alloc float
  store re x
  return re
cvaltoll H.HBool x = do
  done <- newBlock
  zero <- newBlock
  nonzero <- newBlock
  re <- alloc i1
  addTerm $ Switch x nonzero [(C.Int 8 0,zero)] []

  useBlock zero
  store re (constb False)
  br done

  useBlock nonzero
  store re (constb True)
  br done

  useBlock done
  return re
cfuncPtrType (H.Func args ret) = pointerto $ FunctionType (htoc ret) (map htoc args) False

--instead of the function objects we pass around, this is the actual LLVM function pointer type
funcPtrType :: H.Type -> Type
funcPtrType (H.Func args ret) = pointerto $ FunctionType (htoll ret) (map htoll args) False

funcNargs ret nargs = pointerto $ FunctionType ret (replicate nargs voidptr) False

pointerto ty = PointerType ty (AS.AddrSpace 0)

voidptr = pointerto i8

inferType :: Operand -> Type
inferType (LocalReference ty _) = ty
inferType (ConstantOperand c) = case c of
  (C.GlobalReference ty _) -> ty
  _ -> error "not implemented yet"

requiredDefns = do
  let
    mallocGlobal = genFunction voidptr (strtoname "malloc") [(i32,strtoname "size")]
    freeGlobal = genFunction VoidType (strtoname "free") [(voidptr,strtoname "target")]
    allocPushGlobal = genFunction VoidType (strtoname "alloc_push") []
    allocGlobal = genFunction voidptr (strtoname "alloc") [(i32,strtoname "size")]
    allocDependsGlobal = genFunction VoidType (strtoname "alloc_depends") [(voidptr,strtoname "depender"),(voidptr,strtoname "dependee")]
    allocPopExceptGlobal = genFunction VoidType (strtoname "alloc_pop_except") [(voidptr,strtoname "return")]
  addGlobal $ GlobalDefinition mallocGlobal
  addGlobal $ GlobalDefinition freeGlobal
  addGlobal $ GlobalDefinition allocPushGlobal
  addGlobal $ GlobalDefinition allocGlobal
  addGlobal $ GlobalDefinition allocDependsGlobal
  addGlobal $ GlobalDefinition allocPopExceptGlobal
