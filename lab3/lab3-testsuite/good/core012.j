;; BEGIN HEADER

.class public core012
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

  invokestatic core012/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  2
  ;; int x = 56;
  ldc 56
  istore 0
  ;; int y = 23;
  ldc 23
  istore 1
  ;; (void) printInt (x int.+ y);
  iload 0
  iload 1
  iadd
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (x int.- y);
  iload 0
  iload 1
  isub
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (x int.* y);
  iload 0
  iload 1
  imul
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (45 int./ 2);
  ldc 45
  ldc 2
  idiv
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
