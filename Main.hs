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
import System.Exit

main = do
  args <- getArgs
  line <- case args of
    [] -> getLine
    [fname] -> readFile fname
  let ast' = parsed line
  case ast' of
    (Left err) -> die (show err)
    (Right ast'') -> do
      let ast = runPasses ast''
      print ast''
      putStrLn "Passed: "
      print ast
      compile (workingMod $ execState
        (do
          declareGlobals $ map typeofDecl ast
          mapM_ declCodegen ast)
        (genCompilerState "???" "stdin")) "out.ll"
