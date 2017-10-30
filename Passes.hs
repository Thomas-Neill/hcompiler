module Passes where

import AST
import Util

passRecurseE :: (Expr -> Expr) -> Expr -> Expr
passRecurseE p (Binary b l r) = Binary b (p l) (p r)
passRecurseE p (If a b c) = If (p a) (p b) (p c)
passRecurseE p (Let pre e) = Let ([(n,p ex) | (n,ex) <- pre]) (p e)
passRecurseE p x = x

typeVars :: [[(String,Type)]] -> Expr -> Expr
typeVars st (Var s) = maybe (Var s) (\ty -> TypedVar ty s) (resolve' st s)
typeVars st (Let pre e) = Let [(n,typeVars st ex) | (n,ex) <- pre] (typeVars ([(n,typeOf ex) | (n,ex) <- pre]:st) e)
typeVars st e = passRecurseE (typeVars st) e

typeArgs decls = map typeArgs' decls
  where
    typeArgs' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [types] expr

typeGlobals decls = map typeGlobals' decls
  where
    glbs = getDefns decls
    typeGlobals' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [glbs] expr

runPasses = typeGlobals . typeArgs
