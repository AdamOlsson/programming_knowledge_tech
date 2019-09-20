;; BEGIN HEADER

.class public if_state_propagation
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

  invokestatic if_state_propagation/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 1
  .limit stack  5
  ;; int x;
  ;; if ((x = 1) bool.== 1)
  ldc 1
  dup
  istore 0
  ldc 1
  if_icmpeq L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  goto L0
  L1:
  L0:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
