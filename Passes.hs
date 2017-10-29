module Passes where

import AST
import Util

passRecurse :: (Expr -> Expr) -> Expr -> Expr
passRecurse p (Binary b l r) = Binary b (p l) (p r)
passRecurse p (If a b c) = If (p a) (p b) (p c)
passRecurse p (Let pre e) = Let ([(n,p ex) | (n,ex) <- pre]) (p e)
passRecurse p x = x

typeVars :: [[(String,Type)]] -> Expr -> Expr
typeVars st (Var s) = TypedVar (resolve st s) s
typeVars st (Let pre e) = Let [(n,typeVars st ex) | (n,ex) <- pre] (typeVars ([(n,typeOf ex) | (n,ex) <- pre]:st) e)
typeVars st e = passRecurse (typeVars st) e

runPasses = map (\(FuncDef na tys e) -> FuncDef na tys $ typeVars [tys] e)
