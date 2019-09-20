;; BEGIN HEADER

.class public return_fun_val
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

  invokestatic return_fun_val/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  1
  ;; return (int) test ();
  invokestatic return_fun_val/test()I
  ireturn
  return

.end method

.method public static test()I
  .limit locals 0
  .limit stack  1
  ;; return (int) 32;
  ldc 32
  ireturn
  return

.end method
