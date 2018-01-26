; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

declare void @alloc_push()

declare i8* @alloc(i32)

declare void @alloc_depends(i8*, i8*)

declare void @alloc_pop_except(i8*)

define i32* @hask__main() {
  call void @alloc_push()
  %1 = call i8* @alloc(i32 ptrtoint ({ i8*, i8, i8** }* getelementptr ({ i8*, i8, i8** }, { i8*, i8, i8** }* null, i32 1) to i32))
  %2 = bitcast i8* %1 to { i8*, i8, i8** }*
  %3 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  store i8* bitcast (i32* (i32*)* @hask__g to i8*), i8** %3
  %4 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  store i8 0, i8* %4
  %5 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  store i8** null, i8*** %5
  %6 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %7 = bitcast i8* %6 to i32*
  store i32 10, i32* %7
  %8 = bitcast i32* %7 to i8*
  %9 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 1
  %10 = load i8, i8* %9
  switch i8 %10, label %366 [
    i8 0, label %11
    i8 1, label %18
    i8 2, label %27
    i8 3, label %38
    i8 4, label %51
    i8 5, label %66
    i8 6, label %83
    i8 7, label %102
    i8 8, label %123
    i8 9, label %146
    i8 10, label %171
    i8 11, label %198
    i8 12, label %227
    i8 13, label %258
    i8 14, label %291
    i8 15, label %326
  ]

; <label>:11:                                     ; preds = %0
  %12 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %13 = load i8*, i8** %12
  %14 = bitcast i8* %13 to i32* (i8*)*
  %15 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %16 = load i8**, i8*** %15
  %17 = call i32* %14(i8* %8)
  br label %363

; <label>:18:                                     ; preds = %0
  %19 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %20 = load i8*, i8** %19
  %21 = bitcast i8* %20 to i32* (i8*, i8*)*
  %22 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %23 = load i8**, i8*** %22
  %24 = getelementptr i8*, i8** %23, i32 0
  %25 = load i8*, i8** %24
  %26 = call i32* %21(i8* %25, i8* %8)
  br label %363

; <label>:27:                                     ; preds = %0
  %28 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %29 = load i8*, i8** %28
  %30 = bitcast i8* %29 to i32* (i8*, i8*, i8*)*
  %31 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %32 = load i8**, i8*** %31
  %33 = getelementptr i8*, i8** %32, i32 0
  %34 = load i8*, i8** %33
  %35 = getelementptr i8*, i8** %32, i32 1
  %36 = load i8*, i8** %35
  %37 = call i32* %30(i8* %34, i8* %36, i8* %8)
  br label %363

; <label>:38:                                     ; preds = %0
  %39 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %40 = load i8*, i8** %39
  %41 = bitcast i8* %40 to i32* (i8*, i8*, i8*, i8*)*
  %42 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %43 = load i8**, i8*** %42
  %44 = getelementptr i8*, i8** %43, i32 0
  %45 = load i8*, i8** %44
  %46 = getelementptr i8*, i8** %43, i32 1
  %47 = load i8*, i8** %46
  %48 = getelementptr i8*, i8** %43, i32 2
  %49 = load i8*, i8** %48
  %50 = call i32* %41(i8* %45, i8* %47, i8* %49, i8* %8)
  br label %363

; <label>:51:                                     ; preds = %0
  %52 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %53 = load i8*, i8** %52
  %54 = bitcast i8* %53 to i32* (i8*, i8*, i8*, i8*, i8*)*
  %55 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %56 = load i8**, i8*** %55
  %57 = getelementptr i8*, i8** %56, i32 0
  %58 = load i8*, i8** %57
  %59 = getelementptr i8*, i8** %56, i32 1
  %60 = load i8*, i8** %59
  %61 = getelementptr i8*, i8** %56, i32 2
  %62 = load i8*, i8** %61
  %63 = getelementptr i8*, i8** %56, i32 3
  %64 = load i8*, i8** %63
  %65 = call i32* %54(i8* %58, i8* %60, i8* %62, i8* %64, i8* %8)
  br label %363

; <label>:66:                                     ; preds = %0
  %67 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %68 = load i8*, i8** %67
  %69 = bitcast i8* %68 to i32* (i8*, i8*, i8*, i8*, i8*, i8*)*
  %70 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %71 = load i8**, i8*** %70
  %72 = getelementptr i8*, i8** %71, i32 0
  %73 = load i8*, i8** %72
  %74 = getelementptr i8*, i8** %71, i32 1
  %75 = load i8*, i8** %74
  %76 = getelementptr i8*, i8** %71, i32 2
  %77 = load i8*, i8** %76
  %78 = getelementptr i8*, i8** %71, i32 3
  %79 = load i8*, i8** %78
  %80 = getelementptr i8*, i8** %71, i32 4
  %81 = load i8*, i8** %80
  %82 = call i32* %69(i8* %73, i8* %75, i8* %77, i8* %79, i8* %81, i8* %8)
  br label %363

; <label>:83:                                     ; preds = %0
  %84 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %85 = load i8*, i8** %84
  %86 = bitcast i8* %85 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %87 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %88 = load i8**, i8*** %87
  %89 = getelementptr i8*, i8** %88, i32 0
  %90 = load i8*, i8** %89
  %91 = getelementptr i8*, i8** %88, i32 1
  %92 = load i8*, i8** %91
  %93 = getelementptr i8*, i8** %88, i32 2
  %94 = load i8*, i8** %93
  %95 = getelementptr i8*, i8** %88, i32 3
  %96 = load i8*, i8** %95
  %97 = getelementptr i8*, i8** %88, i32 4
  %98 = load i8*, i8** %97
  %99 = getelementptr i8*, i8** %88, i32 5
  %100 = load i8*, i8** %99
  %101 = call i32* %86(i8* %90, i8* %92, i8* %94, i8* %96, i8* %98, i8* %100, i8* %8)
  br label %363

; <label>:102:                                    ; preds = %0
  %103 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %104 = load i8*, i8** %103
  %105 = bitcast i8* %104 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %106 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %107 = load i8**, i8*** %106
  %108 = getelementptr i8*, i8** %107, i32 0
  %109 = load i8*, i8** %108
  %110 = getelementptr i8*, i8** %107, i32 1
  %111 = load i8*, i8** %110
  %112 = getelementptr i8*, i8** %107, i32 2
  %113 = load i8*, i8** %112
  %114 = getelementptr i8*, i8** %107, i32 3
  %115 = load i8*, i8** %114
  %116 = getelementptr i8*, i8** %107, i32 4
  %117 = load i8*, i8** %116
  %118 = getelementptr i8*, i8** %107, i32 5
  %119 = load i8*, i8** %118
  %120 = getelementptr i8*, i8** %107, i32 6
  %121 = load i8*, i8** %120
  %122 = call i32* %105(i8* %109, i8* %111, i8* %113, i8* %115, i8* %117, i8* %119, i8* %121, i8* %8)
  br label %363

; <label>:123:                                    ; preds = %0
  %124 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %125 = load i8*, i8** %124
  %126 = bitcast i8* %125 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %127 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %128 = load i8**, i8*** %127
  %129 = getelementptr i8*, i8** %128, i32 0
  %130 = load i8*, i8** %129
  %131 = getelementptr i8*, i8** %128, i32 1
  %132 = load i8*, i8** %131
  %133 = getelementptr i8*, i8** %128, i32 2
  %134 = load i8*, i8** %133
  %135 = getelementptr i8*, i8** %128, i32 3
  %136 = load i8*, i8** %135
  %137 = getelementptr i8*, i8** %128, i32 4
  %138 = load i8*, i8** %137
  %139 = getelementptr i8*, i8** %128, i32 5
  %140 = load i8*, i8** %139
  %141 = getelementptr i8*, i8** %128, i32 6
  %142 = load i8*, i8** %141
  %143 = getelementptr i8*, i8** %128, i32 7
  %144 = load i8*, i8** %143
  %145 = call i32* %126(i8* %130, i8* %132, i8* %134, i8* %136, i8* %138, i8* %140, i8* %142, i8* %144, i8* %8)
  br label %363

; <label>:146:                                    ; preds = %0
  %147 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %148 = load i8*, i8** %147
  %149 = bitcast i8* %148 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %150 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %151 = load i8**, i8*** %150
  %152 = getelementptr i8*, i8** %151, i32 0
  %153 = load i8*, i8** %152
  %154 = getelementptr i8*, i8** %151, i32 1
  %155 = load i8*, i8** %154
  %156 = getelementptr i8*, i8** %151, i32 2
  %157 = load i8*, i8** %156
  %158 = getelementptr i8*, i8** %151, i32 3
  %159 = load i8*, i8** %158
  %160 = getelementptr i8*, i8** %151, i32 4
  %161 = load i8*, i8** %160
  %162 = getelementptr i8*, i8** %151, i32 5
  %163 = load i8*, i8** %162
  %164 = getelementptr i8*, i8** %151, i32 6
  %165 = load i8*, i8** %164
  %166 = getelementptr i8*, i8** %151, i32 7
  %167 = load i8*, i8** %166
  %168 = getelementptr i8*, i8** %151, i32 8
  %169 = load i8*, i8** %168
  %170 = call i32* %149(i8* %153, i8* %155, i8* %157, i8* %159, i8* %161, i8* %163, i8* %165, i8* %167, i8* %169, i8* %8)
  br label %363

; <label>:171:                                    ; preds = %0
  %172 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %173 = load i8*, i8** %172
  %174 = bitcast i8* %173 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %175 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %176 = load i8**, i8*** %175
  %177 = getelementptr i8*, i8** %176, i32 0
  %178 = load i8*, i8** %177
  %179 = getelementptr i8*, i8** %176, i32 1
  %180 = load i8*, i8** %179
  %181 = getelementptr i8*, i8** %176, i32 2
  %182 = load i8*, i8** %181
  %183 = getelementptr i8*, i8** %176, i32 3
  %184 = load i8*, i8** %183
  %185 = getelementptr i8*, i8** %176, i32 4
  %186 = load i8*, i8** %185
  %187 = getelementptr i8*, i8** %176, i32 5
  %188 = load i8*, i8** %187
  %189 = getelementptr i8*, i8** %176, i32 6
  %190 = load i8*, i8** %189
  %191 = getelementptr i8*, i8** %176, i32 7
  %192 = load i8*, i8** %191
  %193 = getelementptr i8*, i8** %176, i32 8
  %194 = load i8*, i8** %193
  %195 = getelementptr i8*, i8** %176, i32 9
  %196 = load i8*, i8** %195
  %197 = call i32* %174(i8* %178, i8* %180, i8* %182, i8* %184, i8* %186, i8* %188, i8* %190, i8* %192, i8* %194, i8* %196, i8* %8)
  br label %363

; <label>:198:                                    ; preds = %0
  %199 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %200 = load i8*, i8** %199
  %201 = bitcast i8* %200 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %202 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %203 = load i8**, i8*** %202
  %204 = getelementptr i8*, i8** %203, i32 0
  %205 = load i8*, i8** %204
  %206 = getelementptr i8*, i8** %203, i32 1
  %207 = load i8*, i8** %206
  %208 = getelementptr i8*, i8** %203, i32 2
  %209 = load i8*, i8** %208
  %210 = getelementptr i8*, i8** %203, i32 3
  %211 = load i8*, i8** %210
  %212 = getelementptr i8*, i8** %203, i32 4
  %213 = load i8*, i8** %212
  %214 = getelementptr i8*, i8** %203, i32 5
  %215 = load i8*, i8** %214
  %216 = getelementptr i8*, i8** %203, i32 6
  %217 = load i8*, i8** %216
  %218 = getelementptr i8*, i8** %203, i32 7
  %219 = load i8*, i8** %218
  %220 = getelementptr i8*, i8** %203, i32 8
  %221 = load i8*, i8** %220
  %222 = getelementptr i8*, i8** %203, i32 9
  %223 = load i8*, i8** %222
  %224 = getelementptr i8*, i8** %203, i32 10
  %225 = load i8*, i8** %224
  %226 = call i32* %201(i8* %205, i8* %207, i8* %209, i8* %211, i8* %213, i8* %215, i8* %217, i8* %219, i8* %221, i8* %223, i8* %225, i8* %8)
  br label %363

; <label>:227:                                    ; preds = %0
  %228 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %229 = load i8*, i8** %228
  %230 = bitcast i8* %229 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %231 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %232 = load i8**, i8*** %231
  %233 = getelementptr i8*, i8** %232, i32 0
  %234 = load i8*, i8** %233
  %235 = getelementptr i8*, i8** %232, i32 1
  %236 = load i8*, i8** %235
  %237 = getelementptr i8*, i8** %232, i32 2
  %238 = load i8*, i8** %237
  %239 = getelementptr i8*, i8** %232, i32 3
  %240 = load i8*, i8** %239
  %241 = getelementptr i8*, i8** %232, i32 4
  %242 = load i8*, i8** %241
  %243 = getelementptr i8*, i8** %232, i32 5
  %244 = load i8*, i8** %243
  %245 = getelementptr i8*, i8** %232, i32 6
  %246 = load i8*, i8** %245
  %247 = getelementptr i8*, i8** %232, i32 7
  %248 = load i8*, i8** %247
  %249 = getelementptr i8*, i8** %232, i32 8
  %250 = load i8*, i8** %249
  %251 = getelementptr i8*, i8** %232, i32 9
  %252 = load i8*, i8** %251
  %253 = getelementptr i8*, i8** %232, i32 10
  %254 = load i8*, i8** %253
  %255 = getelementptr i8*, i8** %232, i32 11
  %256 = load i8*, i8** %255
  %257 = call i32* %230(i8* %234, i8* %236, i8* %238, i8* %240, i8* %242, i8* %244, i8* %246, i8* %248, i8* %250, i8* %252, i8* %254, i8* %256, i8* %8)
  br label %363

; <label>:258:                                    ; preds = %0
  %259 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %260 = load i8*, i8** %259
  %261 = bitcast i8* %260 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %262 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %263 = load i8**, i8*** %262
  %264 = getelementptr i8*, i8** %263, i32 0
  %265 = load i8*, i8** %264
  %266 = getelementptr i8*, i8** %263, i32 1
  %267 = load i8*, i8** %266
  %268 = getelementptr i8*, i8** %263, i32 2
  %269 = load i8*, i8** %268
  %270 = getelementptr i8*, i8** %263, i32 3
  %271 = load i8*, i8** %270
  %272 = getelementptr i8*, i8** %263, i32 4
  %273 = load i8*, i8** %272
  %274 = getelementptr i8*, i8** %263, i32 5
  %275 = load i8*, i8** %274
  %276 = getelementptr i8*, i8** %263, i32 6
  %277 = load i8*, i8** %276
  %278 = getelementptr i8*, i8** %263, i32 7
  %279 = load i8*, i8** %278
  %280 = getelementptr i8*, i8** %263, i32 8
  %281 = load i8*, i8** %280
  %282 = getelementptr i8*, i8** %263, i32 9
  %283 = load i8*, i8** %282
  %284 = getelementptr i8*, i8** %263, i32 10
  %285 = load i8*, i8** %284
  %286 = getelementptr i8*, i8** %263, i32 11
  %287 = load i8*, i8** %286
  %288 = getelementptr i8*, i8** %263, i32 12
  %289 = load i8*, i8** %288
  %290 = call i32* %261(i8* %265, i8* %267, i8* %269, i8* %271, i8* %273, i8* %275, i8* %277, i8* %279, i8* %281, i8* %283, i8* %285, i8* %287, i8* %289, i8* %8)
  br label %363

; <label>:291:                                    ; preds = %0
  %292 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %293 = load i8*, i8** %292
  %294 = bitcast i8* %293 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %295 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %296 = load i8**, i8*** %295
  %297 = getelementptr i8*, i8** %296, i32 0
  %298 = load i8*, i8** %297
  %299 = getelementptr i8*, i8** %296, i32 1
  %300 = load i8*, i8** %299
  %301 = getelementptr i8*, i8** %296, i32 2
  %302 = load i8*, i8** %301
  %303 = getelementptr i8*, i8** %296, i32 3
  %304 = load i8*, i8** %303
  %305 = getelementptr i8*, i8** %296, i32 4
  %306 = load i8*, i8** %305
  %307 = getelementptr i8*, i8** %296, i32 5
  %308 = load i8*, i8** %307
  %309 = getelementptr i8*, i8** %296, i32 6
  %310 = load i8*, i8** %309
  %311 = getelementptr i8*, i8** %296, i32 7
  %312 = load i8*, i8** %311
  %313 = getelementptr i8*, i8** %296, i32 8
  %314 = load i8*, i8** %313
  %315 = getelementptr i8*, i8** %296, i32 9
  %316 = load i8*, i8** %315
  %317 = getelementptr i8*, i8** %296, i32 10
  %318 = load i8*, i8** %317
  %319 = getelementptr i8*, i8** %296, i32 11
  %320 = load i8*, i8** %319
  %321 = getelementptr i8*, i8** %296, i32 12
  %322 = load i8*, i8** %321
  %323 = getelementptr i8*, i8** %296, i32 13
  %324 = load i8*, i8** %323
  %325 = call i32* %294(i8* %298, i8* %300, i8* %302, i8* %304, i8* %306, i8* %308, i8* %310, i8* %312, i8* %314, i8* %316, i8* %318, i8* %320, i8* %322, i8* %324, i8* %8)
  br label %363

; <label>:326:                                    ; preds = %0
  %327 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 0
  %328 = load i8*, i8** %327
  %329 = bitcast i8* %328 to i32* (i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*)*
  %330 = getelementptr { i8*, i8, i8** }, { i8*, i8, i8** }* %2, i32 0, i32 2
  %331 = load i8**, i8*** %330
  %332 = getelementptr i8*, i8** %331, i32 0
  %333 = load i8*, i8** %332
  %334 = getelementptr i8*, i8** %331, i32 1
  %335 = load i8*, i8** %334
  %336 = getelementptr i8*, i8** %331, i32 2
  %337 = load i8*, i8** %336
  %338 = getelementptr i8*, i8** %331, i32 3
  %339 = load i8*, i8** %338
  %340 = getelementptr i8*, i8** %331, i32 4
  %341 = load i8*, i8** %340
  %342 = getelementptr i8*, i8** %331, i32 5
  %343 = load i8*, i8** %342
  %344 = getelementptr i8*, i8** %331, i32 6
  %345 = load i8*, i8** %344
  %346 = getelementptr i8*, i8** %331, i32 7
  %347 = load i8*, i8** %346
  %348 = getelementptr i8*, i8** %331, i32 8
  %349 = load i8*, i8** %348
  %350 = getelementptr i8*, i8** %331, i32 9
  %351 = load i8*, i8** %350
  %352 = getelementptr i8*, i8** %331, i32 10
  %353 = load i8*, i8** %352
  %354 = getelementptr i8*, i8** %331, i32 11
  %355 = load i8*, i8** %354
  %356 = getelementptr i8*, i8** %331, i32 12
  %357 = load i8*, i8** %356
  %358 = getelementptr i8*, i8** %331, i32 13
  %359 = load i8*, i8** %358
  %360 = getelementptr i8*, i8** %331, i32 14
  %361 = load i8*, i8** %360
  %362 = call i32* %329(i8* %333, i8* %335, i8* %337, i8* %339, i8* %341, i8* %343, i8* %345, i8* %347, i8* %349, i8* %351, i8* %353, i8* %355, i8* %357, i8* %359, i8* %361, i8* %8)
  br label %363

; <label>:363:                                    ; preds = %326, %291, %258, %227, %198, %171, %146, %123, %102, %83, %66, %51, %38, %27, %18, %11
  %364 = phi i32* [ %17, %11 ], [ %26, %18 ], [ %37, %27 ], [ %50, %38 ], [ %65, %51 ], [ %82, %66 ], [ %101, %83 ], [ %122, %102 ], [ %145, %123 ], [ %170, %146 ], [ %197, %171 ], [ %226, %198 ], [ %257, %227 ], [ %290, %258 ], [ %325, %291 ], [ %362, %326 ]
  %365 = bitcast i32* %364 to i8*
  call void @alloc_pop_except(i8* %365)
  ret i32* %364

; <label>:366:                                    ; preds = %0
  unreachable
}

define i32* @hask__g(i32* %a) {
  call void @alloc_push()
  %1 = load i32, i32* %a
  %2 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %3 = bitcast i8* %2 to i32*
  store i32 10, i32* %3
  %4 = load i32, i32* %3
  %5 = mul i32 %1, %4
  %6 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %7 = bitcast i8* %6 to i32*
  store i32 %5, i32* %7
  %8 = load i32, i32* %7
  %9 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %10 = bitcast i8* %9 to i32*
  store i32 10, i32* %10
  %11 = load i32, i32* %10
  %12 = add i32 %8, %11
  %13 = call i8* @alloc(i32 ptrtoint (i32* getelementptr (i32, i32* null, i32 1) to i32))
  %14 = bitcast i8* %13 to i32*
  store i32 %12, i32* %14
  %15 = bitcast i32* %14 to i8*
  call void @alloc_pop_except(i8* %15)
  ret i32* %14
}
