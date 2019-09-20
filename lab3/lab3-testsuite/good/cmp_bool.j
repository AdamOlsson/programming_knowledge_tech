;; BEGIN HEADER

.class public cmp_bool
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

  invokestatic cmp_bool/main()I
  pop
  return

.end method

;; END HEADER

.method public static printBool(Z)V
  .limit locals 1
  .limit stack  2
  ;; if (b)
  iload 0
  ifeq L1
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  goto L0
  L1:
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  L0:
  return

.end method

.method public static main()I
  .limit locals 0
  .limit stack  10
  ;; (void) printBool (true bool.== true);
  ldc 1
  ldc 1
  if_icmpeq L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  invokestatic cmp_bool/printBool(Z)V
  ;; (void) printBool (true bool.== false);
  ldc 1
  ldc 0
  if_icmpeq L4
  ldc 0
  goto L5
  L4:
  ldc 1
  L5:
  invokestatic cmp_bool/printBool(Z)V
  ;; (void) printBool (true bool.!= false);
  ldc 1
  ldc 0
  if_icmpeq L6
  ldc 1
  goto L7
  L6:
  ldc 0
  L7:
  invokestatic cmp_bool/printBool(Z)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
