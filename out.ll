; ModuleID = '???'
source_filename = "stdin"

define i32 @f(i32 %x) {
  ret i32 %x
}

define i32 (i32) @g() {
  ret i32 (i32)* @f
}
