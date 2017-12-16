; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define { i32 }* @mul(i32 %a, i32 %b) {
  %1 = alloca { i32 }
  %2 = mul i32 %a, %b
  %3 = getelementptr { i32 }, { i32 }* %1, i32 0, i32 0
  store i32 %2, i32* %3
  %4 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %5 = bitcast i8* %4 to { i32 }*
  %6 = getelementptr { i32 }, { i32 }* %1, i32 0, i32 0
  %7 = load i32, i32* %6
  %8 = getelementptr { i32 }, { i32 }* %5, i32 0, i32 0
  store i32 %7, i32* %8
  ret { i32 }* %5
}

define i32 @main() {
  %1 = alloca { { i32 }* (i32, i32)*, i32 }
  %2 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 0
  store { i32 }* (i32, i32)* @mul, { i32 }* (i32, i32)** %2
  %3 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 1
  store i32 0, i32* %3
  %4 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 1
  %5 = load i32, i32* %4
  %6 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 0
  %7 = load { i32 }* (i32, i32)*, { i32 }* (i32, i32)** %6
  %8 = call { i32 }* %7(i32 %5, i32 10)
  %9 = alloca { i32 }
  %10 = getelementptr { i32 }, { i32 }* %8, i32 0, i32 0
  %11 = load i32, i32* %10
  %12 = getelementptr { i32 }, { i32 }* %9, i32 0, i32 0
  store i32 %11, i32* %12
  %13 = bitcast { i32 }* %8 to i8*
  call void @free(i8* %13)
  %14 = getelementptr { i32 }, { i32 }* %9, i32 0, i32 0
  %15 = load i32, i32* %14
  %16 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 1
  %17 = load i32, i32* %16
  %18 = getelementptr { { i32 }* (i32, i32)*, i32 }, { { i32 }* (i32, i32)*, i32 }* %1, i32 0, i32 0
  %19 = load { i32 }* (i32, i32)*, { i32 }* (i32, i32)** %18
  %20 = call { i32 }* %19(i32 %17, i32 20)
  %21 = alloca { i32 }
  %22 = getelementptr { i32 }, { i32 }* %20, i32 0, i32 0
  %23 = load i32, i32* %22
  %24 = getelementptr { i32 }, { i32 }* %21, i32 0, i32 0
  store i32 %23, i32* %24
  %25 = bitcast { i32 }* %20 to i8*
  call void @free(i8* %25)
  %26 = getelementptr { i32 }, { i32 }* %21, i32 0, i32 0
  %27 = load i32, i32* %26
  %28 = add i32 %15, %27
  ret i32 %28
}
