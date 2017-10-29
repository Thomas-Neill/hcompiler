module Util where

resolve :: [[(String,a)]] -> String -> a
resolve [] s = error $ "Name '" ++ s ++ "' doesn't exist!"
resolve (e:es) s = case lookup s e of
  (Just result) -> result
  Nothing -> resolve es s
