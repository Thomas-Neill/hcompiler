; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @f(i32 %x, i32 %y, i32 %z) {
  %1 = mul i32 %x, %y
  %2 = mul i32 %1, %z
  ret i32 %2
}

define i32 @main() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i32 (i32, i32, i32)*, i32 }* getelementptr ({ i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32 (i32, i32, i32)*, i32 }*
  %3 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %2, i32 0, i32 0
  store i32 (i32, i32, i32)* @f, i32 (i32, i32, i32)** %3
  %4 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %2, i32 0, i32 1
  store i32 0, i32* %4
  %5 = call i8* @malloc(i32 ptrtoint ({ i32 (i32, i32, i32)*, i32 }* getelementptr ({ i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* null, i32 1) to i32))
  %6 = bitcast i8* %5 to { i32 (i32, i32, i32)*, i32 }*
  %7 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %6, i32 0, i32 0
  store i32 (i32, i32, i32)* @f, i32 (i32, i32, i32)** %7
  %8 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %6, i32 0, i32 1
  store i32 1, i32* %8
  %9 = call i8* @malloc(i32 ptrtoint ({ i32 (i32, i32, i32)*, i32, i32 }* getelementptr ({ i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* null, i32 1) to i32))
  %10 = bitcast i8* %9 to { i32 (i32, i32, i32)*, i32, i32 }*
  %11 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %6, i32 0, i32 0
  %12 = load i32 (i32, i32, i32)*, i32 (i32, i32, i32)** %11
  %13 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 0
  store i32 (i32, i32, i32)* %12, i32 (i32, i32, i32)** %13
  %14 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %6, i32 0, i32 1
  %15 = load i32, i32* %14
  %16 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 1
  store i32 %15, i32* %16
  %17 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 2
  store i32 2, i32* %17
  %18 = bitcast { i32 (i32, i32, i32)*, i32 }* %6 to i8*
  call void @free(i8* %18)
  %19 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %2, i32 0, i32 1
  %20 = load i32, i32* %19
  %21 = getelementptr { i32 (i32, i32, i32)*, i32 }, { i32 (i32, i32, i32)*, i32 }* %2, i32 0, i32 0
  %22 = load i32 (i32, i32, i32)*, i32 (i32, i32, i32)** %21
  %23 = bitcast { i32 (i32, i32, i32)*, i32 }* %2 to i8*
  call void @free(i8* %23)
  %24 = call i32 %22(i32 %20, i32 100, i32 200)
  %25 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 1
  %26 = load i32, i32* %25
  %27 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 2
  %28 = load i32, i32* %27
  %29 = getelementptr { i32 (i32, i32, i32)*, i32, i32 }, { i32 (i32, i32, i32)*, i32, i32 }* %10, i32 0, i32 0
  %30 = load i32 (i32, i32, i32)*, i32 (i32, i32, i32)** %29
  %31 = bitcast { i32 (i32, i32, i32)*, i32, i32 }* %10 to i8*
  call void @free(i8* %31)
  %32 = call i32 %30(i32 %26, i32 %28, i32 3)
  %33 = add i32 %24, %32
  ret i32 %33
}
