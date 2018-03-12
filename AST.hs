module AST where
import Data.Maybe
import Util (commonArgs)
import Data.List
import Data.Char

data Type = HInt | HFloat | HBool | HChar | Func [Type] Type |
            Structure [(String,Type)] | Union [(String,Type)] | TypeVar (Maybe Type) String |
            TemplateType String [Type]

instance Eq Type where
  HInt == HInt = True
  HFloat == HFloat = True
  HBool == HBool = True
  HChar == HChar = True
  (Func tys1 ty1) == (Func tys2 ty2) = tys1 == tys2 && ty1 == ty2
  (Structure tys1) == (Structure tys2) = map snd tys1 == map snd tys2 --order must be preserved, but names can differ
  (Union tys1) == (Union tys2) = map snd tys1 == map snd tys2
  (TypeVar a nm1) == (TypeVar b nm2) = nm1 == nm2 || a == b
  ty1 == (TypeVar (Just ty2) _) = ty1 == ty2
  (TypeVar (Just ty1) _) == ty2 = ty1 == ty2
  (TemplateType nm1 tys1) == (TemplateType nm2 tys2) = tys1 == tys2 && nm1 == nm2
  _ == _ = False

instance Show Type where
  show HInt = "int"
  show HFloat = "float"
  show HBool = "bool"
  show HChar = "char"
  show (Func tys ret) = "((" ++ intercalate "," (map show tys) ++ ")->" ++ show ret ++ ")"
  show (Structure names) = "{" ++ intercalate "," (map (\(nm,ty) -> nm ++ ":" ++ show ty) names) ++ "}"
  show (Union names) =  "{" ++ intercalate "|" (map (\(nm,ty) -> nm ++ ":" ++ show ty) names) ++ "}"
  show (TypeVar Nothing nm) = nm ++ "(undefined)"
  show (TypeVar (Just _) nm) = nm
  show (TemplateType nm tys) = nm ++ "<" ++ intercalate "," (map show tys) ++ ">"

mangle nm tys = nm ++ "__template__" ++ concat (map serializeType tys) ++ "__"

serializeType HInt = "int"
serializeType HFloat = "float"
serializeType HBool = "bool"
serializeType HChar = "char"
serializeType (Func tys ret) =
  "func__" ++ serializeType ret ++ "__" ++ intercalate "_" (map serializeType tys) ++ "__"
serializeType (Structure names) =
  "struct__" ++ intercalate "_" (map (serializeType . snd) names) ++ "__"
serializeType (Union names) =
  "struct__" ++ intercalate "_" (map (serializeType . snd) names) ++ "__"
serializeType (TypeVar _ nm) = nm
serializeType (TemplateType nm tys) = mangle nm tys

data Expr = ILit Int |
            FLit Float |
            BLit Bool |
            CLit Char |
            Binary BinOp Expr Expr |
            If Expr Expr Expr |
            Var (Maybe Type) String |
            TemplateVar String [Type] |
            Let [(String,Expr)] Expr |
            Call Expr [Expr] |
            Lambda [(String,Type)] Type Expr |
            Access Expr String |
            StructLiteral [(String,Expr)] |
            Cast Type Expr |
            Unionize Type String Expr |
            Case Type Expr [(String,String,Expr)] deriving Eq

instance Show Expr where
  show (ILit x) = show x
  show (FLit f) = show f
  show (BLit b) = show b
  show (CLit c) = "'\\" ++ show (ord c) ++ "'"
  show (Binary op l r) = show l ++ show op ++ show r
  show (If c l r) = "if {" ++ show c ++ "} then {" ++ show l ++ "} else {" ++ show r ++ "}"
  show (Var Nothing s) = s
  show (Var (Just ty) s) = s ++ ":" ++ show ty
  show (TemplateVar s tys) = s ++ "<" ++ intercalate "," (map show tys) ++ ">"
  show (Let pre e) = "let {" ++ intercalate ", " (map show pre) ++ "} in {" ++ show e ++ "}"
  show (Call e args) = "(" ++ show e ++ ")(" ++ intercalate ", " (map show args) ++ ")"
  show (Lambda args ty ex) = "{lambda(" ++ intercalate ", " (map (\(nm,ty)->nm ++ ":" ++ show ty) args) ++ ")->" ++ show ty ++ "=" ++ show ex ++ "}"
  show (Access ex prop) = "(" ++ show ex ++ ")." ++ prop
  show (StructLiteral exs) = "{" ++ intercalate ", " (map (\(nm,ex)->nm++"="++show ex) exs) ++ "}"
  show (Cast ty expr) = "cast<" ++ show ty ++ ">(" ++ show expr ++ ")"
  show (Unionize ty nm expr) = "unionize<" ++ show ty ++ ">(" ++ nm ++ "=" ++ show expr ++ ")"
  show (Case ty expr cases) = "case<"++show ty++"> {" ++ show expr ++ "} of {" ++ concat (map (\(nm,cs,ex) -> nm ++ ":" ++ cs ++ "=" ++ show ex ++ ";") cases) ++ "}"

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
castable HChar HInt = True
castable HInt HChar = True
castable x y = x == y

deAlias (TypeVar ty _) = deAlias $ fromJust ty
deAlias x = x

typeOf :: Expr -> Type
typeOf (ILit _) = HInt
typeOf (FLit _) = HFloat
typeOf (BLit _) = HBool
typeOf (CLit _) = HChar
typeOf (Binary op l r) =
  let lt = typeOf l
      rt = typeOf r
  in if lt /= rt then
      error "Can't compare different types"
    else
      if isMath op then
        case deAlias lt of
          HInt -> HInt
          HFloat -> HFloat
          lt -> error $ "Can't add type " ++ show lt
      else
        if isComp op then
          case deAlias lt of
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
typeOf (Var (Just t) _) = t
typeOf (Var Nothing ow) = error $ "Variable " ++ ow ++ " undeclared"
typeOf w@(Call f args) =
  let
    tf = typeOf f
    ta = map typeOf args
  in
    case deAlias tf of
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
            error $ show w ++ ": More args than the function takes"
        else ret
      _ -> error "You can only call a function!"
typeOf (Lambda args rettype expr) =
  if typeOf expr == rettype then
    Func (map snd args) $ typeOf expr
  else
    error "Lambda return disagrees with actual return."
typeOf (Access expr label) =
  case deAlias $ typeOf expr of
    (Structure types) -> case lookup label types of
      Nothing -> error $ "Field" ++ label ++ "DNE"
      (Just x) -> x
    _ -> error $ "not a structure"
typeOf (StructLiteral exs) = Structure $ map (\(nm,e) -> (nm,typeOf e)) exs
typeOf (Cast ty expr) =
  if castable (deAlias ty) (deAlias $ typeOf expr) then
    ty
  else
    error $ "Can't cast type " ++ show (typeOf expr) ++ " to " ++ show ty
typeOf (Unionize ty cs expr) =
  case deAlias ty of
    (Union types) -> case lookup cs types of
        Nothing -> error $ "Union type " ++ cs ++ " is not a member of type " ++ show ty
        (Just exty) ->
          if typeOf expr == exty then
            ty
          else
            error $ "Expected type (" ++ show exty
    _ -> error "Can only unionize to union"
typeOf (Case ty ex cases) =
  case deAlias $ typeOf ex of
    whole@(Union _) ->
      if whole /= ty then
        error "Type mismatch"
      else
        let (_,_,first) = cases !! 0
        in (foldl (\acc x -> if acc /= x then error "Different types in case branch" else acc) (typeOf first) [typeOf lst | (_,_,lst) <- cases])
    bad -> error $ "Expected union for case but got type " ++ show bad


data Declaration =
  FuncDef String [(String,Type)] Type Expr |
  Extern String Type |
  TypeDef String Type |
  --syntactical sugar below
  Data String [(String,Type)] |
  Template [String] Declaration |
  SpecificTemplate [Type] Declaration |
  Import String deriving Eq

instance Show Declaration where
  show (FuncDef nm args ret bod) =
    nm ++ "(" ++ intercalate "," (map (\(x,y) -> x ++ ":" ++ show y) args) ++
    ") -> " ++ show ret ++ " = " ++ show bod ++ ";"
  show (Extern nm ty) = "extern " ++ nm ++ " : " ++ show ty ++ ";"
  show (TypeDef nm ty) = "type " ++ nm ++ " = " ++ show ty ++ ";"
  show (Data nm css) =
    let nms = map fst css
        tys = map snd css
      in "data " ++ nm ++ " = " ++ intercalate " | " (map show tys) ++ ";"
  show (Template vars st) =
    "template<" ++ intercalate "," vars ++ "> " ++ show st
  show (SpecificTemplate vars st) =
    "template<" ++ intercalate "," (map show vars) ++ "> " ++ show st
  show (Import s) = "import " ++ s ++ ";"

typeofDecl :: Declaration -> Maybe (String,Type)
typeofDecl (FuncDef name tys ret result) = Just (name, Func (map snd tys) ret)
typeofDecl (Extern nm ty) = Just (nm,ty)
typeofDecl (TypeDef nm ty) = Nothing

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
    val (TypeDef _ _) = 0
