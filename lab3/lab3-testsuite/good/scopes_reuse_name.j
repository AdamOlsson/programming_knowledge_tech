;; BEGIN HEADER

.class public scopes_reuse_name
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

  invokestatic scopes_reuse_name/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 11
  .limit stack  14
  ;; int x = 0;
  ldc 0
  istore 0
  ;; if (true)
  ldc 1
  ifeq L1
  ;; int x = 1;
  ldc 1
  istore 1
  goto L0
  L1:
  L0:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (true)
  ldc 1
  ifeq L3
  ;; int x;
  ;; (int) x = 2;
  ldc 2
  dup
  istore 2
  pop
  goto L2
  L3:
  L2:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (false)
  ldc 0
  ifeq L5
  goto L4
  L5:
  ;; int x = 3;
  ldc 3
  istore 3
  L4:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (false)
  ldc 0
  ifeq L7
  goto L6
  L7:
  ;; int x;
  ;; (int) x = 4;
  ldc 4
  dup
  istore 4
  pop
  L6:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int i = 0;
  ldc 0
  istore 5
  ;; while (i ++ bool.< 1)
  L8:
  iload 5
  dup
  ldc 1
  iadd
  istore 5
  ldc 1
  if_icmplt L10
  ldc 0
  goto L11
  L10:
  ldc 1
  L11:
  ifeq L9
  ;; int x = 5;
  ldc 5
  istore 6
  goto L8
  L9:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int i = 0;
  ldc 0
  istore 7
  ;; while (i ++ bool.< 1)
  L12:
  iload 7
  dup
  ldc 1
  iadd
  istore 7
  ldc 1
  if_icmplt L14
  ldc 0
  goto L15
  L14:
  ldc 1
  L15:
  ifeq L13
  ;; int x;
  ;; (int) x = 6;
  ldc 6
  dup
  istore 8
  pop
  goto L12
  L13:
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int x = 7;
  ldc 7
  istore 9
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int x;
  ;; (int) x = 8;
  ldc 8
  dup
  istore 10
  pop
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
