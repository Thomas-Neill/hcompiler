module AST where
import Data.Maybe
import Util (commonArgs)
import Data.List

data Type = HInt | HFloat | HBool | Func [Type] Type |
            Structure [(String,Type)] deriving Eq

instance Show Type where
  show HInt = "int"
  show HFloat = "float"
  show HBool = "bool"
  show (Func tys ret) = "((" ++ intercalate "," (map show tys) ++ ")->" ++ show ret ++ ")"
  show (Structure names) = "{" ++ intercalate "," (map (\(nm,ty) -> nm ++ ":" ++ show ty) names) ++ "}"


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
            StructLiteral [(String,Expr)] |
            Cast Type Expr

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
  show (Cast ty expr) = "cast<" ++ show ty ++ ">(" ++ show expr ++ ")"

data BinOp = Add | Sub | Mul | Div | Equal | Inequal | Greater | Less | GrEqual | LEqual | And | Or deriving Eq

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
  show And = "&&"
  show Or = "||"

isComp Equal = True
isComp Inequal = True
isComp Greater = True
isComp Less = True
isComp GrEqual = True
isComp LEqual = True
isComp _ = False

isMath Add = True
isMath Sub = True
isMath Mul = True
isMath Div = True
isMath _ = False

castable :: Type -> Type -> Bool
castable HInt HBool = True
castable HBool HInt = True
castable HFloat HInt = True
castable HInt HFloat = True
castable x y = x == y

typeOf :: Expr -> Type
typeOf (ILit _) = HInt
typeOf (FLit _) = HFloat
typeOf (BLit _) = HBool
typeOf (Binary op l r) =
  let lt = typeOf l
      rt = typeOf r
  in if lt /= rt then
      error "Can't compare different types"
    else
      if isMath op then
        case lt of
          HInt -> HInt
          HFloat -> HFloat
          lt -> error $ "Can't add type " ++ show lt
      else
        if isComp op then
          case lt of
            HInt -> HBool
            HFloat -> HBool
            HBool -> HBool
            other -> error $ "It is impossible to compare items of type " ++ show other
        else --logical/bitwise
          if lt == HInt || lt == HBool then
            lt
          else
            error $ "Can't perform logical/bitwise operations on type " ++ show lt
typeOf (If c l r) =
  let ct = typeOf c
      lt = typeOf l
      rt = typeOf r
  in
    if ct /= HBool then
      error "Expected bool in condition."
    else
      if lt /= rt then
          error "Expected both sides of if to be same type."
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
            let (applied,remaining) = splitAt (length ta) args
            in
              if applied == ta then
                Func remaining ret
              else
                error "Invalid arg types"
          else
            error "More args than the function takes"
        else ret
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
typeOf (Cast ty expr) =
  if castable ty (typeOf expr) then
    ty
  else
    error $ "Can't cast type " ++ show (typeOf expr) ++ " to " ++ show ty
    
typeOf (Var ow) = error $ "Variable " ++ ow ++ " undeclared"

data Declaration =
  FuncDef String [(String,Type)] Type Expr |
  Extern String Type

instance Show Declaration where
  show (FuncDef nm args ret bod) =
    nm ++ "(" ++ intercalate " " (map (\(x,y) -> x ++ ":" ++ show y) args) ++
    ") -> " ++ show ret ++ " = " ++ show bod ++ ";"
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
