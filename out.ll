; ModuleID = '???'
source_filename = "stdin"

define i32 @fibs(i32 %n) {
  %1 = icmp slt i32 %n, 2
  br i1 %1, label %2, label %3

; <label>:2:                                      ; preds = %0
  br label %9

; <label>:3:                                      ; preds = %0
  %4 = sub i32 %n, 1
  %5 = call i32 @fibs(i32 %4)
  %6 = sub i32 %n, 2
  %7 = call i32 @fibs(i32 %6)
  %8 = add i32 %5, %7
  br label %9

; <label>:9:                                      ; preds = %3, %2
  %10 = phi i32 [ 1, %2 ], [ %8, %3 ]
  ret i32 %10
}

define i32 @main() {
  %1 = call i32 @fibs(i32 5)
  ret i32 %1
}
