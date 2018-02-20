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
import System.Process
import System.FilePath

main = do
  args <- getArgs
  line <- case args of
    [] -> getLine
    [fname] -> readFile fname
  let ast' = parsed line
  case ast' of
    (Left err) -> die (show err)
    (Right ast'') -> do
      ast''' <- resolveImports (case args of
            [] -> "./"
            [fname] -> dropFileName fname
          ) ast''
      let ast = runPasses ast'''
      putStrLn "Before passes"
      mapM_ print ast'''
      putStrLn "After passes"
      mapM_ print ast
      compile (workingMod $ execState
        (do
          declareGlobals $ catMaybes $ map typeofDecl ast
          mapM_ declCodegen ast)
        (genCompilerState "???" "stdin")) "out.ll"
      callCommand "clang-5.0 out.ll libh/*.c -lm"
