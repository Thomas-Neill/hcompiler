module Traversals where

import AST
import Control.Monad
import Control.Monad.Identity

passRecurseM :: (Monad m) => (Expr -> m Expr) -> (Expr -> m Expr)
passRecurseM p w@(ILit _) = return w
passRecurseM p w@(FLit _) = return w
passRecurseM p w@(BLit _) = return w
passRecurseM p w@(CLit _) = return w
passRecurseM p (Binary op l r) = do
  l' <- p l
  r' <- p r
  return $ Binary op l' r'
passRecurseM p (If c i e) = do
  c' <- p c
  i' <- p i
  e' <- p e
  return $ If c' i' e'
passRecurseM p w@(Var _ _) = return w
passRecurseM p w@(TemplateVar _ _) = return w
passRecurseM p (Let pre ex) = do
  pre' <- forM pre $ \(nm,e) -> do
    e' <- p e
    return (nm,e')
  ex' <- p ex
  return $ Let pre' ex'
passRecurseM p (Call f args) = do
  f' <- p f
  args' <- mapM p args
  return $ Call f' args'
passRecurseM p (Lambda x y ret) = do
  ret' <- p ret
  return $ Lambda x y ret'
passRecurseM p (Access ex k) = do
  ex' <- p ex
  return $ Access ex' k
passRecurseM p (StructLiteral vals) = do
  vals' <- forM vals $ \(nm,e) -> do
    e' <- p e
    return (nm,e')
  return $ StructLiteral vals'
passRecurseM p (Cast ty ex) = do
  ex' <- p ex
  return $ Cast ty ex'
passRecurseM p (Unionize ty nm ex) = do
  ex' <- p ex
  return $ Unionize ty nm ex'
passRecurseM p (Case ty ex css) = do
  ex' <- p ex
  css' <- forM css $ \(nm,cs,e) -> do
    e' <- p e
    return (nm,cs,e')
  return $ Case ty ex' css'

passRecurse :: (Expr -> Expr) -> (Expr -> Expr)
passRecurse p = runIdentity . passRecurseM (return . p)

passAccumulateM :: (Monad m) => (Expr -> m [a]) -> (Expr -> m [a])
passAccumulateM p (ILit _) = return []
passAccumulateM p (FLit _) = return []
passAccumulateM p (BLit _) = return []
passAccumulateM p (CLit _) = return []
passAccumulateM p (Binary op l r) = do
  l' <- p l
  r' <- p r
  return $ l' ++ r'
passAccumulateM p (If c i e) = do
  c' <- p c
  i' <- p i
  e' <- p e
  return $ c' ++ i' ++ e'
passAccumulateM p (Var _ _) = return []
passAccumulateM p (TemplateVar _ _) = return []
passAccumulateM p (Let pre ex) = do
  pre' <- mapM (p . snd) pre
  ex' <- p ex
  return $ concat pre' ++ ex'
passAccumulateM p (Call f args) = do
  f' <- p f
  args' <- mapM p args
  return $ f' ++ concat args'
passAccumulateM p (Lambda x y ret) = do
  ret' <- p ret
  return $ ret'
passAccumulateM p (Access ex k) = do
  ex' <- p ex
  return $ ex'
passAccumulateM p (StructLiteral vals) = do
  vals' <- mapM (p . snd) vals
  return $ concat vals'
passAccumulateM p (Cast ty ex) = do
  ex' <- p ex
  return $ ex'
passAccumulateM p (Unionize ty nm ex) = do
  ex' <- p ex
  return $ ex'
passAccumulateM p (Case ty ex css) = do
  ex' <- p ex
  css' <- mapM (\(nm,cs,e) -> p e) css
  return $ ex' ++ concat css'

passAccumulate :: (Expr -> [a]) -> (Expr -> [a])
passAccumulate p = runIdentity . passAccumulateM (return . p)

typeRecurse :: (Type -> Type) -> (Type -> Type)
typeRecurse p HInt = HInt
typeRecurse p HFloat = HFloat
typeRecurse p HBool = HBool
typeRecurse p HChar = HChar
typeRecurse p (Func tys ty) = Func (map p tys) (p ty)
typeRecurse p (Structure tys) = Structure [(nm,p ty) | (nm,ty) <- tys]
typeRecurse p (Union tys) = Union [(nm,p ty) | (nm,ty) <- tys]
typeRecurse p (TypeVar ty n) = TypeVar (fmap p ty) n
typeRecurse p (TemplateType nm tys) = TemplateType nm (map p tys)

typeAccumulate :: (Type -> [a]) -> (Type -> [a])
typeAccumulate p HInt = []
typeAccumulate p HFloat = []
typeAccumulate p HBool = []
typeAccumulate p HChar = []
typeAccumulate p (Func tys ty) = p ty ++ concat (map p tys)
typeAccumulate p (Structure tys) = concat (map (p . snd) tys)
typeAccumulate p (Union tys) = concat (map (p . snd) tys)
typeAccumulate p (TypeVar ty n) = case ty of
  Nothing -> []
  (Just ty') -> p ty'
typeAccumulate p (TemplateType nm tys) = concat $ map p tys

passRecurseT :: (Type -> Type) -> (Expr -> Expr)
passRecurseT f =
  let
    pass (Var (Just ty) nm) = Var (Just $ f ty) nm
    pass (Lambda args ret ex) = Lambda [(nm,f ty) | (nm,ty) <- args] (f ret) (pass ex)
    pass (Cast ty ex) = Cast (f ty) (pass ex)
    pass (Unionize ty nm ex) = Unionize (f ty) nm (pass ex)
    pass (Case ty ex cases) = Case (f ty) (pass ex) [(nm,cs,pass ex) | (nm,cs,ex) <- cases]
    pass (TemplateVar nm tys) = TemplateVar nm (map f tys)
    pass x = passRecurse pass x
  in pass

passAccumulateT :: (Type -> [a]) -> (Expr -> [a])
passAccumulateT f =
  let
    pass (Var (Just ty) nm) = f ty
    pass (Lambda args ret ex) = f ret ++ concat (map (f . snd) args) ++ pass ex
    pass (Cast ty ex) = f ty ++ pass ex
    pass (Unionize ty nm ex) = f ty ++ pass ex
    pass (Case ty ex cases) = f ty ++ pass ex ++ concat [pass ex | (nm,cs,ex) <- cases]
    pass (TemplateVar nm tys) = concat $ map f tys
    pass x = passAccumulate pass x
  in pass
