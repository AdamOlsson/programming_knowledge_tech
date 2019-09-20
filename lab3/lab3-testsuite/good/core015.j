;; BEGIN HEADER

.class public core015
.super java/lang/Object

.method public <init>()V
  .limit locals 1

  aload_0
  invokespecial java/lang/Object/<init>()V
  return

.end method

.method public static main([Ljava/lang/String;)V
  .limit locals 1
  .limit stack  1

  invokestatic core015/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  1
  ;; (void) printInt (ev (17));
  ldc 17
  invokestatic core015/ev(I)I
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static ev(I)I
  .limit locals 2
  .limit stack  10
  ;; int e;
  ;; if (y bool.> 0)
  iload 0
  ldc 0
  if_icmpgt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; (int) e = ev (y int.- 2);
  iload 0
  ldc 2
  isub
  invokestatic core015/ev(I)I
  dup
  istore 1
  pop
  goto L0
  L1:
  ;; if (y bool.< 0)
  iload 0
  ldc 0
  if_icmplt L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L5
  ;; (int) e = 0;
  ldc 0
  dup
  istore 1
  pop
  goto L4
  L5:
  ;; (int) e = 1;
  ldc 1
  dup
  istore 1
  pop
  L4:
  L0:
  ;; return (int) e;
  iload 1
  ireturn
  return

.end method
