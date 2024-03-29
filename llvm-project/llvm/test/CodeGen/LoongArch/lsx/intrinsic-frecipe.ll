; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=loongarch64 --mattr=+lsx,+frecipe < %s | FileCheck %s

declare <4 x float> @llvm.loongarch.lsx.vfrecipe.s(<4 x float>)

define <4 x float> @lsx_vfrecipe_s(<4 x float> %va) nounwind {
; CHECK-LABEL: lsx_vfrecipe_s:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vfrecipe.s $vr0, $vr0
; CHECK-NEXT:    ret
entry:
  %res = call <4 x float> @llvm.loongarch.lsx.vfrecipe.s(<4 x float> %va)
  ret <4 x float> %res
}

declare <2 x double> @llvm.loongarch.lsx.vfrecipe.d(<2 x double>)

define <2 x double> @lsx_vfrecipe_d(<2 x double> %va) nounwind {
; CHECK-LABEL: lsx_vfrecipe_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vfrecipe.d $vr0, $vr0
; CHECK-NEXT:    ret
entry:
  %res = call <2 x double> @llvm.loongarch.lsx.vfrecipe.d(<2 x double> %va)
  ret <2 x double> %res
}
