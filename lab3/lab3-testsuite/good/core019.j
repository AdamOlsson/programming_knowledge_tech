;; BEGIN HEADER

.class public core019
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

  invokestatic core019/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 4
  .limit stack  9
  ;; int i = 78;
  ldc 78
  istore 0
  ;; int i = 1;
  ldc 1
  istore 1
  ;; (void) printInt (i);
  iload 1
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; while (i bool.> 76)
  L0:
  iload 0
  ldc 76
  if_icmpgt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; (int) i --;
  iload 0
  dup
  ldc 1
  isub
  istore 0
  pop
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int i = 7;
  ldc 7
  istore 2
  ;; (void) printInt (i);
  iload 2
  invokestatic Runtime/printInt(I)V
  goto L0
  L1:
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (i bool.> 4)
  iload 0
  ldc 4
  if_icmpgt L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L5
  ;; int i = 4;
  ldc 4
  istore 3
  ;; (void) printInt (i);
  iload 3
  invokestatic Runtime/printInt(I)V
  goto L4
  L5:
  L4:
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
