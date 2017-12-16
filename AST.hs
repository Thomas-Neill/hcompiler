module AST where
import Data.Maybe
import Util (commonArgs)
import Data.List

data Type = HInt | HFloat | HBool | Func [Type] Type | Curry [Type] Type Int |
            Structure [(String,Type)]

instance Show Type where
  show HInt = "int"
  show HFloat = "float"
  show HBool = "bool"
  show (Func tys ret) = "((" ++ intercalate "," (map show tys) ++ ")->" ++ show ret ++ ")"
  show (Curry tys ret app) = show (Func (drop app tys) ret)
  show (Structure names) = "{" ++ intercalate "," (map (\(nm,ty) -> nm ++ ":" ++ show ty) names) ++ "}"

instance Eq Type where
  HInt == HInt = True
  HFloat == HFloat = True
  HBool == HBool = True
  Func args ret == Func args1 ret1 = args == args1 && ret == ret1
  (Curry args ret applied) == Func args1 ret1 =
    ret == ret1 && (drop applied args) == args1
  f@(Func _ _) == c@(Curry _ _ _) = c == f
  (Curry args ret applied) == (Curry args1 ret1 applied1) =
    args == args1 && ret == ret1 && applied == applied1
  --note: for two structure types to be equal, their fields must be in the same order
  --and have the same names; hopefully this will prevent bugs
  (Structure members) == (Structure members') = members == members'
  _ == _ = False


isNum HInt = True
isNum HFloat = True
isNum _ = False

data Expr = ILit Int |
            FLit Float |
            BLit Bool |
            Binary BinOp Expr Expr |
            If Expr Expr Expr |
            Var String |
            TypedVar Type String |
            Let [(String,Expr)] Expr |
            Call Expr [Expr] |
            Lambda [(String,Type)] Type Expr |
            Access Expr String |
            StructLiteral [(String,Expr)]

instance Show Expr where
  show (ILit x) = show x
  show (FLit f) = show f
  show (BLit b) = show b
  show (Binary op l r) = show l ++ show op ++ show r
  show (If c l r) = "if {" ++ show c ++ "} then {" ++ show l ++ "} else {" ++ show r ++ "}"
  show (Var s) = s
  show (TypedVar ty s) = s ++ ":" ++ show ty
  show (Let pre e) = "let {" ++ intercalate ", " (map show pre) ++ "} in {" ++ show e ++ "}"
  show (Call e args) = "(" ++ show e ++ ")(" ++ intercalate ", " (map show args) ++ ")"
  show (Lambda args ty ex) = "{lambda(" ++ intercalate ", " (map (\(nm,ty)->nm ++ ":" ++ show ty) args) ++ ")->" ++ show ty ++ "=" ++ show ex ++ "}"
  show (Access ex prop) = "(" ++ show ex ++ ")." ++ prop
  show (StructLiteral exs) = "{" ++ intercalate ", " (map (\(nm,ex)->nm++"="++show ex) exs) ++ "}"

data BinOp = Add | Sub | Mul | Div | Equal | Inequal | Greater | Less | GrEqual | LEqual deriving Eq

instance Show BinOp where
  show Add = "+"
  show Sub = "-"
  show Mul = "*"
  show Div = "/"
  show Equal = "=="
  show Inequal = "/="
  show Greater = ">"
  show Less = "<"
  show GrEqual = ">="
  show LEqual = "<="

isComp Equal = True
isComp Inequal = True
isComp Greater = True
isComp Less = True
isComp GrEqual = True
isComp LEqual = True
isComp _ = False

isMath = not . isComp

typeOf :: Expr -> Type
typeOf (ILit _) = HInt
typeOf (FLit _) = HFloat
typeOf (BLit _) = HBool
typeOf (Binary op l r) =
  let lt = typeOf l
      rt = typeOf r
      nnumerr = error "Expected both numeric types in math expression."
      wrongtypes = error "Different types to compare"
  in if op == Div then
      if not $ isNum lt && isNum rt then
        nnumerr
      else
        HFloat
    else
      if isMath op then
        if not $ isNum lt && isNum rt then
          nnumerr
        else
          lt `binResult` rt
      else
        if lt /= rt then
          wrongtypes
        else
          HBool
typeOf (If c l r) =
  let ct = typeOf c
      lt = typeOf l
      rt = typeOf r
      excond = error "Expected bool in condition."
      branches = error "Expected both sides of if to be same type."
  in
    if ct /= HBool then
      excond
    else
      if lt /= rt then
          branches
      else
        lt
typeOf (Let es e) = (foldl1 seq $ fmap (typeOf . snd) es) `seq` typeOf e
typeOf (TypedVar t _) = t
typeOf (Call f args) =
  let
    tf = typeOf f
    ta = map typeOf args
  in
    case tf of
      (Func args ret) ->
        if args /= ta then
          if length args > length ta then
            Curry args ret (commonArgs ta args)
          else
            error "More args than the function takes"
        else ret
      (Curry args ret applied) ->
        if (drop applied args) /= ta then
          if length args - applied > length ta then
            Curry args ret (applied + commonArgs ta (drop applied args))
          else
            error "More args than the function takes"
        else
          ret
      _ -> error "You can only call a function!"
typeOf (Lambda args rettype expr) =
  if typeOf expr == rettype then
    Func (map snd args) $ typeOf expr
  else
    error "Lambda return disagrees with actual return."
typeOf (Access expr label) =
  case typeOf expr of
    (Structure types) -> case lookup label types of
      Nothing -> error $ "Field" ++ label ++ "DNE"
      (Just x) -> x
    _ -> error $ "not a structure"
typeOf (StructLiteral exs) = Structure $ map (\(nm,e) -> (nm,typeOf e)) exs
typeOf (Var ow) = error $ "Variable " ++ ow ++ " undeclared"


binResult HFloat _ = HFloat
binResult _ HFloat = HFloat
binResult HInt HInt = HInt

data Declaration =
  FuncDef String [(String,Type)] Type Expr |
  Extern String Type

instance Show Declaration where
  show (FuncDef nm args ret bod) =
    nm ++ "[" ++ intercalate " " (map (\(x,y) -> x ++ ":" ++ show y) args) ++
    "] -> " ++ show ret ++ " = " ++ show bod ++ ";"
  show (Extern nm ty) = "extern " ++ nm ++ " : " ++ show ty ++ ";"

typeofDecl :: Declaration -> (String,Type)
typeofDecl (FuncDef name tys ret result) = (name, Func (map snd tys) ret)
typeofDecl (Extern nm ty) = (nm,ty)

typeofDeclAct :: Declaration -> (String,Type)
typeofDeclAct (FuncDef name tys ret result) =
  let actual = typeOf result
  in
    (if ret == actual then 0 else
      error $ "Expected return of " ++ show ret ++ " , but got " ++ show actual)
    `seq` (name,Func (map snd tys) actual)
typeofDeclAct (Extern nm ty) = (nm,ty)

validate :: [Declaration] -> [Declaration]
validate decls = (foldl1 seq $ map val decls) `seq` decls
  where
    val (FuncDef _ _ ret result) =
      if ret == typeOf result then 0 else
        error $ "Expected return of " ++ show ret ++ " , but got " ++ show (typeOf result)
    val (Extern _ _) = 0
