module Parse where

import Text.ParserCombinators.Parsec
import AST
import Data.Maybe

double :: Parser Expr
double = FLit . read <$> ((++) <$> many1 digit <*> ((:) <$> char '.' <*> many1 digit))

int :: Parser Expr
int = ILit . read <$> many1 digit

boolit = choice [
    try (string "true") *> (pure $ BLit True),
    try (string "false") *> (pure $ BLit False)
  ]

pad :: Parser a -> Parser a
pad p = spaces *> p <* spaces

varChar = oneOf "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCCVBNM"

var = Var <$> many1 varChar

typ = choice [
    string "int" *> pure HInt,
    string "float" *> pure HFloat,
    string "bool" *> pure HBool,
    Func <$> (char '(' *> spaces *> char '[' *> typ `sepBy` (pad $ char ',')) <*>
             (spaces *> char ']' *> spaces *> string "->" *> spaces *> typ <* spaces <* char ')')
  ]

primary = pad $ choice [
    boolit,
    var,
    try double,
    int,
    char '(' *> expr <* char ')'
  ]

if' = If <$> (try (string "if") *> spaces *> char '[' *> expr) <*>
             (char ']' *> spaces *> string "then" *> spaces *> char '[' *> expr) <*>
             (char ']' *> spaces *> string "else" *> spaces *> char '[' *> expr <* char ']')

let' = Let <$> (try (string "let") *> spaces *> char '[' *> assignment `sepBy` char ',') <*>
               (spaces *> char ']' *> spaces *> string "in" *> spaces *> char '[' *> expr <* char ']')
    where
      assignment = (,) <$> (spaces *> many1 varChar <* spaces <* char '=') <*> expr

call = Call <$> primary <*> (spaces *> try (char '[') *> spaces *> expr `sepBy` (pad $ char ',') <* char ']')

special = pad $ choice [if',let',try call,primary]

mkBinLevel :: Parser Expr -> [(String,BinOp)] -> Parser Expr
mkBinLevel prev opmap = prev `chainl1` op
  where
    op = do
      str <- choice $ fmap (string . fst) opmap
      return . Binary . fromJust $ lookup str opmap

factor = mkBinLevel special [("*",Mul),("/",Div)]
addition = mkBinLevel factor [("+",Add),("-",Sub)]
comparison = mkBinLevel addition [("==",Equal),("/=",Inequal),(">",Greater),("<",Less)]

expr = comparison

decl = pad $ choice [
    FuncDef <$>
      (many1 varChar) <*>
      (spaces *> char '[' *> ((,) <$> (pad $ many1 varChar) <*> (char ':' *> pad typ)) `sepBy` char ',') <*>
      (char ']' *> spaces *> string "->" *> spaces *> typ) <*>
      (spaces *> char '=' *> spaces *> expr)
  ]


parsed :: String -> Either ParseError [Declaration]
parsed str = parse (many (decl <* char ';' <* spaces) <* eof) "stdin" str
