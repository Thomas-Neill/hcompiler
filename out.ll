; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @mul({ i32, i32 }* %x) {
  %1 = getelementptr { i32, i32 }, { i32, i32 }* %x, i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = getelementptr { i32, i32 }, { i32, i32 }* %x, i32 0, i32 1
  %4 = load i32, i32* %3
  %5 = mul i32 %2, %4
  ret i32 %5
}

define i32 @main() {
  %1 = call i8* @malloc(i32 mul nuw (i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32), i32 2))
  %2 = bitcast i8* %1 to { i32, i32 }*
  %3 = getelementptr { i32, i32 }, { i32, i32 }* %2, i32 0, i32 0
  store i32 5, i32* %3
  %4 = getelementptr { i32, i32 }, { i32, i32 }* %2, i32 0, i32 1
  store i32 6, i32* %4
  %5 = call i32 @mul({ i32, i32 }* %2)
  ret i32 %5
}
