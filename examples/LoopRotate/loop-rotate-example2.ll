; RUN: opt -analyze < %s | FileCheck %s
;
; FIXME: Edit the run line and add checks!
;
; XFAIL: *
;
;    int A[100];
;    int B[100];
;    void example(long N) {
;      for (long i = 0; i < N; ++i)
;        A[i] = i;
;    }
;
source_filename = "loop-rotate-example2.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@A = common global [100 x i32] zeroinitializer, align 16
@B = common global [100 x i32] zeroinitializer, align 16

define void @example(i64 %N) {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i64 %i.0, %N
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %conv = trunc i64 %i.0 to i32
  %arrayidx = getelementptr inbounds [100 x i32], [100 x i32]* @A, i64 0, i64 %i.0
  store i32 %conv, i32* %arrayidx, align 4, !tbaa !3
  %inc = add nuw nsw i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture)

declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture)


!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 9.0.0 (git@github.ibm.com:compiler/llvm-project.git ae45184d694fb793ba3bc0f898265aaf2923f38f)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
