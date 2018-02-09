module Parse where

import Text.ParserCombinators.Parsec
import AST
import Data.Maybe

spaces1 = many1 space

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

varChar = oneOf $ ['a'..'z'] ++ ['A'..'Z']

argsTypes = char '(' *> (((,) <$> (pad $ many1 varChar) <*> (char ':' *> pad typ)) `sepBy` char ',') <* char ')'

var = Var Nothing <$> many1 varChar

typ = choice [
    try $ (string "int") *> pure HInt,
    try $ (string "float") *> pure HFloat,
    try $ (string "bool") *> pure HBool,
    TypeVar Nothing <$> many1 varChar,
    Func <$> (char '(' *> spaces *> char '(' *> spaces *> typ `sepBy` (pad $ char ',')) <*>
             (spaces *> char ')' *> spaces *> string "->" *> spaces *> typ <* spaces <* char ')'),
    Structure <$> try (char '{' *> spaces *>
      ((,) <$> (many1 varChar) <*> (spaces *> char ':' *> spaces *> typ))
        `sepBy` (pad $ char ',')
      <* spaces <* char '}'),
    Union <$> (char '{' *> spaces *>
      ((,) <$> (many1 varChar) <*> (spaces *> char ':' *> spaces *> typ))
        `sepBy` (pad $ char '|')
      <* spaces <* char '}')
  ]

primary' = pad $ choice [
    boolit,
    var,
    try double,
    int,
    char '(' *> expr <* char ')',
    try lambda,
    struct
  ]

primary = do
  val <- primary'
  foldl (\acc x-> x acc) val <$> (many $
    choice [
      (\prop acc -> Access acc prop) <$> (char '.' *> many1 varChar),
      (\args acc -> Call acc args) <$> (char '(' *> (expr `sepBy` (pad $ char ',')) <* char ')')
    ])

lambda = Lambda <$>
  (char '{' *> spaces *> string "lambda" *> spaces *> argsTypes) <*>
  (spaces *> string "->" *> spaces *> typ) <*>
  (spaces *> char '=' *> expr <* char '}')

struct = StructLiteral <$>
  (char '{' *> spaces *>
    ((,) <$> (many1 varChar) <*> (spaces *> char '=' *> spaces *> expr))
      `sepBy` (pad $ char ',')
   <* spaces <* char '}')


if' = If <$> (try (string "if") *> spaces *> char '{' *> expr) <*>
             (char '}' *> spaces *> string "then" *> spaces *> char '{' *> expr) <*>
             (char '}' *> spaces *> string "else" *> spaces *> char '{' *> expr <* char '}')

let' = Let <$> (try (string "let") *> spaces *> char '{' *> assignment `sepBy` char ',') <*>
               (spaces *> char '}' *> spaces *> string "in" *> spaces *> char '{' *> expr <* char '}')
    where
      assignment = (,) <$> (spaces *> many1 varChar <* spaces <* char '=') <*> expr

cast = Cast <$> (try (string "cast<") *> spaces *> typ) <*>
                (char '>' *> spaces *> char '(' *> expr <* char ')')

unionize = Unionize <$> (try (string "unionize<") *> spaces *> typ) <*>
                (char '>' *> spaces *> char '(' *> spaces *> many1 varChar) <*>
                (spaces *> char '=' *> expr <* char ')')

case' = Case <$> (try (string "case") *> spaces *> char '<' *>  spaces *>typ) <*>
          (char '>' *> spaces *> char '{' *> expr) <*>
          (char '}' *> spaces *> string "of" *> spaces *> char '{' *> spaces *>
            many1 ((,,) <$> (many1 varChar) <*>
              (spaces *> string ":" *> spaces *> many1 varChar) <*>
              (spaces *> char '=' *> expr <* char ';' <* spaces)) <* spaces <* char '}')

special = pad $ choice [if',let',cast,unionize,case',primary]

mkBinLevel :: Parser Expr -> [(String,BinOp)] -> Parser Expr
mkBinLevel prev opmap = prev `chainl1` op
  where
    op = (do
      str <- choice $ fmap (try . string . fst) opmap
      return . Binary . fromJust $ lookup str opmap)

factor = mkBinLevel special [("*",Mul),("/",Div)]
addition = mkBinLevel factor [("+",Add),("-",Sub)]
comparison = mkBinLevel addition [("==",Equal),("/=",Inequal),("<=",LEqual),(">=",GrEqual),(">",Greater),("<",Less)]
and' = mkBinLevel comparison [("&&",And)]
or' = mkBinLevel and' [("||",Or)]
expr = or'

decl = pad $ choice [
    Extern <$>
      (try (string "extern") *> spaces1 *> many1 varChar) <*>
      (spaces *> char ':' *> spaces *> typ <* spaces),
    TypeDef <$>
      (try (string "type") *> spaces1 *> many1 varChar) <*>
      (spaces *> char '=' *> spaces *> typ <* spaces),
    Data <$>
      (try (string "data") *> spaces1 *> many1 varChar) <*>
      (spaces *> char '=' *> spaces *> ((,) <$> many1 varChar <*> (spaces1 *> typ)) `sepBy` (pad $ char '|')),
    FuncDef <$>
      (many1 varChar) <*>
      (spaces *> argsTypes) <*>
      (spaces *> string "->" *> spaces *> typ) <*>
      (spaces *> char '=' *> spaces *> expr)
  ]


parsed :: String -> Either ParseError [Declaration]
parsed str = parse (many (decl <* char ';' <* spaces) <* eof) "stdin" str
