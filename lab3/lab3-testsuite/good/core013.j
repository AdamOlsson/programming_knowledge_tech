;; BEGIN HEADER

.class public core013
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

  invokestatic core013/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  13
  ;; (void) printBool (test (0 int.- 1) && test (0));
  ldc 0
  ldc 1
  isub
  invokestatic core013/test(I)Z
  ifeq L0
  ldc 0
  invokestatic core013/test(I)Z
  goto L1
  L0:
  ldc 0
  L1:
  invokestatic core013/printBool(Z)V
  ;; (void) printBool (test (0 int.- 2) || test (1));
  ldc 0
  ldc 2
  isub
  invokestatic core013/test(I)Z
  ifeq L2
  ldc 1
  goto L3
  L2:
  ldc 1
  invokestatic core013/test(I)Z
  L3:
  invokestatic core013/printBool(Z)V
  ;; (void) printBool (test (3) && test (0 int.- 5) && true);
  ldc 3
  invokestatic core013/test(I)Z
  ifeq L4
  ldc 0
  ldc 5
  isub
  invokestatic core013/test(I)Z
  goto L5
  L4:
  ldc 0
  L5:
  ifeq L6
  ldc 1
  goto L7
  L6:
  ldc 0
  L7:
  invokestatic core013/printBool(Z)V
  ;; (void) printBool (test (3) || test (0 int.- 5) && true);
  ldc 3
  invokestatic core013/test(I)Z
  ifeq L8
  ldc 1
  goto L9
  L8:
  ldc 0
  ldc 5
  isub
  invokestatic core013/test(I)Z
  ifeq L10
  ldc 1
  goto L11
  L10:
  ldc 0
  L11:
  L9:
  invokestatic core013/printBool(Z)V
  ;; (void) printBool (true);
  ldc 1
  invokestatic core013/printBool(Z)V
  ;; (void) printBool (false);
  ldc 0
  invokestatic core013/printBool(Z)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static printBool(Z)V
  .limit locals 1
  .limit stack  2
  ;; if (b)
  iload 0
  ifeq L13
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  goto L12
  L13:
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  L12:
  return

.end method

.method public static test(I)Z
  .limit locals 1
  .limit stack  4
  ;; return (bool) i bool.> 0;
  iload 0
  ldc 0
  if_icmpgt L14
  ldc 0
  goto L15
  L14:
  ldc 1
  L15:
  ireturn
  return

.end method
