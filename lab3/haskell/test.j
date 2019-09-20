;; BEGIN HEADER

.class public test
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

  invokestatic test/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 1
  .limit stack  9
  ;; int y = 17;
  ldc 17
  istore 0
  ;; while (y bool.> 0)
  L0:
  ifeq L1
  iload 0
  ldc 0
  if_icmpgt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ;; (int) y = y int.- 2;
  iload 0
  ldc 2
  isub
  dup
  istore 0
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
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  goto L4
  L5:
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  L4:
  return

.end method
