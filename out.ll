; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @lambda__0(i32 %g, i32 %m, i32 %x) {
  %1 = mul i32 %g, %x
  %2 = add i32 %1, %m
  ret i32 %2
}

define i32 @main() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i32 (i32, i32, i32)*, i32, i32 }* getelementptr ({ i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32 (i32, i32, i32)*, i32, i32 }*
  %3 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 0
  store i32 (i32, i32, i32)* @lambda__0, i32 (i32, i32, i32)** %3
  %4 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 1
  store i32 3, i32* %4
  %5 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 2
  store i32 20, i32* %5
  %6 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 1
  %7 = load i32, i32* %6
  %8 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 2
  %9 = load i32, i32* %8
  %10 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %2, i32 0, i32 0
  %11 = load i32 (i32, i32, i32)*, i32 (i32, i32, i32)** %10
  %12 = bitcast { i32 (i32, i32, i32)*, i32, i32 }* %2 to i8*
  call void @free(i8* %12)
  %13 = call i32 %11(i32 %7, i32 %9, i32 10)
  ret i32 %13
}
