module Util where

resolve' :: [[(String,a)]] -> String -> Maybe a
resolve' [] s = Nothing
resolve' (e:es) s = case lookup s e of
  (Just result) -> Just result
  Nothing -> resolve' es s

resolve :: [[(String,a)]] -> String -> a
resolve e s = maybe (error $ "Key " ++ s ++ " does not exist!") id (resolve' e s)
