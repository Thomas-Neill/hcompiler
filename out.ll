; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

declare void @alloc_push()

declare i8* @alloc(i32)

declare void @alloc_depends(i8*, i8*)

declare void @alloc_pop_except(i8*)

define { i32, i8* }* @hask__just(i32* %a) {
  call void @alloc_push()
  %1 = call i8* @alloc(i32 ptrtoint ({ i32, i8* }* getelementptr ({ i32, i8* }, { i32, i8* }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32, i8* }*
  %3 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 0
  store i32 0, i32* %3
  %4 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %5 = bitcast i32* %a to i8*
  store i8* %5, i8** %4
  %6 = bitcast { i32, i8* }* %2 to i8*
  %7 = bitcast i32* %a to i8*
  call void @alloc_depends(i8* %6, i8* %7)
  %8 = bitcast { i32, i8* }* %2 to i8*
  call void @alloc_pop_except(i8* %8)
  ret { i32, i8* }* %2
}

define { i32, i8* }* @hask__null() {
  call void @alloc_push()
  %1 = call i8* @alloc(i32 ptrtoint ({ i32, i8* }* getelementptr ({ i32, i8* }, { i32, i8* }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i32, i8* }*
  %3 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 0
  store i32 1, i32* %3
  %4 = getelementptr { i32, i8* }, { i32, i8* }* %2, i32 0, i32 1
  %5 = call i8* @alloc(i32 0)
  %6 = bitcast i8* %5 to {}*
  %7 = bitcast {}* %6 to i8*
  store i8* %7, i8** %4
  %8 = bitcast { i32, i8* }* %2 to i8*
  %9 = bitcast {}* %6 to i8*
  call void @alloc_depends(i8* %8, i8* %9)
  %10 = bitcast { i32, i8* }* %2 to i8*
  call void @alloc_pop_except(i8* %10)
  ret { i32, i8* }* %2
}

define i32* @hask__unwrap({ i32, i8* }* %x) {
  call void @alloc_push()
  %1 = getelementptr { i32, i8* }, { i32, i8* }* %x, i32 0, i32 0
  %2 = load i32, i32* %1
  switch i32 %2, label %16 [
    i32 0, label %6
    i32 1, label %10
  ]

; <label>:3:                                      ; preds = %10, %6
  %4 = phi i32* [ %9, %6 ], [ %15, %10 ]
  %5 = bitcast i32* %4 to i8*
  call void @alloc_pop_except(i8* %5)
  ret i32* %4

; <label>:6:                                      ; preds = %0
  %7 = getelementptr { i32, i8* }, { i32, i8* }* %x, i32 0, i32 1
  %8 = load i8*, i8** %7
  %9 = bitcast i8* %8 to i32*
  br label %3

; <label>:10:                                     ; preds = %0
  %11 = getelementptr { i32, i8* }, { i32, i8* }* %x, i32 0, i32 1
  %12 = load i8*, i8** %11
  %13 = bitcast i8* %12 to {}*
  %14 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %15 = bitcast i8* %14 to i32*
  store i32 0, i32* %15
  br label %3

; <label>:16:                                     ; preds = %0
  unreachable
}

define i32* @hask__main() {
  call void @alloc_push()
  %1 = call i8* @alloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i8*, i8, i8** }*
  %3 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  store i8* bitcast (i32* ({ i32, i8* }*)* @hask__unwrap to i8*), i8** %3
  %4 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  store i8 0, i8* %4
  %5 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  store i8** null, i8*** %5
  %6 = call i8* @alloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %7 = bitcast i8* %6 to { i8*, i8, i8** }*
  %8 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  store i8* bitcast ({ i32, i8* }* (i32*)* @hask__just to i8*), i8** %8
  %9 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 1
  store i8 0, i8* %9
  %10 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  store i8** null, i8*** %10
  %11 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %12 = bitcast i8* %11 to i32*
  store i32 255, i32* %12
  %13 = bitcast i32* %12 to i8*
  %14 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 1
  %15 = load i8, i8* %14
  switch i8 %15, label %373 [
    i8 0, label %16
    i8 1, label %23
    i8 2, label %32
    i8 3, label %43
    i8 4, label %56
    i8 5, label %71
    i8 6, label %88
    i8 7, label %107
    i8 8, label %128
    i8 9, label %151
    i8 10, label %176
    i8 11, label %203
    i8 12, label %232
    i8 13, label %263
    i8 14, label %296
    i8 15, label %331
  ]

; <label>:16:                                     ; preds = %0
  %17 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %18 = load i8*, i8** %17
  %19 = bitcast i8* %18 to { i32, i8* }* (i8*)*
  %20 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %21 = load i8**, i8*** %20
  %22 = call { i32, i8* }* %19(i8* %13)
  br label %368

; <label>:23:                                     ; preds = %0
  %24 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %25 = load i8*, i8** %24
  %26 = bitcast i8* %25 to { i32, i8* }* (i8*, i8*)*
  %27 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %28 = load i8**, i8*** %27
  %29 = getelementptr i8*, i8** %28, i32 0
  %30 = load i8*, i8** %29
  %31 = call { i32, i8* }* %26(i8* %30, i8* %13)
  br label %368

; <label>:32:                                     ; preds = %0
  %33 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %34 = load i8*, i8** %33
  %35 = bitcast i8* %34 to { i32, i8* }* (i8*, i8*, i8*)*
  %36 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %37 = load i8**, i8*** %36
  %38 = getelementptr i8*, i8** %37, i32 0
  %39 = load i8*, i8** %38
  %40 = getelementptr i8*, i8** %37, i32 1
  %41 = load i8*, i8** %40
  %42 = call { i32, i8* }* %35(i8* %39, i8* %41, i8* %13)
  br label %368

; <label>:43:                                     ; preds = %0
  %44 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %45 = load i8*, i8** %44
  %46 = bitcast i8* %45 to { i32, i8* }* (i8*, i8*, i8*, i8*)*
  %47 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %48 = load i8**, i8*** %47
  %49 = getelementptr i8*, i8** %48, i32 0
  %50 = load i8*, i8** %49
  %51 = getelementptr i8*, i8** %48, i32 1
  %52 = load i8*, i8** %51
  %53 = getelementptr i8*, i8** %48, i32 2
  %54 = load i8*, i8** %53
  %55 = call { i32, i8* }* %46(i8* %50, i8* %52, i8* %54, i8* %13)
  br label %368

; <label>:56:                                     ; preds = %0
  %57 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %58 = load i8*, i8** %57
  %59 = bitcast i8* %58 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*)*
  %60 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %61 = load i8**, i8*** %60
  %62 = getelementptr i8*, i8** %61, i32 0
  %63 = load i8*, i8** %62
  %64 = getelementptr i8*, i8** %61, i32 1
  %65 = load i8*, i8** %64
  %66 = getelementptr i8*, i8** %61, i32 2
  %67 = load i8*, i8** %66
  %68 = getelementptr i8*, i8** %61, i32 3
  %69 = load i8*, i8** %68
  %70 = call { i32, i8* }* %59(i8* %63, i8* %65, i8* %67, i8* %69, i8* %13)
  br label %368

; <label>:71:                                     ; preds = %0
  %72 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %73 = load i8*, i8** %72
  %74 = bitcast i8* %73 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*)*
  %75 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %76 = load i8**, i8*** %75
  %77 = getelementptr i8*, i8** %76, i32 0
  %78 = load i8*, i8** %77
  %79 = getelementptr i8*, i8** %76, i32 1
  %80 = load i8*, i8** %79
  %81 = getelementptr i8*, i8** %76, i32 2
  %82 = load i8*, i8** %81
  %83 = getelementptr i8*, i8** %76, i32 3
  %84 = load i8*, i8** %83
  %85 = getelementptr i8*, i8** %76, i32 4
  %86 = load i8*, i8** %85
  %87 = call { i32, i8* }* %74(i8* %78, i8* %80, i8* %82, i8* %84, i8* %86, i8* %13)
  br label %368

; <label>:88:                                     ; preds = %0
  %89 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %90 = load i8*, i8** %89
  %91 = bitcast i8* %90 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %92 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %93 = load i8**, i8*** %92
  %94 = getelementptr i8*, i8** %93, i32 0
  %95 = load i8*, i8** %94
  %96 = getelementptr i8*, i8** %93, i32 1
  %97 = load i8*, i8** %96
  %98 = getelementptr i8*, i8** %93, i32 2
  %99 = load i8*, i8** %98
  %100 = getelementptr i8*, i8** %93, i32 3
  %101 = load i8*, i8** %100
  %102 = getelementptr i8*, i8** %93, i32 4
  %103 = load i8*, i8** %102
  %104 = getelementptr i8*, i8** %93, i32 5
  %105 = load i8*, i8** %104
  %106 = call { i32, i8* }* %91(i8* %95, i8* %97, i8* %99, i8* %101, i8* %103, i8* %105, i8* %13)
  br label %368

; <label>:107:                                    ; preds = %0
  %108 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %109 = load i8*, i8** %108
  %110 = bitcast i8* %109 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %111 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %112 = load i8**, i8*** %111
  %113 = getelementptr i8*, i8** %112, i32 0
  %114 = load i8*, i8** %113
  %115 = getelementptr i8*, i8** %112, i32 1
  %116 = load i8*, i8** %115
  %117 = getelementptr i8*, i8** %112, i32 2
  %118 = load i8*, i8** %117
  %119 = getelementptr i8*, i8** %112, i32 3
  %120 = load i8*, i8** %119
  %121 = getelementptr i8*, i8** %112, i32 4
  %122 = load i8*, i8** %121
  %123 = getelementptr i8*, i8** %112, i32 5
  %124 = load i8*, i8** %123
  %125 = getelementptr i8*, i8** %112, i32 6
  %126 = load i8*, i8** %125
  %127 = call { i32, i8* }* %110(i8* %114, i8* %116, i8* %118, i8* %120, i8* %122, i8* %124, i8* %126, i8* %13)
  br label %368

; <label>:128:                                    ; preds = %0
  %129 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %130 = load i8*, i8** %129
  %131 = bitcast i8* %130 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %132 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %133 = load i8**, i8*** %132
  %134 = getelementptr i8*, i8** %133, i32 0
  %135 = load i8*, i8** %134
  %136 = getelementptr i8*, i8** %133, i32 1
  %137 = load i8*, i8** %136
  %138 = getelementptr i8*, i8** %133, i32 2
  %139 = load i8*, i8** %138
  %140 = getelementptr i8*, i8** %133, i32 3
  %141 = load i8*, i8** %140
  %142 = getelementptr i8*, i8** %133, i32 4
  %143 = load i8*, i8** %142
  %144 = getelementptr i8*, i8** %133, i32 5
  %145 = load i8*, i8** %144
  %146 = getelementptr i8*, i8** %133, i32 6
  %147 = load i8*, i8** %146
  %148 = getelementptr i8*, i8** %133, i32 7
  %149 = load i8*, i8** %148
  %150 = call { i32, i8* }* %131(i8* %135, i8* %137, i8* %139, i8* %141, i8* %143, i8* %145, i8* %147, i8* %149, i8* %13)
  br label %368

; <label>:151:                                    ; preds = %0
  %152 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %153 = load i8*, i8** %152
  %154 = bitcast i8* %153 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %155 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %156 = load i8**, i8*** %155
  %157 = getelementptr i8*, i8** %156, i32 0
  %158 = load i8*, i8** %157
  %159 = getelementptr i8*, i8** %156, i32 1
  %160 = load i8*, i8** %159
  %161 = getelementptr i8*, i8** %156, i32 2
  %162 = load i8*, i8** %161
  %163 = getelementptr i8*, i8** %156, i32 3
  %164 = load i8*, i8** %163
  %165 = getelementptr i8*, i8** %156, i32 4
  %166 = load i8*, i8** %165
  %167 = getelementptr i8*, i8** %156, i32 5
  %168 = load i8*, i8** %167
  %169 = getelementptr i8*, i8** %156, i32 6
  %170 = load i8*, i8** %169
  %171 = getelementptr i8*, i8** %156, i32 7
  %172 = load i8*, i8** %171
  %173 = getelementptr i8*, i8** %156, i32 8
  %174 = load i8*, i8** %173
  %175 = call { i32, i8* }* %154(i8* %158, i8* %160, i8* %162, i8* %164, i8* %166, i8* %168, i8* %170, i8* %172, i8* %174, i8* %13)
  br label %368

; <label>:176:                                    ; preds = %0
  %177 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %178 = load i8*, i8** %177
  %179 = bitcast i8* %178 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %180 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %181 = load i8**, i8*** %180
  %182 = getelementptr i8*, i8** %181, i32 0
  %183 = load i8*, i8** %182
  %184 = getelementptr i8*, i8** %181, i32 1
  %185 = load i8*, i8** %184
  %186 = getelementptr i8*, i8** %181, i32 2
  %187 = load i8*, i8** %186
  %188 = getelementptr i8*, i8** %181, i32 3
  %189 = load i8*, i8** %188
  %190 = getelementptr i8*, i8** %181, i32 4
  %191 = load i8*, i8** %190
  %192 = getelementptr i8*, i8** %181, i32 5
  %193 = load i8*, i8** %192
  %194 = getelementptr i8*, i8** %181, i32 6
  %195 = load i8*, i8** %194
  %196 = getelementptr i8*, i8** %181, i32 7
  %197 = load i8*, i8** %196
  %198 = getelementptr i8*, i8** %181, i32 8
  %199 = load i8*, i8** %198
  %200 = getelementptr i8*, i8** %181, i32 9
  %201 = load i8*, i8** %200
  %202 = call { i32, i8* }* %179(i8* %183, i8* %185, i8* %187, i8* %189, i8* %191, i8* %193, i8* %195, i8* %197, i8* %199, i8* %201, i8* %13)
  br label %368

; <label>:203:                                    ; preds = %0
  %204 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %205 = load i8*, i8** %204
  %206 = bitcast i8* %205 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %207 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %208 = load i8**, i8*** %207
  %209 = getelementptr i8*, i8** %208, i32 0
  %210 = load i8*, i8** %209
  %211 = getelementptr i8*, i8** %208, i32 1
  %212 = load i8*, i8** %211
  %213 = getelementptr i8*, i8** %208, i32 2
  %214 = load i8*, i8** %213
  %215 = getelementptr i8*, i8** %208, i32 3
  %216 = load i8*, i8** %215
  %217 = getelementptr i8*, i8** %208, i32 4
  %218 = load i8*, i8** %217
  %219 = getelementptr i8*, i8** %208, i32 5
  %220 = load i8*, i8** %219
  %221 = getelementptr i8*, i8** %208, i32 6
  %222 = load i8*, i8** %221
  %223 = getelementptr i8*, i8** %208, i32 7
  %224 = load i8*, i8** %223
  %225 = getelementptr i8*, i8** %208, i32 8
  %226 = load i8*, i8** %225
  %227 = getelementptr i8*, i8** %208, i32 9
  %228 = load i8*, i8** %227
  %229 = getelementptr i8*, i8** %208, i32 10
  %230 = load i8*, i8** %229
  %231 = call { i32, i8* }* %206(i8* %210, i8* %212, i8* %214, i8* %216, i8* %218, i8* %220, i8* %222, i8* %224, i8* %226, i8* %228, i8* %230, i8* %13)
  br label %368

; <label>:232:                                    ; preds = %0
  %233 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %234 = load i8*, i8** %233
  %235 = bitcast i8* %234 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %236 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %237 = load i8**, i8*** %236
  %238 = getelementptr i8*, i8** %237, i32 0
  %239 = load i8*, i8** %238
  %240 = getelementptr i8*, i8** %237, i32 1
  %241 = load i8*, i8** %240
  %242 = getelementptr i8*, i8** %237, i32 2
  %243 = load i8*, i8** %242
  %244 = getelementptr i8*, i8** %237, i32 3
  %245 = load i8*, i8** %244
  %246 = getelementptr i8*, i8** %237, i32 4
  %247 = load i8*, i8** %246
  %248 = getelementptr i8*, i8** %237, i32 5
  %249 = load i8*, i8** %248
  %250 = getelementptr i8*, i8** %237, i32 6
  %251 = load i8*, i8** %250
  %252 = getelementptr i8*, i8** %237, i32 7
  %253 = load i8*, i8** %252
  %254 = getelementptr i8*, i8** %237, i32 8
  %255 = load i8*, i8** %254
  %256 = getelementptr i8*, i8** %237, i32 9
  %257 = load i8*, i8** %256
  %258 = getelementptr i8*, i8** %237, i32 10
  %259 = load i8*, i8** %258
  %260 = getelementptr i8*, i8** %237, i32 11
  %261 = load i8*, i8** %260
  %262 = call { i32, i8* }* %235(i8* %239, i8* %241, i8* %243, i8* %245, i8* %247, i8* %249, i8* %251, i8* %253, i8* %255, i8* %257, i8* %259, i8* %261, i8* %13)
  br label %368

; <label>:263:                                    ; preds = %0
  %264 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %265 = load i8*, i8** %264
  %266 = bitcast i8* %265 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %267 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %268 = load i8**, i8*** %267
  %269 = getelementptr i8*, i8** %268, i32 0
  %270 = load i8*, i8** %269
  %271 = getelementptr i8*, i8** %268, i32 1
  %272 = load i8*, i8** %271
  %273 = getelementptr i8*, i8** %268, i32 2
  %274 = load i8*, i8** %273
  %275 = getelementptr i8*, i8** %268, i32 3
  %276 = load i8*, i8** %275
  %277 = getelementptr i8*, i8** %268, i32 4
  %278 = load i8*, i8** %277
  %279 = getelementptr i8*, i8** %268, i32 5
  %280 = load i8*, i8** %279
  %281 = getelementptr i8*, i8** %268, i32 6
  %282 = load i8*, i8** %281
  %283 = getelementptr i8*, i8** %268, i32 7
  %284 = load i8*, i8** %283
  %285 = getelementptr i8*, i8** %268, i32 8
  %286 = load i8*, i8** %285
  %287 = getelementptr i8*, i8** %268, i32 9
  %288 = load i8*, i8** %287
  %289 = getelementptr i8*, i8** %268, i32 10
  %290 = load i8*, i8** %289
  %291 = getelementptr i8*, i8** %268, i32 11
  %292 = load i8*, i8** %291
  %293 = getelementptr i8*, i8** %268, i32 12
  %294 = load i8*, i8** %293
  %295 = call { i32, i8* }* %266(i8* %270, i8* %272, i8* %274, i8* %276, i8* %278, i8* %280, i8* %282, i8* %284, i8* %286, i8* %288, i8* %290, i8* %292, i8* %294, i8* %13)
  br label %368

; <label>:296:                                    ; preds = %0
  %297 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %298 = load i8*, i8** %297
  %299 = bitcast i8* %298 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %300 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %301 = load i8**, i8*** %300
  %302 = getelementptr i8*, i8** %301, i32 0
  %303 = load i8*, i8** %302
  %304 = getelementptr i8*, i8** %301, i32 1
  %305 = load i8*, i8** %304
  %306 = getelementptr i8*, i8** %301, i32 2
  %307 = load i8*, i8** %306
  %308 = getelementptr i8*, i8** %301, i32 3
  %309 = load i8*, i8** %308
  %310 = getelementptr i8*, i8** %301, i32 4
  %311 = load i8*, i8** %310
  %312 = getelementptr i8*, i8** %301, i32 5
  %313 = load i8*, i8** %312
  %314 = getelementptr i8*, i8** %301, i32 6
  %315 = load i8*, i8** %314
  %316 = getelementptr i8*, i8** %301, i32 7
  %317 = load i8*, i8** %316
  %318 = getelementptr i8*, i8** %301, i32 8
  %319 = load i8*, i8** %318
  %320 = getelementptr i8*, i8** %301, i32 9
  %321 = load i8*, i8** %320
  %322 = getelementptr i8*, i8** %301, i32 10
  %323 = load i8*, i8** %322
  %324 = getelementptr i8*, i8** %301, i32 11
  %325 = load i8*, i8** %324
  %326 = getelementptr i8*, i8** %301, i32 12
  %327 = load i8*, i8** %326
  %328 = getelementptr i8*, i8** %301, i32 13
  %329 = load i8*, i8** %328
  %330 = call { i32, i8* }* %299(i8* %303, i8* %305, i8* %307, i8* %309, i8* %311, i8* %313, i8* %315, i8* %317, i8* %319, i8* %321, i8* %323, i8* %325, i8* %327, i8* %329, i8* %13)
  br label %368

; <label>:331:                                    ; preds = %0
  %332 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 0
  %333 = load i8*, i8** %332
  %334 = bitcast i8* %333 to { i32, i8* }* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %335 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %7, i32 0, i32 2
  %336 = load i8**, i8*** %335
  %337 = getelementptr i8*, i8** %336, i32 0
  %338 = load i8*, i8** %337
  %339 = getelementptr i8*, i8** %336, i32 1
  %340 = load i8*, i8** %339
  %341 = getelementptr i8*, i8** %336, i32 2
  %342 = load i8*, i8** %341
  %343 = getelementptr i8*, i8** %336, i32 3
  %344 = load i8*, i8** %343
  %345 = getelementptr i8*, i8** %336, i32 4
  %346 = load i8*, i8** %345
  %347 = getelementptr i8*, i8** %336, i32 5
  %348 = load i8*, i8** %347
  %349 = getelementptr i8*, i8** %336, i32 6
  %350 = load i8*, i8** %349
  %351 = getelementptr i8*, i8** %336, i32 7
  %352 = load i8*, i8** %351
  %353 = getelementptr i8*, i8** %336, i32 8
  %354 = load i8*, i8** %353
  %355 = getelementptr i8*, i8** %336, i32 9
  %356 = load i8*, i8** %355
  %357 = getelementptr i8*, i8** %336, i32 10
  %358 = load i8*, i8** %357
  %359 = getelementptr i8*, i8** %336, i32 11
  %360 = load i8*, i8** %359
  %361 = getelementptr i8*, i8** %336, i32 12
  %362 = load i8*, i8** %361
  %363 = getelementptr i8*, i8** %336, i32 13
  %364 = load i8*, i8** %363
  %365 = getelementptr i8*, i8** %336, i32 14
  %366 = load i8*, i8** %365
  %367 = call { i32, i8* }* %334(i8* %338, i8* %340, i8* %342, i8* %344, i8* %346, i8* %348, i8* %350, i8* %352, i8* %354, i8* %356, i8* %358, i8* %360, i8* %362, i8* %364, i8* %366, i8* %13)
  br label %368

; <label>:368:                                    ; preds = %331, %296, %263, %232, %203, %176, %151, %128, %107, %88, %71, %56, %43, %32, %23, %16
  %369 = phi { i32, i8* }* [ %22, %16 ], [ %31, %23 ], [ %42, %32 ], [ %55, %43 ], [ %70, %56 ], [ %87, %71 ], [ %106, %88 ], [ %127, %107 ], [ %150, %128 ], [ %175, %151 ], [ %202, %176 ], [ %231, %203 ], [ %262, %232 ], [ %295, %263 ], [ %330, %296 ], [ %367, %331 ]
  %370 = bitcast { i32, i8* }* %369 to i8*
  %371 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  %372 = load i8, i8* %371
  switch i8 %372, label %729 [
    i8 0, label %374
    i8 1, label %381
    i8 2, label %390
    i8 3, label %401
    i8 4, label %414
    i8 5, label %429
    i8 6, label %446
    i8 7, label %465
    i8 8, label %486
    i8 9, label %509
    i8 10, label %534
    i8 11, label %561
    i8 12, label %590
    i8 13, label %621
    i8 14, label %654
    i8 15, label %689
  ]

; <label>:373:                                    ; preds = %0
  unreachable

; <label>:374:                                    ; preds = %368
  %375 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %376 = load i8*, i8** %375
  %377 = bitcast i8* %376 to i32* (i8*)*
  %378 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %379 = load i8**, i8*** %378
  %380 = call i32* %377(i8* %370)
  br label %726

; <label>:381:                                    ; preds = %368
  %382 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %383 = load i8*, i8** %382
  %384 = bitcast i8* %383 to i32* (i8*, i8*)*
  %385 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %386 = load i8**, i8*** %385
  %387 = getelementptr i8*, i8** %386, i32 0
  %388 = load i8*, i8** %387
  %389 = call i32* %384(i8* %388, i8* %370)
  br label %726

; <label>:390:                                    ; preds = %368
  %391 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %392 = load i8*, i8** %391
  %393 = bitcast i8* %392 to i32* (i8*, i8*, i8*)*
  %394 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %395 = load i8**, i8*** %394
  %396 = getelementptr i8*, i8** %395, i32 0
  %397 = load i8*, i8** %396
  %398 = getelementptr i8*, i8** %395, i32 1
  %399 = load i8*, i8** %398
  %400 = call i32* %393(i8* %397, i8* %399, i8* %370)
  br label %726

; <label>:401:                                    ; preds = %368
  %402 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %403 = load i8*, i8** %402
  %404 = bitcast i8* %403 to i32* (i8*, i8*, i8*, i8*)*
  %405 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %406 = load i8**, i8*** %405
  %407 = getelementptr i8*, i8** %406, i32 0
  %408 = load i8*, i8** %407
  %409 = getelementptr i8*, i8** %406, i32 1
  %410 = load i8*, i8** %409
  %411 = getelementptr i8*, i8** %406, i32 2
  %412 = load i8*, i8** %411
  %413 = call i32* %404(i8* %408, i8* %410, i8* %412, i8* %370)
  br label %726

; <label>:414:                                    ; preds = %368
  %415 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %416 = load i8*, i8** %415
  %417 = bitcast i8* %416 to i32* (i8*, i8*, i8*, i8*, i8*)*
  %418 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %419 = load i8**, i8*** %418
  %420 = getelementptr i8*, i8** %419, i32 0
  %421 = load i8*, i8** %420
  %422 = getelementptr i8*, i8** %419, i32 1
  %423 = load i8*, i8** %422
  %424 = getelementptr i8*, i8** %419, i32 2
  %425 = load i8*, i8** %424
  %426 = getelementptr i8*, i8** %419, i32 3
  %427 = load i8*, i8** %426
  %428 = call i32* %417(i8* %421, i8* %423, i8* %425, i8* %427, i8* %370)
  br label %726

; <label>:429:                                    ; preds = %368
  %430 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %431 = load i8*, i8** %430
  %432 = bitcast i8* %431 to i32* (i8*, i8*, i8*, i8*, i8*, i8*)*
  %433 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %434 = load i8**, i8*** %433
  %435 = getelementptr i8*, i8** %434, i32 0
  %436 = load i8*, i8** %435
  %437 = getelementptr i8*, i8** %434, i32 1
  %438 = load i8*, i8** %437
  %439 = getelementptr i8*, i8** %434, i32 2
  %440 = load i8*, i8** %439
  %441 = getelementptr i8*, i8** %434, i32 3
  %442 = load i8*, i8** %441
  %443 = getelementptr i8*, i8** %434, i32 4
  %444 = load i8*, i8** %443
  %445 = call i32* %432(i8* %436, i8* %438, i8* %440, i8* %442, i8* %444, i8* %370)
  br label %726

; <label>:446:                                    ; preds = %368
  %447 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %448 = load i8*, i8** %447
  %449 = bitcast i8* %448 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %450 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %451 = load i8**, i8*** %450
  %452 = getelementptr i8*, i8** %451, i32 0
  %453 = load i8*, i8** %452
  %454 = getelementptr i8*, i8** %451, i32 1
  %455 = load i8*, i8** %454
  %456 = getelementptr i8*, i8** %451, i32 2
  %457 = load i8*, i8** %456
  %458 = getelementptr i8*, i8** %451, i32 3
  %459 = load i8*, i8** %458
  %460 = getelementptr i8*, i8** %451, i32 4
  %461 = load i8*, i8** %460
  %462 = getelementptr i8*, i8** %451, i32 5
  %463 = load i8*, i8** %462
  %464 = call i32* %449(i8* %453, i8* %455, i8* %457, i8* %459, i8* %461, i8* %463, i8* %370)
  br label %726

; <label>:465:                                    ; preds = %368
  %466 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %467 = load i8*, i8** %466
  %468 = bitcast i8* %467 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %469 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %470 = load i8**, i8*** %469
  %471 = getelementptr i8*, i8** %470, i32 0
  %472 = load i8*, i8** %471
  %473 = getelementptr i8*, i8** %470, i32 1
  %474 = load i8*, i8** %473
  %475 = getelementptr i8*, i8** %470, i32 2
  %476 = load i8*, i8** %475
  %477 = getelementptr i8*, i8** %470, i32 3
  %478 = load i8*, i8** %477
  %479 = getelementptr i8*, i8** %470, i32 4
  %480 = load i8*, i8** %479
  %481 = getelementptr i8*, i8** %470, i32 5
  %482 = load i8*, i8** %481
  %483 = getelementptr i8*, i8** %470, i32 6
  %484 = load i8*, i8** %483
  %485 = call i32* %468(i8* %472, i8* %474, i8* %476, i8* %478, i8* %480, i8* %482, i8* %484, i8* %370)
  br label %726

; <label>:486:                                    ; preds = %368
  %487 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %488 = load i8*, i8** %487
  %489 = bitcast i8* %488 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %490 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %491 = load i8**, i8*** %490
  %492 = getelementptr i8*, i8** %491, i32 0
  %493 = load i8*, i8** %492
  %494 = getelementptr i8*, i8** %491, i32 1
  %495 = load i8*, i8** %494
  %496 = getelementptr i8*, i8** %491, i32 2
  %497 = load i8*, i8** %496
  %498 = getelementptr i8*, i8** %491, i32 3
  %499 = load i8*, i8** %498
  %500 = getelementptr i8*, i8** %491, i32 4
  %501 = load i8*, i8** %500
  %502 = getelementptr i8*, i8** %491, i32 5
  %503 = load i8*, i8** %502
  %504 = getelementptr i8*, i8** %491, i32 6
  %505 = load i8*, i8** %504
  %506 = getelementptr i8*, i8** %491, i32 7
  %507 = load i8*, i8** %506
  %508 = call i32* %489(i8* %493, i8* %495, i8* %497, i8* %499, i8* %501, i8* %503, i8* %505, i8* %507, i8* %370)
  br label %726

; <label>:509:                                    ; preds = %368
  %510 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %511 = load i8*, i8** %510
  %512 = bitcast i8* %511 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %513 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %514 = load i8**, i8*** %513
  %515 = getelementptr i8*, i8** %514, i32 0
  %516 = load i8*, i8** %515
  %517 = getelementptr i8*, i8** %514, i32 1
  %518 = load i8*, i8** %517
  %519 = getelementptr i8*, i8** %514, i32 2
  %520 = load i8*, i8** %519
  %521 = getelementptr i8*, i8** %514, i32 3
  %522 = load i8*, i8** %521
  %523 = getelementptr i8*, i8** %514, i32 4
  %524 = load i8*, i8** %523
  %525 = getelementptr i8*, i8** %514, i32 5
  %526 = load i8*, i8** %525
  %527 = getelementptr i8*, i8** %514, i32 6
  %528 = load i8*, i8** %527
  %529 = getelementptr i8*, i8** %514, i32 7
  %530 = load i8*, i8** %529
  %531 = getelementptr i8*, i8** %514, i32 8
  %532 = load i8*, i8** %531
  %533 = call i32* %512(i8* %516, i8* %518, i8* %520, i8* %522, i8* %524, i8* %526, i8* %528, i8* %530, i8* %532, i8* %370)
  br label %726

; <label>:534:                                    ; preds = %368
  %535 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %536 = load i8*, i8** %535
  %537 = bitcast i8* %536 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %538 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %539 = load i8**, i8*** %538
  %540 = getelementptr i8*, i8** %539, i32 0
  %541 = load i8*, i8** %540
  %542 = getelementptr i8*, i8** %539, i32 1
  %543 = load i8*, i8** %542
  %544 = getelementptr i8*, i8** %539, i32 2
  %545 = load i8*, i8** %544
  %546 = getelementptr i8*, i8** %539, i32 3
  %547 = load i8*, i8** %546
  %548 = getelementptr i8*, i8** %539, i32 4
  %549 = load i8*, i8** %548
  %550 = getelementptr i8*, i8** %539, i32 5
  %551 = load i8*, i8** %550
  %552 = getelementptr i8*, i8** %539, i32 6
  %553 = load i8*, i8** %552
  %554 = getelementptr i8*, i8** %539, i32 7
  %555 = load i8*, i8** %554
  %556 = getelementptr i8*, i8** %539, i32 8
  %557 = load i8*, i8** %556
  %558 = getelementptr i8*, i8** %539, i32 9
  %559 = load i8*, i8** %558
  %560 = call i32* %537(i8* %541, i8* %543, i8* %545, i8* %547, i8* %549, i8* %551, i8* %553, i8* %555, i8* %557, i8* %559, i8* %370)
  br label %726

; <label>:561:                                    ; preds = %368
  %562 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %563 = load i8*, i8** %562
  %564 = bitcast i8* %563 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %565 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %566 = load i8**, i8*** %565
  %567 = getelementptr i8*, i8** %566, i32 0
  %568 = load i8*, i8** %567
  %569 = getelementptr i8*, i8** %566, i32 1
  %570 = load i8*, i8** %569
  %571 = getelementptr i8*, i8** %566, i32 2
  %572 = load i8*, i8** %571
  %573 = getelementptr i8*, i8** %566, i32 3
  %574 = load i8*, i8** %573
  %575 = getelementptr i8*, i8** %566, i32 4
  %576 = load i8*, i8** %575
  %577 = getelementptr i8*, i8** %566, i32 5
  %578 = load i8*, i8** %577
  %579 = getelementptr i8*, i8** %566, i32 6
  %580 = load i8*, i8** %579
  %581 = getelementptr i8*, i8** %566, i32 7
  %582 = load i8*, i8** %581
  %583 = getelementptr i8*, i8** %566, i32 8
  %584 = load i8*, i8** %583
  %585 = getelementptr i8*, i8** %566, i32 9
  %586 = load i8*, i8** %585
  %587 = getelementptr i8*, i8** %566, i32 10
  %588 = load i8*, i8** %587
  %589 = call i32* %564(i8* %568, i8* %570, i8* %572, i8* %574, i8* %576, i8* %578, i8* %580, i8* %582, i8* %584, i8* %586, i8* %588, i8* %370)
  br label %726

; <label>:590:                                    ; preds = %368
  %591 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %592 = load i8*, i8** %591
  %593 = bitcast i8* %592 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %594 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %595 = load i8**, i8*** %594
  %596 = getelementptr i8*, i8** %595, i32 0
  %597 = load i8*, i8** %596
  %598 = getelementptr i8*, i8** %595, i32 1
  %599 = load i8*, i8** %598
  %600 = getelementptr i8*, i8** %595, i32 2
  %601 = load i8*, i8** %600
  %602 = getelementptr i8*, i8** %595, i32 3
  %603 = load i8*, i8** %602
  %604 = getelementptr i8*, i8** %595, i32 4
  %605 = load i8*, i8** %604
  %606 = getelementptr i8*, i8** %595, i32 5
  %607 = load i8*, i8** %606
  %608 = getelementptr i8*, i8** %595, i32 6
  %609 = load i8*, i8** %608
  %610 = getelementptr i8*, i8** %595, i32 7
  %611 = load i8*, i8** %610
  %612 = getelementptr i8*, i8** %595, i32 8
  %613 = load i8*, i8** %612
  %614 = getelementptr i8*, i8** %595, i32 9
  %615 = load i8*, i8** %614
  %616 = getelementptr i8*, i8** %595, i32 10
  %617 = load i8*, i8** %616
  %618 = getelementptr i8*, i8** %595, i32 11
  %619 = load i8*, i8** %618
  %620 = call i32* %593(i8* %597, i8* %599, i8* %601, i8* %603, i8* %605, i8* %607, i8* %609, i8* %611, i8* %613, i8* %615, i8* %617, i8* %619, i8* %370)
  br label %726

; <label>:621:                                    ; preds = %368
  %622 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %623 = load i8*, i8** %622
  %624 = bitcast i8* %623 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %625 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %626 = load i8**, i8*** %625
  %627 = getelementptr i8*, i8** %626, i32 0
  %628 = load i8*, i8** %627
  %629 = getelementptr i8*, i8** %626, i32 1
  %630 = load i8*, i8** %629
  %631 = getelementptr i8*, i8** %626, i32 2
  %632 = load i8*, i8** %631
  %633 = getelementptr i8*, i8** %626, i32 3
  %634 = load i8*, i8** %633
  %635 = getelementptr i8*, i8** %626, i32 4
  %636 = load i8*, i8** %635
  %637 = getelementptr i8*, i8** %626, i32 5
  %638 = load i8*, i8** %637
  %639 = getelementptr i8*, i8** %626, i32 6
  %640 = load i8*, i8** %639
  %641 = getelementptr i8*, i8** %626, i32 7
  %642 = load i8*, i8** %641
  %643 = getelementptr i8*, i8** %626, i32 8
  %644 = load i8*, i8** %643
  %645 = getelementptr i8*, i8** %626, i32 9
  %646 = load i8*, i8** %645
  %647 = getelementptr i8*, i8** %626, i32 10
  %648 = load i8*, i8** %647
  %649 = getelementptr i8*, i8** %626, i32 11
  %650 = load i8*, i8** %649
  %651 = getelementptr i8*, i8** %626, i32 12
  %652 = load i8*, i8** %651
  %653 = call i32* %624(i8* %628, i8* %630, i8* %632, i8* %634, i8* %636, i8* %638, i8* %640, i8* %642, i8* %644, i8* %646, i8* %648, i8* %650, i8* %652, i8* %370)
  br label %726

; <label>:654:                                    ; preds = %368
  %655 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %656 = load i8*, i8** %655
  %657 = bitcast i8* %656 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %658 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %659 = load i8**, i8*** %658
  %660 = getelementptr i8*, i8** %659, i32 0
  %661 = load i8*, i8** %660
  %662 = getelementptr i8*, i8** %659, i32 1
  %663 = load i8*, i8** %662
  %664 = getelementptr i8*, i8** %659, i32 2
  %665 = load i8*, i8** %664
  %666 = getelementptr i8*, i8** %659, i32 3
  %667 = load i8*, i8** %666
  %668 = getelementptr i8*, i8** %659, i32 4
  %669 = load i8*, i8** %668
  %670 = getelementptr i8*, i8** %659, i32 5
  %671 = load i8*, i8** %670
  %672 = getelementptr i8*, i8** %659, i32 6
  %673 = load i8*, i8** %672
  %674 = getelementptr i8*, i8** %659, i32 7
  %675 = load i8*, i8** %674
  %676 = getelementptr i8*, i8** %659, i32 8
  %677 = load i8*, i8** %676
  %678 = getelementptr i8*, i8** %659, i32 9
  %679 = load i8*, i8** %678
  %680 = getelementptr i8*, i8** %659, i32 10
  %681 = load i8*, i8** %680
  %682 = getelementptr i8*, i8** %659, i32 11
  %683 = load i8*, i8** %682
  %684 = getelementptr i8*, i8** %659, i32 12
  %685 = load i8*, i8** %684
  %686 = getelementptr i8*, i8** %659, i32 13
  %687 = load i8*, i8** %686
  %688 = call i32* %657(i8* %661, i8* %663, i8* %665, i8* %667, i8* %669, i8* %671, i8* %673, i8* %675, i8* %677, i8* %679, i8* %681, i8* %683, i8* %685, i8* %687, i8* %370)
  br label %726

; <label>:689:                                    ; preds = %368
  %690 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %691 = load i8*, i8** %690
  %692 = bitcast i8* %691 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %693 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %694 = load i8**, i8*** %693
  %695 = getelementptr i8*, i8** %694, i32 0
  %696 = load i8*, i8** %695
  %697 = getelementptr i8*, i8** %694, i32 1
  %698 = load i8*, i8** %697
  %699 = getelementptr i8*, i8** %694, i32 2
  %700 = load i8*, i8** %699
  %701 = getelementptr i8*, i8** %694, i32 3
  %702 = load i8*, i8** %701
  %703 = getelementptr i8*, i8** %694, i32 4
  %704 = load i8*, i8** %703
  %705 = getelementptr i8*, i8** %694, i32 5
  %706 = load i8*, i8** %705
  %707 = getelementptr i8*, i8** %694, i32 6
  %708 = load i8*, i8** %707
  %709 = getelementptr i8*, i8** %694, i32 7
  %710 = load i8*, i8** %709
  %711 = getelementptr i8*, i8** %694, i32 8
  %712 = load i8*, i8** %711
  %713 = getelementptr i8*, i8** %694, i32 9
  %714 = load i8*, i8** %713
  %715 = getelementptr i8*, i8** %694, i32 10
  %716 = load i8*, i8** %715
  %717 = getelementptr i8*, i8** %694, i32 11
  %718 = load i8*, i8** %717
  %719 = getelementptr i8*, i8** %694, i32 12
  %720 = load i8*, i8** %719
  %721 = getelementptr i8*, i8** %694, i32 13
  %722 = load i8*, i8** %721
  %723 = getelementptr i8*, i8** %694, i32 14
  %724 = load i8*, i8** %723
  %725 = call i32* %692(i8* %696, i8* %698, i8* %700, i8* %702, i8* %704, i8* %706, i8* %708, i8* %710, i8* %712, i8* %714, i8* %716, i8* %718, i8* %720, i8* %722, i8* %724, i8* %370)
  br label %726

; <label>:726:                                    ; preds = %689, %654, %621, %590, %561, %534, %509, %486, %465, %446, %429, %414, %401, %390, %381, %374
  %727 = phi i32* [ %380, %374 ], [ %389, %381 ], [ %400, %390 ], [ %413, %401 ], [ %428, %414 ], [ %445, %429 ], [ %464, %446 ], [ %485, %465 ], [ %508, %486 ], [ %533, %509 ], [ %560, %534 ], [ %589, %561 ], [ %620, %590 ], [ %653, %621 ], [ %688, %654 ], [ %725, %689 ]
  %728 = bitcast i32* %727 to i8*
  call void @alloc_pop_except(i8* %728)
  ret i32* %727

; <label>:729:                                    ; preds = %368
  unreachable
}
