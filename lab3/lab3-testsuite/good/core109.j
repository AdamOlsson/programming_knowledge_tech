;; BEGIN HEADER

.class public core109
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

  invokestatic core109/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 1
  .limit stack  1
  ;; int j = 4;
  ldc 4
  istore 0
  ;; (void) printInt (j);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) j;
  iload 0
  ireturn
  return

.end method
