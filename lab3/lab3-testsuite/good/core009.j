;; BEGIN HEADER

.class public core009
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

  invokestatic core009/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 1
  .limit stack  1
  ;; int x = foo ();
  invokestatic core009/foo()I
  istore 0
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static foo()I
  .limit locals 0
  .limit stack  1
  ;; return (int) 10;
  ldc 10
  ireturn
  return

.end method
