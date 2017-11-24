module Passes where
import Debug.Trace
import AST
import Util

traceThrough :: (Show a) => a -> a
traceThrough x = trace (show x) x

passRecurseE :: (Expr -> Expr) -> Expr -> Expr
passRecurseE p (Binary b l r) = Binary b (p l) (p r)
passRecurseE p (If a b c) = If (p a) (p b) (p c)
passRecurseE p (Let pre e) = Let ([(n,p ex) | (n,ex) <- pre]) (p e)
passRecurseE p (Call f args) = Call (p f) (map p args)
passRecurseE p x = x

typeVars :: [[(String,Type)]] -> Expr -> Expr
typeVars st (Var s) = maybe (Var s) (\ty -> TypedVar ty s) (resolve' st s)
typeVars st (Let pre e) =
  let
    pre' = [(n,typeVars st ex) | (n,ex) <- pre]
    in Let pre' (typeVars ([(n,typeOf ex) | (n,ex) <- pre']:st) e)
typeVars st e = passRecurseE (typeVars st) e

updateVars :: [[(String,Type)]] -> Expr -> Expr
updateVars st (TypedVar ty nm) = maybe (TypedVar ty nm) (\ty' -> TypedVar ty' nm) (resolve' st nm)
updateVars st (Let pre e) = Let [(n,updateVars st ex) | (n,ex) <- pre] (updateVars ([(n,typeOf ex) | (n,ex) <- pre]:st) e)
updateVars st e = passRecurseE (updateVars st) e

typeGlobals decls = map typeGlobals' decls
  where -- type global definitions
    glbs = map typeofDecl decls
    typeGlobals' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [glbs] expr
    typeGlobals' (Extern nm ty) = Extern nm ty

typeArgs decls = map typeArgs' decls
  where --type arguments to functions
    typeArgs' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [types] expr
    typeArgs' (Extern nm ty) = Extern nm ty

actualTypeGlobals decls = map actualTypeGlobals' decls
  where --we can now find the actual types using the function bodies
    fixed = map typeofDeclAct decls
    actualTypeGlobals' (FuncDef name types ret expr) =
      FuncDef name types (typeOf expr) $ updateVars [fixed] expr
    actualTypeGlobals' (Extern nm ty) = Extern nm ty

runPasses = validate . actualTypeGlobals . typeArgs . typeGlobals
