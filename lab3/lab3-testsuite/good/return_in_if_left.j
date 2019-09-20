;; BEGIN HEADER

.class public return_in_if_left
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

  invokestatic return_in_if_left/main()I
  pop
  return

.end method

;; END HEADER

.method public static g()I
  .limit locals 0
  .limit stack  2
  ;; if (true)
  ldc 1
  ifeq L1
  ;; return (int) 12;
  ldc 12
  ireturn
  goto L0
  L1:
  ;; return (int) 11;
  ldc 11
  ireturn
  L0:
  ;; return (int) 10;
  ldc 10
  ireturn
  return

.end method

.method public static main()I
  .limit locals 0
  .limit stack  1
  ;; (void) printInt (g ());
  invokestatic return_in_if_left/g()I
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
