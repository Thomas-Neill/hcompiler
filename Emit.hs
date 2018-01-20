module Emit where

import LLVM.AST as AST

import LLVM.Module
import LLVM.Context
import LLVM.Pretty (ppllvm)

compile :: AST.Module -> String -> IO ()
compile ast outfile = do
  --putStr $ (read.show) $ ppllvm ast
  withContext $ \ctx ->
    withModuleFromAST ctx ast $ \mod ->
      writeLLVMAssemblyToFile (File outfile) mod
