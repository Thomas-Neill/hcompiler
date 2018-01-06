; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @add(i8* %x, i8* %y) {
  %1 = bitcast i8* %x to i32*
  %2 = load i32, i32* %1
  %3 = bitcast i8* %y to i32*
  %4 = load i32, i32* %3
  %5 = add i32 %2, %4
  ret i32 %5
}

define i32 @inc(i8* %x) {
  %1 = bitcast i8* %x to i32*
  %2 = load i32, i32* %1
  %3 = add i32 %2, 1
  ret i32 %3
}

define { i8*, i8, i8** }* @choose(i8* %b) {
  %1 = bitcast i8* %b to i1*
  %2 = load i1, i1* %1
  br i1 %2, label %3, label %9

; <label>:3:                                      ; preds = %0
  %4 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %5 = bitcast i8* %4 to { i8*, i8, i8** }*
  %6 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %5, i32 0, i32 0
  store i8* bitcast (i32 (i8*)* @inc to i8*), i8** %6
  %7 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %5, i32 0, i32 1
  store i8 0, i8* %7
  %8 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %5, i32 0, i32 2
  store i8** null, i8*** %8
  br label %34

; <label>:9:                                      ; preds = %0
  %10 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %11 = bitcast i8* %10 to { i8*, i8, i8** }*
  %12 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 0
  store i8* bitcast (i32 (i8*, i8*)* @add to i8*), i8** %12
  %13 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 1
  store i8 0, i8* %13
  %14 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 2
  store i8** null, i8*** %14
  %15 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %16 = bitcast i8* %15 to i32*
  store i32 1, i32* %16
  %17 = bitcast i32* %16 to i8*
  %18 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %19 = bitcast i8* %18 to { i8*, i8, i8** }*
  %20 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %19, i32 0, i32 0
  %21 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 0
  %22 = load i8*, i8** %21
  store i8* %22, i8** %20
  %23 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 1
  %24 = load i8, i8* %23
  %25 = add i8 %24, 1
  %26 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %19, i32 0, i32 1
  store i8 %25, i8* %26
  %27 = zext i8 %25 to i32
  %28 = mul i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32), %27
  %29 = call i8* @malloc(i32 %28)
  %30 = bitcast i8* %29 to i8**
  %31 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %19, i32 0, i32 2
  store i8** %30, i8*** %31
  %32 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %11, i32 0, i32 2
  %33 = load i8**, i8*** %32
  switch i8 %24, label %44 [
    i8 0, label %36
    i8 1, label %38
  ]

; <label>:34:                                     ; preds = %43, %3
  %35 = phi { i8*, i8, i8** }* [ %5, %3 ], [ %19, %43 ]
  ret { i8*, i8, i8** }* %35

; <label>:36:                                     ; preds = %9
  %37 = getelementptr i8*, i8** %30, i32 0
  store i8* %17, i8** %37
  br label %43

; <label>:38:                                     ; preds = %9
  %39 = getelementptr i8*, i8** %33, i32 0
  %40 = load i8*, i8** %39
  %41 = getelementptr i8*, i8** %30, i32 0
  store i8* %40, i8** %41
  %42 = getelementptr i8*, i8** %30, i32 1
  store i8* %17, i8** %42
  br label %43

; <label>:43:                                     ; preds = %38, %36
  br label %34

; <label>:44:                                     ; preds = %9
  unreachable
}

define i32 @main() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i8*, i8, i8** }*
  %3 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  store i8* bitcast ({ i8*, i8, i8** }* (i8*)* @choose to i8*), i8** %3
  %4 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  store i8 0, i8* %4
  %5 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  store i8** null, i8*** %5
  %6 = call i8* @malloc(i32 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i32))
  %7 = bitcast i8* %6 to i1*
  store i1 true, i1* %7
  %8 = bitcast i1* %7 to i8*
  %9 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  %10 = load i8, i8* %9
  switch i8 %10, label %34 [
    i8 0, label %11
    i8 1, label %18
  ]

; <label>:11:                                     ; preds = %0
  %12 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %13 = load i8*, i8** %12
  %14 = bitcast i8* %13 to { i8*, i8, i8** }* (i8*)*
  %15 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %16 = load i8**, i8*** %15
  %17 = call { i8*, i8, i8** }* %14(i8* %8)
  br label %27

; <label>:18:                                     ; preds = %0
  %19 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %20 = load i8*, i8** %19
  %21 = bitcast i8* %20 to { i8*, i8, i8** }* (i8*, i8*)*
  %22 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %23 = load i8**, i8*** %22
  %24 = getelementptr i8*, i8** %23, i32 0
  %25 = load i8*, i8** %24
  %26 = call { i8*, i8, i8** }* %21(i8* %25, i8* %8)
  br label %27

; <label>:27:                                     ; preds = %18, %11
  %28 = phi { i8*, i8, i8** }* [ %17, %11 ], [ %26, %18 ]
  %29 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %30 = bitcast i8* %29 to i32*
  store i32 10, i32* %30
  %31 = bitcast i32* %30 to i8*
  %32 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %28, i32 0, i32 1
  %33 = load i8, i8* %32
  switch i8 %33, label %63 [
    i8 0, label %35
    i8 1, label %42
  ]

; <label>:34:                                     ; preds = %0
  unreachable

; <label>:35:                                     ; preds = %27
  %36 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %28, i32 0, i32 0
  %37 = load i8*, i8** %36
  %38 = bitcast i8* %37 to i32 (i8*)*
  %39 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %28, i32 0, i32 2
  %40 = load i8**, i8*** %39
  %41 = call i32 %38(i8* %31)
  br label %51

; <label>:42:                                     ; preds = %27
  %43 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %28, i32 0, i32 0
  %44 = load i8*, i8** %43
  %45 = bitcast i8* %44 to i32 (i8*, i8*)*
  %46 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %28, i32 0, i32 2
  %47 = load i8**, i8*** %46
  %48 = getelementptr i8*, i8** %47, i32 0
  %49 = load i8*, i8** %48
  %50 = call i32 %45(i8* %49, i8* %31)
  br label %51

; <label>:51:                                     ; preds = %42, %35
  %52 = phi i32 [ %41, %35 ], [ %50, %42 ]
  %53 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %54 = bitcast i8* %53 to { i8*, i8, i8** }*
  %55 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 0
  store i8* bitcast ({ i8*, i8, i8** }* (i8*)* @choose to i8*), i8** %55
  %56 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 1
  store i8 0, i8* %56
  %57 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 2
  store i8** null, i8*** %57
  %58 = call i8* @malloc(i32 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i32))
  %59 = bitcast i8* %58 to i1*
  store i1 false, i1* %59
  %60 = bitcast i1* %59 to i8*
  %61 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 1
  %62 = load i8, i8* %61
  switch i8 %62, label %87 [
    i8 0, label %64
    i8 1, label %71
  ]

; <label>:63:                                     ; preds = %27
  unreachable

; <label>:64:                                     ; preds = %51
  %65 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 0
  %66 = load i8*, i8** %65
  %67 = bitcast i8* %66 to { i8*, i8, i8** }* (i8*)*
  %68 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 2
  %69 = load i8**, i8*** %68
  %70 = call { i8*, i8, i8** }* %67(i8* %60)
  br label %80

; <label>:71:                                     ; preds = %51
  %72 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 0
  %73 = load i8*, i8** %72
  %74 = bitcast i8* %73 to { i8*, i8, i8** }* (i8*, i8*)*
  %75 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %54, i32 0, i32 2
  %76 = load i8**, i8*** %75
  %77 = getelementptr i8*, i8** %76, i32 0
  %78 = load i8*, i8** %77
  %79 = call { i8*, i8, i8** }* %74(i8* %78, i8* %60)
  br label %80

; <label>:80:                                     ; preds = %71, %64
  %81 = phi { i8*, i8, i8** }* [ %70, %64 ], [ %79, %71 ]
  %82 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %83 = bitcast i8* %82 to i32*
  store i32 5, i32* %83
  %84 = bitcast i32* %83 to i8*
  %85 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %81, i32 0, i32 1
  %86 = load i8, i8* %85
  switch i8 %86, label %107 [
    i8 0, label %88
    i8 1, label %95
  ]

; <label>:87:                                     ; preds = %51
  unreachable

; <label>:88:                                     ; preds = %80
  %89 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %81, i32 0, i32 0
  %90 = load i8*, i8** %89
  %91 = bitcast i8* %90 to i32 (i8*)*
  %92 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %81, i32 0, i32 2
  %93 = load i8**, i8*** %92
  %94 = call i32 %91(i8* %84)
  br label %104

; <label>:95:                                     ; preds = %80
  %96 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %81, i32 0, i32 0
  %97 = load i8*, i8** %96
  %98 = bitcast i8* %97 to i32 (i8*, i8*)*
  %99 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %81, i32 0, i32 2
  %100 = load i8**, i8*** %99
  %101 = getelementptr i8*, i8** %100, i32 0
  %102 = load i8*, i8** %101
  %103 = call i32 %98(i8* %102, i8* %84)
  br label %104

; <label>:104:                                    ; preds = %95, %88
  %105 = phi i32 [ %94, %88 ], [ %103, %95 ]
  %106 = add i32 %52, %105
  ret i32 %106

; <label>:107:                                    ; preds = %80
  unreachable
}
