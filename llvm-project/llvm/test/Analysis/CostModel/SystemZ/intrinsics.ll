; RUN: opt < %s -passes="print<cost-model>" 2>&1 -disable-output -mtriple=systemz-unknown -mcpu=z13 \
; RUN:  | FileCheck %s -check-prefixes=CHECK,Z13
; RUN: opt < %s -passes="print<cost-model>" 2>&1 -disable-output -mtriple=systemz-unknown -mcpu=z15 \
; RUN:  | FileCheck %s -check-prefixes=CHECK,Z15

define void @bswap_i128(i128 %arg) {
; CHECK: function 'bswap_i128'
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp = tail call i128 @llvm.bswap.i128(i128 %arg)
  %swp = tail call i128 @llvm.bswap.i128(i128 %arg)
  ret void
}

define void @bswap_i64(i64 %arg, <2 x i64> %arg2) {
; CHECK: function 'bswap_i64'
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i64
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <2 x i64>
; CHECK: Cost Model: Found an estimated cost of 2 for instruction:   %swp4 = tail call <4 x i64>
  %swp1 = tail call i64 @llvm.bswap.i64(i64 %arg)
  %swp2 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %arg2)
  %swp4 = tail call <4 x i64> @llvm.bswap.v4i64(<4 x i64> undef)
  ret void
}

define void @bswap_i32(i32 %arg, <2 x i32> %arg2, <4 x i32> %arg4) {
; CHECK: function 'bswap_i32'
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i32
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <2 x i32>
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp4 = tail call <4 x i32>
; CHECK: Cost Model: Found an estimated cost of 2 for instruction:   %swp8 = tail call <8 x i32>
  %swp1 = tail call i32 @llvm.bswap.i32(i32 %arg)
  %swp2 = tail call <2 x i32> @llvm.bswap.v2i32(<2 x i32> %arg2)
  %swp4 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %arg4)
  %swp8 = tail call <8 x i32> @llvm.bswap.v8i32(<8 x i32> undef)
  ret void
}

define void @bswap_i16(i16 %arg, <2 x i16> %arg2, <4 x i16> %arg4,
                       <8 x i16> %arg8) {
; CHECK: function 'bswap_i16'
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i16 @llvm.bswap.i16(i16 %arg)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <2 x i16> @llvm.bswap.v2i16(<2 x i16> %arg2)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp4 = tail call <4 x i16> @llvm.bswap.v4i16(<4 x i16> %arg4)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp8 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %arg8)
; CHECK: Cost Model: Found an estimated cost of 2 for instruction:   %swp16 = tail call <16 x i16> @llvm.bswap.v16i16(<16 x i16> undef)
  %swp1 = tail call i16 @llvm.bswap.i16(i16 %arg)
  %swp2 = tail call <2 x i16> @llvm.bswap.v2i16(<2 x i16> %arg2)
  %swp4 = tail call <4 x i16> @llvm.bswap.v4i16(<4 x i16> %arg4)
  %swp8 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %arg8)
  %swp16 = tail call <16 x i16> @llvm.bswap.v16i16(<16 x i16> undef)
  ret void
}

; Test that store/load reversed is reflected in costs.
define void @bswap_i64_mem(ptr %src, i64 %arg, ptr %dst) {
; CHECK: function 'bswap_i64_mem'
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load i64, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i64 @llvm.bswap.i64(i64 %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call i64 @llvm.bswap.i64(i64 %arg)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i64 %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load i64, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call i64 @llvm.bswap.i64(i64 %Ld2)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i64 %swp3, ptr %dst
  %Ld1  = load i64, ptr %src
  %swp1 = tail call i64 @llvm.bswap.i64(i64 %Ld1)

  %swp2 = tail call i64 @llvm.bswap.i64(i64 %arg)
  store i64 %swp2, ptr %dst

  %Ld2  = load i64, ptr %src
  %swp3 = tail call i64 @llvm.bswap.i64(i64 %Ld2)
  store i64 %swp3, ptr %dst

  ret void
}

define void @bswap_v2i64_mem(ptr %src, <2 x i64> %arg, ptr %dst) {
; CHECK:function 'bswap_v2i64_mem'
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   %Ld1 = load <2 x i64>, ptr %src
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load <2 x i64>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %arg)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <2 x i64> %swp2, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <2 x i64> %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load <2 x i64>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %Ld2)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <2 x i64> %swp3, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <2 x i64> %swp3, ptr %dst

  %Ld1  = load <2 x i64>, ptr %src
  %swp1 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %Ld1)

  %swp2 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %arg)
  store <2 x i64> %swp2, ptr %dst

  %Ld2  = load <2 x i64>, ptr %src
  %swp3 = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %Ld2)
  store <2 x i64> %swp3, ptr %dst

  ret void
}

define void @bswap_i32_mem(ptr %src, i32 %arg, ptr %dst) {
; CHECK: function 'bswap_i32_mem'
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load i32, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i32 @llvm.bswap.i32(i32 %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call i32 @llvm.bswap.i32(i32 %arg)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i32 %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load i32, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call i32 @llvm.bswap.i32(i32 %Ld2)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i32 %swp3, ptr %dst
  %Ld1  = load i32, ptr %src
  %swp1 = tail call i32 @llvm.bswap.i32(i32 %Ld1)

  %swp2 = tail call i32 @llvm.bswap.i32(i32 %arg)
  store i32 %swp2, ptr %dst

  %Ld2  = load i32, ptr %src
  %swp3 = tail call i32 @llvm.bswap.i32(i32 %Ld2)
  store i32 %swp3, ptr %dst

  ret void
}

define void @bswap_v4i32_mem(ptr %src, <4 x i32> %arg, ptr %dst) {
; CHECK: function 'bswap_v4i32_mem'
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   %Ld1 = load <4 x i32>, ptr %src
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load <4 x i32>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %arg)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <4 x i32> %swp2, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <4 x i32> %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load <4 x i32>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %Ld2)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <4 x i32> %swp3, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <4 x i32> %swp3, ptr %dst
%Ld1  = load <4 x i32>, ptr %src
  %swp1 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %Ld1)

  %swp2 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %arg)
  store <4 x i32> %swp2, ptr %dst

  %Ld2  = load <4 x i32>, ptr %src
  %swp3 = tail call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %Ld2)
  store <4 x i32> %swp3, ptr %dst

  ret void
}

define void @bswap_i16_mem(ptr %src, i16 %arg, ptr %dst) {
; CHECK: function 'bswap_i16_mem'
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load i16, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call i16 @llvm.bswap.i16(i16 %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call i16 @llvm.bswap.i16(i16 %arg)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i16 %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load i16, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call i16 @llvm.bswap.i16(i16 %Ld2)
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   store i16 %swp3, ptr %dst
  %Ld1  = load i16, ptr %src
  %swp1 = tail call i16 @llvm.bswap.i16(i16 %Ld1)

  %swp2 = tail call i16 @llvm.bswap.i16(i16 %arg)
  store i16 %swp2, ptr %dst

  %Ld2  = load i16, ptr %src
  %swp3 = tail call i16 @llvm.bswap.i16(i16 %Ld2)
  store i16 %swp3, ptr %dst

  ret void
}

define void @bswap_v8i16_mem(ptr %src, <8 x i16> %arg, ptr %dst) {
; CHECK: function 'bswap_v8i16_mem'
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   %Ld1 = load <8 x i16>, ptr %src
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   %Ld1 = load <8 x i16>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp1 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %Ld1)
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp2 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %arg)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <8 x i16> %swp2, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <8 x i16> %swp2, ptr %dst
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %Ld2 = load <8 x i16>, ptr %src
; CHECK: Cost Model: Found an estimated cost of 1 for instruction:   %swp3 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %Ld2)
; Z13:   Cost Model: Found an estimated cost of 1 for instruction:   store <8 x i16> %swp3, ptr %dst
; Z15:   Cost Model: Found an estimated cost of 0 for instruction:   store <8 x i16> %swp3, ptr %dst
%Ld1  = load <8 x i16>, ptr %src
  %swp1 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %Ld1)

  %swp2 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %arg)
  store <8 x i16> %swp2, ptr %dst

  %Ld2  = load <8 x i16>, ptr %src
  %swp3 = tail call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %Ld2)
  store <8 x i16> %swp3, ptr %dst

  ret void
}

declare i128 @llvm.bswap.i128(i128)

declare i64 @llvm.bswap.i64(i64)
declare <2 x i64> @llvm.bswap.v2i64(<2 x i64>)
declare <4 x i64> @llvm.bswap.v4i64(<4 x i64>)

declare i32 @llvm.bswap.i32(i32)
declare <2 x i32> @llvm.bswap.v2i32(<2 x i32>)
declare <4 x i32> @llvm.bswap.v4i32(<4 x i32>)
declare <8 x i32> @llvm.bswap.v8i32(<8 x i32>)

declare i16 @llvm.bswap.i16(i16)
declare <2 x i16> @llvm.bswap.v2i16(<2 x i16>)
declare <4 x i16> @llvm.bswap.v4i16(<4 x i16>)
declare <8 x i16> @llvm.bswap.v8i16(<8 x i16>)
declare <16 x i16> @llvm.bswap.v16i16(<16 x i16>)
