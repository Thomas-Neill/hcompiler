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
  print ast'
  let (Right ast'') = ast'
      ast = runPasses ast''
  print ast
  compile (workingMod $ execState
    (do
      declareGlobals $ getDefns ast
      mapM_ declCodegen ast)
    (genCompilerState "???" "stdin")) "out.ll"
