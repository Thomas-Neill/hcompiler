module Emit where

import LLVM.AST as AST

import LLVM.Module
import LLVM.Context


compile :: AST.Module -> String -> IO ()
compile ast outfile = do
  withContext $ \ctx ->
    withModuleFromAST ctx ast $ \mod ->
      writeLLVMAssemblyToFile (File outfile) mod
