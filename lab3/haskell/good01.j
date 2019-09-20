;; BEGIN HEADER

.class public good01
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

  invokestatic good01/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 3
  .limit stack  1
  ;; int x = 1;
  ldc 1
  istore 0
  ;; int y = 1;
  ldc 1
  istore 1
  ;; int i = readInt ();
  invokestatic Runtime/readInt()I
  istore 2
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn

.end method
