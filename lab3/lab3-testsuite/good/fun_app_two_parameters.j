;; BEGIN HEADER

.class public fun_app_two_parameters
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

  invokestatic fun_app_two_parameters/main()I
  pop
  return

.end method

;; END HEADER

.method public static abc(ZI)I
  .limit locals 2
  .limit stack  1
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static main()I
  .limit locals 0
  .limit stack  2
  ;; return (int) abc (true, 0);
  ldc 1
  ldc 0
  invokestatic fun_app_two_parameters/abc(ZI)I
  ireturn
  return

.end method
