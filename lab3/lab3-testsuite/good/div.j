;; BEGIN HEADER

.class public div
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

  invokestatic div/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  2
  ;; (void) printInt (5 int./ 3);
  ldc 5
  ldc 3
  idiv
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
