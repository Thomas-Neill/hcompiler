module Util where

resolve' :: [[(String,a)]] -> String -> Maybe a
resolve' [] s = Nothing
resolve' (e:es) s = case lookup s e of
  (Just result) -> Just result
  Nothing -> resolve' es s

resolve :: [[(String,a)]] -> String -> a
resolve e s = maybe (error $ "Key " ++ s ++ " does not exist!") id (resolve' e s)

--note, len args != len function as a precon.
--             args  function
commonArgs :: (Eq a) => [a] -> [a] -> Int
commonArgs [] _ = 0 -- base case
commonArgs (x:xs) (y:ys) =
  if x /= y then
    error "Invalid types!"
  else
    1 + commonArgs xs ys
