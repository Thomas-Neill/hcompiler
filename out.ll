; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define { i32, i8* }* @wrap(i8* %x) {
  %1 = bitcast i8* %x to i32*
  %2 = load i32, i32* %1
  %3 = call i8* @malloc(i32 ptrtoint ({ i32, i8* }* getelementptr ({ i32, i8* }, { i32, i8* }* null, i32 1) to i32))
  %4 = bitcast i8* %3 to { i32, i8* }*
  %5 = getelementptr { i32, i8* }, { i32, i8* }* %4, i32 0, i32 0
  store i32 1, i32* %5
  %6 = getelementptr { i32, i8* }, { i32, i8* }* %4, i32 0, i32 1
  %7 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %8 = bitcast i8* %7 to i32*
  store i32 %2, i32* %8
  %9 = bitcast i32* %8 to i8*
  store i8* %9, i8** %6
  ret { i32, i8* }* %4
}

define { i32, i8* }* @null() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i32, i8* }* getelementptr ({ i32, i8* }, { i32, i8* }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32, i8* }*
  %3 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 0
  store i32 0, i32* %3
  %4 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %5 = call i8* @malloc(i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32))
  %6 = bitcast i8* %5 to {}**
  %7 = call i8* @malloc(i32 0)
  %8 = bitcast i8* %7 to {}*
  store {}* %8, {}** %6
  %9 = bitcast {}** %6 to i8*
  store i8* %9, i8** %4
  ret { i32, i8* }* %2
}

define { i32, i8* }* @safeadd(i8* %foo) {
  %1 = bitcast i8* %foo to { i32, i8* }**
  %2 = load { i32, i8* }*, { i32, i8* }** %1
  %3 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 0
  %4 = load i32, i32* %3
  switch i32 %4, label %35 [
    i32 0, label %7
    i32 1, label %19
  ]

; <label>:5:                                      ; preds = %71, %52
  %6 = phi { i32, i8* }* [ %53, %52 ], [ %72, %71 ]
  ret { i32, i8* }* %6

; <label>:7:                                      ; preds = %0
  %8 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %9 = load i8*, i8** %8
  %10 = bitcast i8* %9 to {}**
  %11 = load {}*, {}** %10
  %12 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %13 = bitcast i8* %12 to { i8*, i8, i8** }*
  %14 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* ()* @null to i8*), i8** %14
  %15 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 1
  store i8 0, i8* %15
  %16 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 2
  store i8** null, i8*** %16
  %17 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 1
  %18 = load i8, i8* %17
  switch i8 %18, label %54 [
    i8 0, label %36
    i8 1, label %43
  ]

; <label>:19:                                     ; preds = %0
  %20 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %21 = load i8*, i8** %20
  %22 = bitcast i8* %21 to i32*
  %23 = load i32, i32* %22
  %24 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %25 = bitcast i8* %24 to { i8*, i8, i8** }*
  %26 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* (i8*)* @wrap to i8*), i8** %26
  %27 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 1
  store i8 0, i8* %27
  %28 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 2
  store i8** null, i8*** %28
  %29 = add i32 %23, 10
  %30 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %31 = bitcast i8* %30 to i32*
  store i32 %29, i32* %31
  %32 = bitcast i32* %31 to i8*
  %33 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 1
  %34 = load i8, i8* %33
  switch i8 %34, label %73 [
    i8 0, label %55
    i8 1, label %62
  ]

; <label>:35:                                     ; preds = %0
  unreachable

; <label>:36:                                     ; preds = %7
  %37 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 0
  %38 = load i8*, i8** %37
  %39 = bitcast i8* %38 to { i32, i8* }* ()*
  %40 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 2
  %41 = load i8**, i8*** %40
  %42 = call { i32, i8* }* %39()
  br label %52

; <label>:43:                                     ; preds = %7
  %44 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 0
  %45 = load i8*, i8** %44
  %46 = bitcast i8* %45 to { i32, i8* }* (i8*)*
  %47 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %13, i32 0, i32 2
  %48 = load i8**, i8*** %47
  %49 = getelementptr i8*, i8** %48, i32 0
  %50 = load i8*, i8** %49
  %51 = call { i32, i8* }* %46(i8* %50)
  br label %52

; <label>:52:                                     ; preds = %43, %36
  %53 = phi { i32, i8* }* [ %42, %36 ], [ %51, %43 ]
  br label %5

; <label>:54:                                     ; preds = %7
  unreachable

; <label>:55:                                     ; preds = %19
  %56 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 0
  %57 = load i8*, i8** %56
  %58 = bitcast i8* %57 to { i32, i8* }* (i8*)*
  %59 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 2
  %60 = load i8**, i8*** %59
  %61 = call { i32, i8* }* %58(i8* %32)
  br label %71

; <label>:62:                                     ; preds = %19
  %63 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 0
  %64 = load i8*, i8** %63
  %65 = bitcast i8* %64 to { i32, i8* }* (i8*, i8*)*
  %66 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %25, i32 0, i32 2
  %67 = load i8**, i8*** %66
  %68 = getelementptr i8*, i8** %67, i32 0
  %69 = load i8*, i8** %68
  %70 = call { i32, i8* }* %65(i8* %69, i8* %32)
  br label %71

; <label>:71:                                     ; preds = %62, %55
  %72 = phi { i32, i8* }* [ %61, %55 ], [ %70, %62 ]
  br label %5

; <label>:73:                                     ; preds = %19
  unreachable
}

define i32 @unwrap(i8* %bar) {
  %1 = bitcast i8* %bar to { i32, i8* }**
  %2 = load { i32, i8* }*, { i32, i8* }** %1
  %3 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 0
  %4 = load i32, i32* %3
  switch i32 %4, label %17 [
    i32 0, label %7
    i32 1, label %12
  ]

; <label>:5:                                      ; preds = %12, %7
  %6 = phi i32 [ 0, %7 ], [ %16, %12 ]
  ret i32 %6

; <label>:7:                                      ; preds = %0
  %8 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %9 = load i8*, i8** %8
  %10 = bitcast i8* %9 to {}**
  %11 = load {}*, {}** %10
  br label %5

; <label>:12:                                     ; preds = %0
  %13 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %14 = load i8*, i8** %13
  %15 = bitcast i8* %14 to i32*
  %16 = load i32, i32* %15
  br label %5

; <label>:17:                                     ; preds = %0
  unreachable
}

define i32 @main() {
  %1 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i8*, i8, i8** }*
  %3 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  store i8* bitcast (i32 (i8*)* @unwrap to i8*), i8** %3
  %4 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  store i8 0, i8* %4
  %5 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  store i8** null, i8*** %5
  %6 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %7 = bitcast i8* %6 to { i8*, i8, i8** }*
  %8 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* (i8*)* @safeadd to i8*), i8** %8
  %9 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 1
  store i8 0, i8* %9
  %10 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  store i8** null, i8*** %10
  %11 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %12 = bitcast i8* %11 to { i8*, i8, i8** }*
  %13 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* ()* @null to i8*), i8** %13
  %14 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 1
  store i8 0, i8* %14
  %15 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 2
  store i8** null, i8*** %15
  %16 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 1
  %17 = load i8, i8* %16
  switch i8 %17, label %41 [
    i8 0, label %18
    i8 1, label %25
  ]

; <label>:18:                                     ; preds = %0
  %19 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 0
  %20 = load i8*, i8** %19
  %21 = bitcast i8* %20 to { i32, i8* }* ()*
  %22 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 2
  %23 = load i8**, i8*** %22
  %24 = call { i32, i8* }* %21()
  br label %34

; <label>:25:                                     ; preds = %0
  %26 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 0
  %27 = load i8*, i8** %26
  %28 = bitcast i8* %27 to { i32, i8* }* (i8*)*
  %29 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %12, i32 0, i32 2
  %30 = load i8**, i8*** %29
  %31 = getelementptr i8*, i8** %30, i32 0
  %32 = load i8*, i8** %31
  %33 = call { i32, i8* }* %28(i8* %32)
  br label %34

; <label>:34:                                     ; preds = %25, %18
  %35 = phi { i32, i8* }* [ %24, %18 ], [ %33, %25 ]
  %36 = call i8* @malloc(i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32))
  %37 = bitcast i8* %36 to { i32, i8* }**
  store { i32, i8* }* %35, { i32, i8* }** %37
  %38 = bitcast { i32, i8* }** %37 to i8*
  %39 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 1
  %40 = load i8, i8* %39
  switch i8 %40, label %65 [
    i8 0, label %42
    i8 1, label %49
  ]

; <label>:41:                                     ; preds = %0
  unreachable

; <label>:42:                                     ; preds = %34
  %43 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %44 = load i8*, i8** %43
  %45 = bitcast i8* %44 to { i32, i8* }* (i8*)*
  %46 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %47 = load i8**, i8*** %46
  %48 = call { i32, i8* }* %45(i8* %38)
  br label %58

; <label>:49:                                     ; preds = %34
  %50 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %51 = load i8*, i8** %50
  %52 = bitcast i8* %51 to { i32, i8* }* (i8*, i8*)*
  %53 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %54 = load i8**, i8*** %53
  %55 = getelementptr i8*, i8** %54, i32 0
  %56 = load i8*, i8** %55
  %57 = call { i32, i8* }* %52(i8* %56, i8* %38)
  br label %58

; <label>:58:                                     ; preds = %49, %42
  %59 = phi { i32, i8* }* [ %48, %42 ], [ %57, %49 ]
  %60 = call i8* @malloc(i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32))
  %61 = bitcast i8* %60 to { i32, i8* }**
  store { i32, i8* }* %59, { i32, i8* }** %61
  %62 = bitcast { i32, i8* }** %61 to i8*
  %63 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  %64 = load i8, i8* %63
  switch i8 %64, label %104 [
    i8 0, label %66
    i8 1, label %73
  ]

; <label>:65:                                     ; preds = %34
  unreachable

; <label>:66:                                     ; preds = %58
  %67 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %68 = load i8*, i8** %67
  %69 = bitcast i8* %68 to i32 (i8*)*
  %70 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %71 = load i8**, i8*** %70
  %72 = call i32 %69(i8* %62)
  br label %82

; <label>:73:                                     ; preds = %58
  %74 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %75 = load i8*, i8** %74
  %76 = bitcast i8* %75 to i32 (i8*, i8*)*
  %77 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %78 = load i8**, i8*** %77
  %79 = getelementptr i8*, i8** %78, i32 0
  %80 = load i8*, i8** %79
  %81 = call i32 %76(i8* %80, i8* %62)
  br label %82

; <label>:82:                                     ; preds = %73, %66
  %83 = phi i32 [ %72, %66 ], [ %81, %73 ]
  %84 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %85 = bitcast i8* %84 to { i8*, i8, i8** }*
  %86 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 0
  store i8* bitcast (i32 (i8*)* @unwrap to i8*), i8** %86
  %87 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 1
  store i8 0, i8* %87
  %88 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 2
  store i8** null, i8*** %88
  %89 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %90 = bitcast i8* %89 to { i8*, i8, i8** }*
  %91 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* (i8*)* @safeadd to i8*), i8** %91
  %92 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 1
  store i8 0, i8* %92
  %93 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 2
  store i8** null, i8*** %93
  %94 = call i8* @malloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %95 = bitcast i8* %94 to { i8*, i8, i8** }*
  %96 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* (i8*)* @wrap to i8*), i8** %96
  %97 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 1
  store i8 0, i8* %97
  %98 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 2
  store i8** null, i8*** %98
  %99 = call i8* @malloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %100 = bitcast i8* %99 to i32*
  store i32 20, i32* %100
  %101 = bitcast i32* %100 to i8*
  %102 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 1
  %103 = load i8, i8* %102
  switch i8 %103, label %128 [
    i8 0, label %105
    i8 1, label %112
  ]

; <label>:104:                                    ; preds = %58
  unreachable

; <label>:105:                                    ; preds = %82
  %106 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 0
  %107 = load i8*, i8** %106
  %108 = bitcast i8* %107 to { i32, i8* }* (i8*)*
  %109 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 2
  %110 = load i8**, i8*** %109
  %111 = call { i32, i8* }* %108(i8* %101)
  br label %121

; <label>:112:                                    ; preds = %82
  %113 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 0
  %114 = load i8*, i8** %113
  %115 = bitcast i8* %114 to { i32, i8* }* (i8*, i8*)*
  %116 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %95, i32 0, i32 2
  %117 = load i8**, i8*** %116
  %118 = getelementptr i8*, i8** %117, i32 0
  %119 = load i8*, i8** %118
  %120 = call { i32, i8* }* %115(i8* %119, i8* %101)
  br label %121

; <label>:121:                                    ; preds = %112, %105
  %122 = phi { i32, i8* }* [ %111, %105 ], [ %120, %112 ]
  %123 = call i8* @malloc(i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32))
  %124 = bitcast i8* %123 to { i32, i8* }**
  store { i32, i8* }* %122, { i32, i8* }** %124
  %125 = bitcast { i32, i8* }** %124 to i8*
  %126 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 1
  %127 = load i8, i8* %126
  switch i8 %127, label %152 [
    i8 0, label %129
    i8 1, label %136
  ]

; <label>:128:                                    ; preds = %82
  unreachable

; <label>:129:                                    ; preds = %121
  %130 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 0
  %131 = load i8*, i8** %130
  %132 = bitcast i8* %131 to { i32, i8* }* (i8*)*
  %133 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 2
  %134 = load i8**, i8*** %133
  %135 = call { i32, i8* }* %132(i8* %125)
  br label %145

; <label>:136:                                    ; preds = %121
  %137 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 0
  %138 = load i8*, i8** %137
  %139 = bitcast i8* %138 to { i32, i8* }* (i8*, i8*)*
  %140 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %90, i32 0, i32 2
  %141 = load i8**, i8*** %140
  %142 = getelementptr i8*, i8** %141, i32 0
  %143 = load i8*, i8** %142
  %144 = call { i32, i8* }* %139(i8* %143, i8* %125)
  br label %145

; <label>:145:                                    ; preds = %136, %129
  %146 = phi { i32, i8* }* [ %135, %129 ], [ %144, %136 ]
  %147 = call i8* @malloc(i32 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i32))
  %148 = bitcast i8* %147 to { i32, i8* }**
  store { i32, i8* }* %146, { i32, i8* }** %148
  %149 = bitcast { i32, i8* }** %148 to i8*
  %150 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 1
  %151 = load i8, i8* %150
  switch i8 %151, label %172 [
    i8 0, label %153
    i8 1, label %160
  ]

; <label>:152:                                    ; preds = %121
  unreachable

; <label>:153:                                    ; preds = %145
  %154 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 0
  %155 = load i8*, i8** %154
  %156 = bitcast i8* %155 to i32 (i8*)*
  %157 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 2
  %158 = load i8**, i8*** %157
  %159 = call i32 %156(i8* %149)
  br label %169

; <label>:160:                                    ; preds = %145
  %161 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 0
  %162 = load i8*, i8** %161
  %163 = bitcast i8* %162 to i32 (i8*, i8*)*
  %164 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %85, i32 0, i32 2
  %165 = load i8**, i8*** %164
  %166 = getelementptr i8*, i8** %165, i32 0
  %167 = load i8*, i8** %166
  %168 = call i32 %163(i8* %167, i8* %149)
  br label %169

; <label>:169:                                    ; preds = %160, %153
  %170 = phi i32 [ %159, %153 ], [ %168, %160 ]
  %171 = add i32 %83, %170
  ret i32 %171

; <label>:172:                                    ; preds = %145
  unreachable
}
