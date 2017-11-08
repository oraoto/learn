int globalvar = 12;

int add(int a) {
    return globalvar + a;
}

// Convert to LLVM IR: clang -emit-llvm -c -S add.c
// -S for IR

/*
define i32 @add(i32) #0 {
  ; stack allocated variable
  %2 = alloca i32, align 4
  ; store parameter %0 to %2
  store i32 %0, i32* %2, align 4
  ; load globalvar to register
  %3 = load i32, i32* @globalvar, align 4
  ; load %2 to register
  %4 = load i32, i32* %2, align 4
  ; do the addition, nsw = No Unsigned Wrap
  %5 = add nsw i32 %3, %4
  ;
  ret i32 %5
}
*/


// Convert to LLVM bitcode: llvm-as add.ll -o add.bc