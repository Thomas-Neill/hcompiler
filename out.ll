; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32* @add(i32* %x, i32* %y) {
  %1 = load i32, i32* %x
  %2 = load i32, i32* %y
  %3 = add i32 %1, %2
  %4 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %5 = bitcast i8* %4 to i32*
  store i32 %3, i32* %5
  ret i32* %5
}

define i32* @go() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i8*, i8, i8** }*
  %3 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  store i8* bitcast (i32* (i32*, i32*)* @add to i8*), i8** %3
  %4 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  store i8 0, i8* %4
  %5 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  store i8** null, i8*** %5
  %6 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %7 = bitcast i8* %6 to i32*
  store i32 10, i32* %7
  %8 = bitcast i32* %7 to i8*
  %9 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %10 = bitcast i8* %9 to { i8*, i8, i8** }*
  %11 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 0
  %12 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %13 = load i8*, i8** %12
  store i8* %13, i8** %11
  %14 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  %15 = load i8, i8* %14
  %16 = add i8 %15, 1
  %17 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 1
  store i8 %16, i8* %17
  %18 = zext i8 %16 to i32
  %19 = mul i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32), %18
  %20 = call i8* @malloc(i32 %19)
  %21 = bitcast i8* %20 to i8**
  %22 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 2
  store i8** %21, i8*** %22
  %23 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %24 = load i8**, i8*** %23
  switch i8 %15, label %38 [
    i8 0, label %25
    i8 1, label %27
  ]

; <label>:25:                                     ; preds = %0
  %26 = getelementptr i8*, i8** %21, i32 0
  store i8* %8, i8** %26
  br label %32

; <label>:27:                                     ; preds = %0
  %28 = getelementptr i8*, i8** %24, i32 0
  %29 = load i8*, i8** %28
  %30 = getelementptr i8*, i8** %21, i32 0
  store i8* %29, i8** %30
  %31 = getelementptr i8*, i8** %21, i32 1
  store i8* %8, i8** %31
  br label %32

; <label>:32:                                     ; preds = %27, %25
  %33 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %34 = bitcast i8* %33 to i32*
  store i32 20, i32* %34
  %35 = bitcast i32* %34 to i8*
  %36 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 1
  %37 = load i8, i8* %36
  switch i8 %37, label %63 [
    i8 0, label %39
    i8 1, label %46
  ]

; <label>:38:                                     ; preds = %0
  unreachable

; <label>:39:                                     ; preds = %32
  %40 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 0
  %41 = load i8*, i8** %40
  %42 = bitcast i8* %41 to i32* (i8*)*
  %43 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 2
  %44 = load i8**, i8*** %43
  %45 = call i32* %42(i8* %35)
  br label %55

; <label>:46:                                     ; preds = %32
  %47 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 0
  %48 = load i8*, i8** %47
  %49 = bitcast i8* %48 to i32* (i8*, i8*)*
  %50 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 2
  %51 = load i8**, i8*** %50
  %52 = getelementptr i8*, i8** %51, i32 0
  %53 = load i8*, i8** %52
  %54 = call i32* %49(i8* %53, i8* %35)
  br label %55

; <label>:55:                                     ; preds = %46, %39
  %56 = phi i32* [ %45, %39 ], [ %54, %46 ]
  %57 = load i32, i32* %56
  %58 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %59 = bitcast i8* %58 to i32*
  store i32 0, i32* %59
  %60 = bitcast i32* %59 to i8*
  %61 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 1
  %62 = load i8, i8* %61
  switch i8 %62, label %86 [
    i8 0, label %64
    i8 1, label %71
  ]

; <label>:63:                                     ; preds = %32
  unreachable

; <label>:64:                                     ; preds = %55
  %65 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 0
  %66 = load i8*, i8** %65
  %67 = bitcast i8* %66 to i32* (i8*)*
  %68 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 2
  %69 = load i8**, i8*** %68
  %70 = call i32* %67(i8* %60)
  br label %80

; <label>:71:                                     ; preds = %55
  %72 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 0
  %73 = load i8*, i8** %72
  %74 = bitcast i8* %73 to i32* (i8*, i8*)*
  %75 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %10, i32 0, i32 2
  %76 = load i8**, i8*** %75
  %77 = getelementptr i8*, i8** %76, i32 0
  %78 = load i8*, i8** %77
  %79 = call i32* %74(i8* %78, i8* %60)
  br label %80

; <label>:80:                                     ; preds = %71, %64
  %81 = phi i32* [ %70, %64 ], [ %79, %71 ]
  %82 = load i32, i32* %81
  %83 = add i32 %57, %82
  %84 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %85 = bitcast i8* %84 to i32*
  store i32 %83, i32* %85
  ret i32* %85

; <label>:86:                                     ; preds = %55
  unreachable
}
