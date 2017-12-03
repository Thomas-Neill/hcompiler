; ModuleID = '???'
source_filename = "stdin"

declare i8* @malloc(i32)

declare void @free(i8*)

define i32 @lambda__0(i32 %x) {
  ret i32 5
}

define i32 @lambda__1(i32 %x) {
  %1 = mul i32 %x, %x
  ret i32 %1
}

define i32 @main() {
  %1 = call i32 @lambda__0(i32 10)
  %2 = call i32 @lambda__1(i32 %1)
  ret i32 %2
}
