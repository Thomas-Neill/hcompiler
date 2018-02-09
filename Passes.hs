module Passes where
import AST
import Util
import Control.Monad.State
import Data.Maybe
import Debug.Trace
passRecurseE :: (Expr -> Expr) -> Expr -> Expr
passRecurseE p w@(ILit _) = w
passRecurseE p w@(FLit _) = w
passRecurseE p w@(BLit _) = w
passRecurseE p (Binary b l r) = Binary b (p l) (p r)
passRecurseE p w@(Var _ _) = w
passRecurseE p (If a b c) = If (p a) (p b) (p c)
passRecurseE p (Let pre e) = Let ([(n,p ex) | (n,ex) <- pre]) (p e)
passRecurseE p (Call f args) = Call (p f) (map p args)
passRecurseE p (Lambda args ty ret) = Lambda args ty (p ret)
passRecurseE p (Access ex prop) = Access (p ex) prop
passRecurseE p (StructLiteral exs) = StructLiteral $ [(n,p ex) | (n,ex) <- exs]
passRecurseE p (Cast ty ex) = Cast ty (p ex)
passRecurseE p (Unionize ty nm ex) = Unionize ty nm (p ex)
passRecurseE p (Case ty ex exs) = Case ty (p ex) [(a,b,p e) | (a,b,e) <- exs]

typeVars :: [[(String,Type)]] -> Expr -> Expr
typeVars st (Var Nothing s) = Var (resolve' st s) s
typeVars st (Var old nm) = Var (maybe old Just (resolve' st nm)) nm
typeVars st (Let pre e) =
  let
    pre' = [(n,typeVars st ex) | (n,ex) <- pre]
    in Let pre' (typeVars ([(n,typeOf ex) | (n,ex) <- pre']:st) e)
typeVars st (Lambda args ty ret) = Lambda args ty (typeVars (args:st) ret)
typeVars st (Case ty ex exs) =
  let
    (Union typeMap) = deAlias ty
    getType cs = fromJust $ lookup cs typeMap
  in Case ty (typeVars st ex) [(n,cs,typeVars ([(n,getType cs)]:st) e) | (n,cs,e) <- exs]
typeVars st e = passRecurseE (typeVars st) e

removeLambdas decls = evalState removeLambdas' 0
  where
    removeLambdas' :: State Int [Declaration]
    removeLambdas' = do
      newdefns <- fmap concat $ mapM extractLambdas decls
      put 0 --reset counter
      decls' <- mapM replaceLambdas decls
      return $ typeGlobals $ newdefns ++ decls' --gotta type the new lambdas

    closures :: Expr -> [(String,Type)]
    closures (Lambda args _ ex) =
        filter (\(x,_) -> x `notElem` (map fst args)) (usedVars ex)
      where
        usedVars (ILit _) = []
        usedVars (FLit _) = []
        usedVars (BLit _) = []
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
        usedVars (Cast _ ex) = usedVars ex
        usedVars (Unionize _ _ ex) = usedVars ex
        usedVars (Case _ ex css) = usedVars ex ++ concat [usedVars expr | (_,_,expr) <- css]
        usedVars (Var (Just ty) name) = [(name,ty)]
        usedVars (Var Nothing _) = error "Oops, missed a var"

    extractLambdas :: Declaration -> State Int [Declaration]
    extractLambdas (Extern _ _) = return []
    extractLambdas (FuncDef _ _ _ expr) = extractLambdasE expr

    extractLambdasE :: Expr -> State Int [Declaration]
    extractLambdasE (ILit _) = return []
    extractLambdasE (FLit _) = return []
    extractLambdasE (BLit _) = return []
    extractLambdasE (Binary _ l r) = do
      lds <- extractLambdasE l
      rds <- extractLambdasE r
      return $ lds ++ rds
    extractLambdasE (If a b c) = do
      ads <- extractLambdasE a
      bds <- extractLambdasE b
      cds <- extractLambdasE c
      return $ ads ++ cds ++ cds
    extractLambdasE (Var _ _) = return []
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
    extractLambdasE (Cast _ ex) = extractLambdasE ex
    extractLambdasE (Unionize _ _ ex) = extractLambdasE ex
    extractLambdasE (Case _ ex css) = do
      exds <- extractLambdasE ex
      cssds <- mapM extractLambdasE [expr | (_,_,expr) <- css]
      return $ exds ++ concat cssds
    extractLambdasE whole@(Lambda args ret ex) = do
      exds <- extractLambdasE ex
      counter <- get
      let
        clses = closures whole
        this = FuncDef ("lambda__" ++ show counter) (clses ++ args) ret ex
      put $ counter + 1
      return $ this:exds

    replaceLambdas :: Declaration -> State Int Declaration
    replaceLambdas (Extern a b) = return $ Extern a b
    replaceLambdas (FuncDef nm args ty expr) = do
      expr' <- replaceLambdasE expr
      return $ FuncDef nm args ty expr'

    replaceLambdasE :: Expr -> State Int Expr
    replaceLambdasE w@(ILit _) = return w
    replaceLambdasE w@(FLit _) = return w
    replaceLambdasE w@(BLit _) = return w
    replaceLambdasE (Binary op l r) = do
      l' <- replaceLambdasE l
      r' <- replaceLambdasE r
      return $ Binary op l' r'
    replaceLambdasE (If a b c) = do
      a' <- replaceLambdasE a
      b' <- replaceLambdasE b
      c' <- replaceLambdasE c
      return $ If a' b' c'
    replaceLambdasE w@(Var _ _ ) = return w
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
    replaceLambdasE (Cast ty ex) = do
      ex' <- replaceLambdasE ex
      return $ Cast ty ex'
    replaceLambdasE (Unionize ty cs ex) = do
      ex' <- replaceLambdasE ex
      return $ Unionize ty cs ex'
    replaceLambdasE (Case t ex css) = do
      ex' <- replaceLambdasE ex
      css' <- flip mapM css $ \(var,css,expr) -> do
        expr' <- replaceLambdasE expr
        return (var,css,expr')
      return (Case t ex' css')
    replaceLambdasE whole@(Lambda _ _ _) = do
      counter <- get
      put $ counter + 1
      let clses = closures whole
      return $ Call (Var Nothing $ "lambda__" ++ show counter) (map (\(nm,ty) -> Var (Just ty) nm) clses)

typeGlobals decls = map typeGlobals' decls
  where -- type global definitions
    glbs = catMaybes $ map typeofDecl decls
    typeGlobals' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [glbs] expr
    typeGlobals' (Extern nm ty) = Extern nm ty

typeArgs decls = map typeArgs' decls
  where --type arguments to functions
    typeArgs' (FuncDef name types ret expr) =
      FuncDef name types ret $ typeVars [types] expr
    typeArgs' (Extern nm ty) = Extern nm ty

typeAliases decls = catMaybes $ map typeAliases' decls
  where
    typeAlias ty = let
      getTypeAliases (FuncDef _ _ _ _) = Nothing
      getTypeAliases (Extern _ _) = Nothing
      getTypeAliases (TypeDef nm ty) = Just (nm,ty)
      typetbl = (catMaybes $ map getTypeAliases decls)
      in
        case ty of
          HInt -> HInt
          HBool -> HBool
          (Func tys ty) -> Func (map typeAlias tys) (typeAlias ty)
          (Structure tys) -> Structure [(nm,typeAlias ty)|(nm,ty)<-tys]
          (Union tys) -> Union [(nm,typeAlias ty)|(nm,ty)<-tys]
          (TypeVar Nothing nm) -> TypeVar (fmap typeAlias (lookup nm typetbl)) nm
    typeAliases' (FuncDef name args ty ex) =
      Just $ FuncDef name [(nm,typeAlias ty)|(nm,ty)<-args] (typeAlias ty) (typeAliasesE ex)
    typeAliases' (Extern nm ty) = Just $ Extern nm ty
    typeAliases' (TypeDef nm ty) = Nothing

    typeAliasesE (Var (Just ty) nm) = Var (Just $ typeAlias ty) nm
    typeAliasesE (Lambda args ret ex) = Lambda [(nm,typeAlias ty) | (nm,ty) <- args] (typeAlias ret) (typeAliasesE ex)
    typeAliasesE (Cast ty ex) = Cast (typeAlias ty) (typeAliasesE ex)
    typeAliasesE (Unionize ty nm ex) = Unionize (typeAlias ty) nm (typeAliasesE ex)
    typeAliasesE (Case ty ex cases) = Case (typeAlias ty) ex [(nm,cs,typeAliasesE ex) | (nm,cs,ex) <- cases]
    typeAliasesE ex = passRecurseE typeAliasesE ex

removeData decls = newdefns ++ (filter isntdata decls)
  where
    isntdata (Data _ _) = False
    isntdata _ = True
    newdefns = concat $ map getnewdefns decls
    getnewdefns (Data nm tys) =
      let
        actualty = Union tys
        tydef = (TypeDef nm actualty)
        constructors = map makeConstructor tys
        makeConstructor (nm,ty') = case ty' of
          (Structure tys) -> FuncDef nm tys actualty $ Unionize actualty nm $ StructLiteral $ map (\(nm,_) -> (nm,Var Nothing nm)) tys
          ty -> FuncDef nm [("a",ty)] actualty (Unionize actualty nm (Var Nothing "a"))
      in tydef : constructors
    getnewdefns _ = []

runPasses = validate . removeLambdas . typeArgs . typeGlobals . typeAliases . removeData
