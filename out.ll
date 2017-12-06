; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @lambda__0(i32 %x, i32 %y) {
  %1 = add i32 %x, %y
  ret i32 %1
}

define i32 @main() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i32 (i32, i32)*, i32 }* getelementptr ({ i32 (i32, i32)*, i32 }, { i32 (i32, i32)*, i32 }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32 (i32, i32)*, i32 }*
  %3 = getelementptr { i32 (i32, i32)*, i32 }, { i32 (i32, i32)*, i32 }* %2, i32 0, i32 0
  store i32 (i32, i32)* @lambda__0, i32 (i32, i32)** %3
  %4 = getelementptr { i32 (i32, i32)*, i32 }, { i32 (i32, i32)*, i32 }* %2, i32 0, i32 1
  store i32 5, i32* %4
  %5 = getelementptr { i32 (i32, i32)*, i32 }, { i32 (i32, i32)*, i32 }* %2, i32 0, i32 1
  %6 = load i32, i32* %5
  %7 = getelementptr { i32 (i32, i32)*, i32 }, { i32 (i32, i32)*, i32 }* %2, i32 0, i32 0
  %8 = load i32 (i32, i32)*, i32 (i32, i32)** %7
  %9 = bitcast { i32 (i32, i32)*, i32 }* %2 to i8*
  call void @free(i8* %9)
  %10 = call i32 %8(i32 %6, i32 5)
  ret i32 %10
}
