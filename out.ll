; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @f(i32 %x) {
  %1 = mul i32 %x, %x
  ret i32 %1
}

define i32 @main() {
  %1 = call i32 @f(i32 100)
  %2 = call i32 @f(i32 100)
  %3 = mul i32 %1, %2
  ret i32 %3
}
