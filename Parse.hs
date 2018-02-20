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

name = many1 varChar

argsTypes = char '(' *> (((,) <$> (pad $ name) <*> (char ':' *> pad typ)) `sepBy` char ',') <* char ')'

typ = choice [
    try $ (string "int") *> pure HInt,
    try $ (string "float") *> pure HFloat,
    try $ (string "bool") *> pure HBool,
    try $ TemplateType <$> name <*> (char '<' *> spaces *> typ `sepBy` (pad $ char ',') <* spaces <* char '>'),
    TypeVar Nothing <$> name,
    Func <$> (char '(' *> spaces *> char '(' *> spaces *> typ `sepBy` (pad $ char ',')) <*>
             (spaces *> char ')' *> spaces *> string "->" *> spaces *> typ <* spaces <* char ')'),
    Structure <$> try (char '{' *> spaces *>
      ((,) <$> name <*> (spaces *> char ':' *> spaces *> typ))
        `sepBy` (pad $ char ',')
      <* spaces <* char '}'),
    Union <$> (char '{' *> spaces *>
      ((,) <$> name <*> (spaces *> char ':' *> spaces *> typ))
        `sepBy` (pad $ char '|')
      <* spaces <* char '}')
  ]

primary' = pad $ choice [
    boolit,
    try $ TemplateVar <$> name <*> (spaces *> char '<' *> spaces *> typ `sepBy` (pad $ char ',') <* spaces <* char '>'),
    Var Nothing <$> name,
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
      (\prop acc -> Access acc prop) <$> (char '.' *> name),
      (\args acc -> Call acc args) <$> (char '(' *> (expr `sepBy` (pad $ char ',')) <* char ')')
    ])

lambda = Lambda <$>
  (char '{' *> spaces *> string "lambda" *> spaces *> argsTypes) <*>
  (spaces *> string "->" *> spaces *> typ) <*>
  (spaces *> char '=' *> expr <* char '}')

struct = StructLiteral <$>
  (char '{' *> spaces *>
    ((,) <$> name <*> (spaces *> char '=' *> spaces *> expr))
      `sepBy` (pad $ char ',')
   <* spaces <* char '}')


if' = If <$> (try (string "if") *> spaces *> char '{' *> expr) <*>
             (char '}' *> spaces *> string "then" *> spaces *> char '{' *> expr) <*>
             (char '}' *> spaces *> string "else" *> spaces *> char '{' *> expr <* char '}')

let' = Let <$> (try (string "let") *> spaces *> char '{' *> assignment `sepBy` char ',') <*>
               (spaces *> char '}' *> spaces *> string "in" *> spaces *> char '{' *> expr <* char '}')
    where
      assignment = (,) <$> (spaces *> name <* spaces <* char '=') <*> expr

cast = Cast <$> (try (string "cast<") *> spaces *> typ) <*>
                (char '>' *> spaces *> char '(' *> expr <* char ')')

unionize = Unionize <$> (try (string "unionize<") *> spaces *> typ) <*>
                (char '>' *> spaces *> char '(' *> spaces *> name) <*>
                (spaces *> char '=' *> expr <* char ')')

case' = Case <$> (try (string "case") *> spaces *> char '<' *>  spaces *>typ) <*>
          (char '>' *> spaces *> char '{' *> expr) <*>
          (char '}' *> spaces *> string "of" *> spaces *> char '{' *> spaces *>
            many1 ((,,) <$> name <*>
              (spaces *> string ":" *> spaces *> name) <*>
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
      (try (string "extern") *> spaces1 *> name) <*>
      (spaces *> char ':' *> spaces *> typ <* spaces),
    TypeDef <$>
      (try (string "type") *> spaces1 *> name) <*>
      (spaces *> char '=' *> spaces *> typ <* spaces),
    Data <$>
      (try (string "data") *> spaces1 *> name) <*>
      (spaces *> char '=' *> spaces *> ((,) <$> name <*> (spaces1 *> typ)) `sepBy` (pad $ char '|')),
    Template <$>
      (try (string "template") *> spaces *> char '<' *> spaces *> name `sepBy` (pad $ char ',') <* spaces <* char '>') <*>
      (spaces *> decl),
    Import <$>
      (try (string "import") *> spaces *> many1 (oneOf ("/" ++ ['a'..'z'] ++ ['A'..'Z'])) <* spaces),
    FuncDef <$>
      name <*>
      (spaces *> argsTypes) <*>
      (spaces *> string "->" *> spaces *> typ) <*>
      (spaces *> char '=' *> spaces *> expr)
  ]


parsed :: String -> Either ParseError [Declaration]
parsed str = parse (many (decl <* char ';' <* spaces) <* eof) "stdin" str
