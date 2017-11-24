import LLVMM
import Codegen
import Parse
import Emit
import Control.Monad.State
import LLVM.AST
import AST
import Data.Maybe
import Passes
import System.Environment

main = do
  args <- getArgs
  line <- case args of
    [] -> getLine
    [fname] -> readFile fname
  let ast' = parsed line
  let (Right ast'') = ast'
      ast = runPasses ast''
  mapM print ast''
  mapM print ast
  compile (workingMod $ execState
    (do
      declareGlobals $ map typeofDecl ast
      mapM_ declCodegen ast)
    (genCompilerState "???" "stdin")) "out.ll"
