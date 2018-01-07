module Passes where
import Debug.Trace
import AST
import Util
import Control.Monad.State

passRecurseE :: (Expr -> Expr) -> Expr -> Expr
passRecurseE p (Binary b l r) = Binary b (p l) (p r)
passRecurseE p (If a b c) = If (p a) (p b) (p c)
passRecurseE p (Let pre e) = Let ([(n,p ex) | (n,ex) <- pre]) (p e)
passRecurseE p (Call f args) = Call (p f) (map p args)
passRecurseE p (Lambda args ty ret) = Lambda args ty (p ret)
passRecurseE p (Access ex prop) = Access (p ex) prop
passRecurseE p (StructLiteral exs) = StructLiteral $ [(n,p ex) | (n,ex) <- exs]
passRecurseE p x = x

typeVars :: [[(String,Type)]] -> Expr -> Expr
typeVars st (TypedVar ty nm) = maybe (TypedVar ty nm) (\ty' -> TypedVar ty' nm) (resolve' st nm)
typeVars st (Var s) = maybe (Var s) (\ty -> TypedVar ty s) (resolve' st s)
typeVars st (Let pre e) =
  let
    pre' = [(n,typeVars st ex) | (n,ex) <- pre]
    in Let pre' (typeVars ([(n,typeOf ex) | (n,ex) <- pre']:st) e)
typeVars st (Lambda args ty ret) = Lambda args ty (typeVars (args:st) ret)
typeVars st e = passRecurseE (typeVars st) e

removeLambdas decls = evalState removeLambdas' 0
  where
    removeLambdas' :: State Int [Declaration]
    removeLambdas' = do
      newdefns <- fmap concat $ mapM extractLambdas decls
      put 0 --reset counter
      decls' <- mapM replaceLambdas decls
      return $ typeGlobals $ newdefns ++ decls' --gotta type dem new lambders

    closures :: Expr -> [(String,Type)]
    closures (Lambda args _ ex) =
        filter (\(x,_) -> x `notElem` (map fst args)) (usedVars ex)
      where
        usedVars (Binary _ l r) = usedVars l ++ usedVars r
        usedVars (If a b c) = usedVars a ++ usedVars b ++ usedVars c
        usedVars (Let pre e) =
          (concat $ map (usedVars . snd) pre) ++
            (filter (\(x,_) -> x `notElem` (map fst pre)) $ usedVars e)
        usedVars (Call f args) =
          usedVars f ++ concat (map usedVars args)
        usedVars (Lambda args _ ex) =
          (filter (\(x,_) -> x `notElem` (map fst args)) $ usedVars ex)
        usedVars (Access ex _) =
          usedVars ex
        usedVars (StructLiteral props) =
          concat $ (map (usedVars . snd) props)
        usedVars (TypedVar ty name) = [(name,ty)]
        usedVars (Var _) = error "Oops, missed a var"
        usedVars _ = []

    extractLambdas :: Declaration -> State Int [Declaration]
    extractLambdas (Extern _ _) = return []
    extractLambdas (FuncDef _ _ _ expr) = extractLambdasE expr

    extractLambdasE :: Expr -> State Int [Declaration]
    extractLambdasE (Binary _ l r) = do
      lds <- extractLambdasE l
      rds <- extractLambdasE r
      return $ lds ++ rds
    extractLambdasE (If a b c) = do
      ads <- extractLambdasE a
      bds <- extractLambdasE b
      cds <- extractLambdasE c
      return $ ads ++ cds ++ cds
    extractLambdasE (Let pre e) = do
      preds <- fmap concat $ mapM extractLambdasE (map snd pre)
      eds <- extractLambdasE e
      return $ preds ++ eds
    extractLambdasE (Call f args) = do
      fds <- extractLambdasE f
      argsds <- fmap concat $ mapM extractLambdasE args
      return $ fds ++ argsds
    extractLambdasE (Access ex _) = extractLambdasE ex
    extractLambdasE (StructLiteral props) =
      fmap concat $ mapM extractLambdasE (map snd props)
    extractLambdasE whole@(Lambda args ret ex) = do
      exds <- extractLambdasE ex
      counter <- get
      let
        clses = closures whole
        this = FuncDef ("lambda__" ++ show counter) (clses ++ args) ret ex
      put $ counter + 1
      return $ this:exds
    extractLambdasE _ = return []

    replaceLambdas :: Declaration -> State Int Declaration
    replaceLambdas (Extern a b) = return $ Extern a b
    replaceLambdas (FuncDef nm args ty expr) = do
      expr' <- replaceLambdasE expr
      return $ FuncDef nm args ty expr'

    replaceLambdasE :: Expr -> State Int Expr
    replaceLambdasE (Binary op l r) = do
      l' <- replaceLambdasE l
      r' <- replaceLambdasE r
      return $ Binary op l' r'
    replaceLambdasE (If a b c) = do
      a' <- replaceLambdasE a
      b' <- replaceLambdasE b
      c' <- replaceLambdasE c
      return $ If a' b' c'
    replaceLambdasE (Let pre e) = do
      pre' <- flip mapM pre $ \(nm,ex) -> do
        ex' <- replaceLambdasE ex
        return (nm,ex')
      e' <- replaceLambdasE e
      return $ Let pre' e'
    replaceLambdasE (Call f args) = do
      f' <- replaceLambdasE f
      args' <- mapM replaceLambdasE args
      return $ Call f' args'
    replaceLambdasE (Access ex s) = do
      ex' <- replaceLambdasE ex
      return $ Access ex' s
    replaceLambdasE (StructLiteral props) = do
      props' <- flip mapM props $ \(nm,ex) -> do
        ex' <- replaceLambdasE ex
        return (nm,ex')
      return $ StructLiteral props'
    replaceLambdasE whole@(Lambda _ _ _) = do
      counter <- get
      put $ counter + 1
      let clses = closures whole
      return $ Call (Var $ "lambda__" ++ show counter) (map (\(nm,ty) -> TypedVar ty nm) clses)
    replaceLambdasE x = return x

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

runPasses = validate . removeLambdas . typeArgs . typeGlobals
