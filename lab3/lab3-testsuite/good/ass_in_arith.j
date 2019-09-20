;; BEGIN HEADER

.class public ass_in_arith
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

  invokestatic ass_in_arith/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  4
  ;; int x = 50;
  ldc 50
  istore 0
  ;; int y = x ++ int.+ x --;
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  iload 0
  dup
  ldc 1
  isub
  istore 0
  iadd
  istore 1
  ;; (void) printInt (y);
  iload 1
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt ((x = 10) int.+ x ++ int.+ x);
  ldc 10
  dup
  istore 0
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  iadd
  iload 0
  iadd
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
