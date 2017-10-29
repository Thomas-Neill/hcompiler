module Emit where

import LLVM.AST as AST

import LLVM.Module
import LLVM.Internal.Context


compile :: AST.Module -> String -> IO ()
compile ast outfile =
  withContext $ \ctx ->
    withModuleFromAST ctx ast $ \mod ->
      writeLLVMAssemblyToFile (File outfile) mod
