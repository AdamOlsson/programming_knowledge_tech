;; BEGIN HEADER

.class public ass_var_to_var
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

  invokestatic ass_var_to_var/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  1
  ;; int x = 0;
  ldc 0
  istore 0
  ;; int y = x;
  iload 0
  istore 1
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
