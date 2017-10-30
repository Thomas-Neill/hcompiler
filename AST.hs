module AST where
import Data.Maybe

data Type = HInt | HFloat | HBool | Func [Type] Type deriving (Show,Eq)

isNum HInt = True
isNum HFloat = True
isNum _ = False

data Expr = ILit Integer |
            FLit Float |
            BLit Bool |
            Binary BinOp Expr Expr |
            If Expr Expr Expr |
            Var String |
            TypedVar Type String |
            Let [(String,Expr)] Expr | deriving Show

data BinOp = Add | Sub | Mul | Div | Equal | Inequal | Greater | Less deriving (Show,Eq)

isComp Equal = True
isComp Inequal = True
isComp Greater = True
isComp Less = True
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
      wrongtypes = error "Inequal types to compare"
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
typeOf (Var ow) = error $ "Ooops, var " ++ ow ++ " not named properly."

binResult HFloat _ = HFloat
binResult _ HFloat = HFloat
binResult HInt HInt = HInt

data Declaration = FuncDef String [(String,Type)] Type Expr deriving Show

typeofDecl :: Declaration -> (String,Type)
typeofDecl (FuncDef name tys ret result) =
  if typeOf result /= ret then
    error "Wrong return type!"
  else
    (name, Func (map snd tys) ret)

getDefns :: [Declaration] -> [(String,Type)]
getDefns = map typeofDecl
