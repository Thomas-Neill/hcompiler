module Passes where
import AST
import Util
import Control.Monad
import Control.Monad.State
import Control.Monad.Identity
import Data.Maybe
import Data.List
import Debug.Trace
import Parse
import Traversals

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
typeVars st e = passRecurse (typeVars st) e

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
        usedVars (Var (Just ty) name) = [(name,ty)]
        usedVars (Var Nothing _) = error "Oops, missed a var"
        usedVars ex = passAccumulate usedVars ex

    extractLambdas :: Declaration -> State Int [Declaration]
    extractLambdas (Extern _ _) = return []
    extractLambdas (FuncDef _ _ _ expr) = extractLambdasE expr

    extractLambdasE :: Expr -> State Int [Declaration]
    extractLambdasE whole@(Lambda args ret ex) = do
      exds <- extractLambdasE ex
      counter <- get
      let
        clses = closures whole
        this = FuncDef ("lambda__" ++ show counter) (clses ++ args) ret ex
      put $ counter + 1
      return $ this:exds
    extractLambdasE x = passAccumulateM extractLambdasE x

    replaceLambdas :: Declaration -> State Int Declaration
    replaceLambdas (Extern a b) = return $ Extern a b
    replaceLambdas (FuncDef nm args ty expr) = do
      expr' <- replaceLambdasE expr
      return $ FuncDef nm args ty expr'

    replaceLambdasE :: Expr -> State Int Expr
    replaceLambdasE whole@(Lambda _ _ _) = do
      counter <- get
      put $ counter + 1
      let clses = closures whole
      return $ Call (Var Nothing $ "lambda__" ++ show counter) (map (\(nm,ty) -> Var (Just ty) nm) clses)
    replaceLambdasE x = passRecurseM replaceLambdasE x

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
          (TypeVar Nothing nm) -> TypeVar (fmap typeAlias (lookup nm typetbl)) nm
          x -> typeRecurse typeAlias x
    typeAliases' (FuncDef name args ty ex) =
      Just $ FuncDef name [(nm,typeAlias ty)|(nm,ty)<-args] (typeAlias ty) (passRecurseT typeAlias ex)
    typeAliases' (Extern nm ty) = Just $ Extern nm ty
    typeAliases' (TypeDef nm ty) = Nothing

--instantiates templates for functions and externs
removeTemplates decls = filter isnttemplate $ removeTemplates' [] [] decls
  where
    isnttemplate (Template _ _) = False
    isnttemplate _ = True

--what have I done...
--TODO: FIX THIS!!!
removeTemplates' already alreadytys decls =
  let next = newdefns ++ (map (rmtmptyvars . rmtmpvars) decls)
    in if newdefns == [] then next
        else removeTemplates' (usetbl ++ already) (tyusetbl ++ alreadytys) next
  where
    --stringify template vars
    rmtmpvars (FuncDef nm args ret ex) = FuncDef nm args ret $ rmtmpvarsE ex
    rmtmpvars w@(TypeDef _ _) = w
    rmtmpvars w@(Extern _ _) = w
    rmtmpvars w@(Template _ _) = w

    rmtmpvarsE (TemplateVar nm tys) = Var Nothing (mangle nm tys)
    rmtmpvarsE x = passRecurse rmtmpvarsE x

    rmtmptyvars (FuncDef nm args ret ex) =
      FuncDef nm [(nm,rmtmptyvarsT ty) | (nm,ty) <- args] (rmtmptyvarsT ret) (passRecurseT rmtmptyvarsT ex)
    rmtmptyvars (TypeDef nm ty) = TypeDef nm (rmtmptyvarsT ty)
    rmtmptyvars (Extern nm ty) = Extern nm (rmtmptyvarsT ty)
    rmtmptyvars w@(Template _ _) = w

    rmtmptyvarsT (TemplateType nm tys) = TypeVar Nothing (mangle nm tys)
    rmtmptyvarsT x = typeRecurse rmtmptyvarsT x

    newdefns = map getdecl usetbl ++ map gettydecl tyusetbl
    -- map of string names to declarations
    defntbl = catMaybes $ map gettempdefn decls
    gettempdefn w@(Template tmpargs decl) =
      case decl of
          (FuncDef nm _ _ _) -> Just (nm,w)
          (Extern nm _) -> Just (nm,w)
          _ -> Nothing
    gettempdefn _ = Nothing
    --list of names which must be instantiated with types tys
    usetbl = filter (\x -> not $ x `elem` already) $ nub $ concat $ map gettmpuses decls
    gettmpuses (FuncDef nm args ret ex) = gettmpusesE ex
    gettmpuses (TypeDef _ _) = []
    gettmpuses (Extern _ _) = []
    gettmpuses (Template _ _) = []

    gettmpusesE (TemplateVar nm tys) = [(nm,tys)]
    gettmpusesE x = passAccumulate gettmpusesE x

    --list of template defns of types
    tydefntbl = catMaybes $ map gettytempdefn decls
    gettytempdefn w@(Template tmpargs decl) =
      case decl of
        (TypeDef nm _) -> Just (nm,w)
        _ -> Nothing
    gettytempdefn _ = Nothing

    --list of types to instantiate, same as above
    tyusetbl = filter (\x -> not $ x `elem` alreadytys) $ nub $ concat $ map gettytmpuses decls
    gettytmpuses (FuncDef nm args ret ex) = (passAccumulateT gettytmpusesT ex) ++ concat (map (gettytmpusesT . snd) args) ++ gettytmpusesT ret
    gettytmpuses (TypeDef _ ty) = gettytmpusesT ty
    gettytmpuses (Extern _ ty) = gettytmpusesT ty
    gettytmpuses (Template _ _) = []

    gettytmpusesT (TemplateType nm tys) = (nm,tys):(concat $ map gettytmpusesT tys)
    gettytmpusesT x = typeAccumulate gettytmpusesT x


    --now we proceed to instantiate the used templates
    getdecl (nm,tys) =
      case lookup nm defntbl of
        Nothing -> error $ "Could not find template " ++ nm
        (Just (Template tpargs decl)) ->
          if length tys /= length tpargs then
            error $ "Application of template " ++ nm ++ " incorrect args #..."
          else
            let
              tempvartbl = zip tpargs tys
              typeTemplate w@(TypeVar Nothing nm) =  maybe w id (lookup nm tempvartbl)
              typeTemplate x = typeRecurse typeTemplate x

              typeTemplates (FuncDef name args ty ex) =
                FuncDef (mangle name tys)  [(nm,typeTemplate ty)|(nm,ty)<-args] (typeTemplate ty) (passRecurseT typeTemplate ex)
              typeTemplates (Extern name ty) =
                Extern (mangle name tys) (typeTemplate ty)
            in typeTemplates decl

    gettydecl (nm,tys) =
      case lookup nm tydefntbl of
        Nothing -> error $ "Could not find template " ++ nm
        (Just (Template tpargs decl)) ->
          if length tys /= length tpargs then
            error $ "Application of template " ++ nm ++ " incorrect arg #..."
          else
            let
              tempvartbl = zip tpargs tys
              typeTemplate w@(TypeVar Nothing nm) = maybe w id (lookup nm tempvartbl)
              typeTemplate x = typeRecurse typeTemplate x

              typeTemplates (TypeDef name ty) =
                TypeDef (mangle name tys) (typeTemplate ty)
            in typeTemplates decl

removeData decls = newdefns ++ (filter isntdata decls)
  where
    isntdata (Data _ _) = False
    isntdata (Template _ (Data _ _)) = False
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
    getnewdefns (Template tynms stuff) =
      map (Template tynms) $ getnewdefns stuff
    getnewdefns _ = []

runPasses = validate . removeLambdas . typeArgs . typeGlobals . typeAliases . removeTemplates . removeData

resolveImports' :: String -> [String] -> [Declaration] -> IO [Declaration]
resolveImports' root already decls =
  let importNames = ["std/prelude.hask"] ++ (catMaybes $ map getImport decls)
      getImport (Import nm) = Just $ nm ++ ".hask"
      getImport _ = Nothing
      newImports = filter (\x -> not $ x `elem` already) importNames
  in if newImports == [] then
      return decls
      else do
        newDecls <- flip mapM newImports $ \imprt -> do
          text <- readFile $ root ++ imprt
          case parsed text of
            (Left bad) -> do
              putStrLn (show bad)
              error $ "Parse error in imported module " ++ imprt
            (Right good) -> return good
        resolveImports' root (already ++ newImports) (decls ++ concat newDecls)

resolveImports :: String -> [Declaration] -> IO [Declaration]
resolveImports root decls = fmap removeImports $ resolveImports' root [] decls
  where
    removeImports ((Import _):xs) = removeImports xs
    removeImports (x:xs) = x:(removeImports xs)
    removeImports [] = []
