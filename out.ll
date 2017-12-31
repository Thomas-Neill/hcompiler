; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @main() {
  %1 = call { i32 }* @f()
  %2 = alloca { i32 }
  %3 = getelementptr { i32 }, { i32 }* %1, i32 0, i32 0
  %4 = load i32, i32* %3
  %5 = getelementptr { i32 }, { i32 }* %2, i32 0, i32 0
  store i32 %4, i32* %5
  %6 = bitcast { i32 }* %1 to i8*
  call void @free(i8* %6)
  %7 = getelementptr { i32 }, { i32 }* %2, i32 0, i32 0
  %8 = load i32, i32* %7
  ret i32 %8
}

define { i32 }* @f() {
  %1 = alloca { i32 }
  %2 = getelementptr { i32 }, { i32 }* %1, i32 0, i32 0
  store i32 100, i32* %2
  %3 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %4 = bitcast i8* %3 to { i32 }*
  %5 = getelementptr { i32 }, { i32 }* %1, i32 0, i32 0
  %6 = load i32, i32* %5
  %7 = getelementptr { i32 }, { i32 }* %4, i32 0, i32 0
  store i32 %6, i32* %7
  ret { i32 }* %4
}
