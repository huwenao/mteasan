; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=i686 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64 < %s | FileCheck %s

@var = external dso_local global i32, align 4
@a = external global [4 x i32], align 16

define dso_local void @test() {
; CHECK-LABEL: test:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # var a+12 test
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    ret{{[l|q]}}
entry:
  %ai = getelementptr inbounds [4 x i32], ptr @a, i64 0, i64 3
  call void asm sideeffect "// ${0:p} ${1:p} ${2:p}", "^Ws,^Ws,^Ws,~{dirflag},~{fpsr},~{flags}"(ptr @var, ptr %ai, ptr @test)
  ret void
}

define dso_local void @test_label() {
; CHECK-LABEL: test_label:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:  .Ltmp0: # Block address taken
; CHECK-NEXT:  # %bb.1: # %label
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # .Ltmp0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    ret{{[l|q]}}
entry:
  br label %label

label:
  tail call void asm sideeffect "// ${0:p}", "^Ws,~{dirflag},~{fpsr},~{flags}"(ptr blockaddress(@test_label, %label))
  ret void
}