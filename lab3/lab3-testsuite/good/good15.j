;; BEGIN HEADER

.class public good15
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

  invokestatic good15/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  30
  ;; int i = 1;
  ldc 1
  istore 0
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (bool) true || i ++ bool.!= 45;
  ldc 1
  ifeq L0
  ldc 1
  goto L1
  L0:
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 45
  if_icmpeq L2
  ldc 1
  goto L3
  L2:
  ldc 0
  L3:
  L1:
  pop
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (bool) false || i ++ bool.>= 0;
  ldc 0
  ifeq L4
  ldc 1
  goto L5
  L4:
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 0
  if_icmpge L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  L5:
  pop
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (bool) true && i ++ bool.< 0;
  ldc 1
  ifeq L8
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 0
  if_icmplt L10
  ldc 0
  goto L11
  L10:
  ldc 1
  L11:
  goto L9
  L8:
  ldc 0
  L9:
  pop
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (bool) false && i ++ bool.> 0;
  ldc 0
  ifeq L12
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 0
  if_icmpgt L14
  ldc 0
  goto L15
  L14:
  ldc 1
  L15:
  goto L13
  L12:
  ldc 0
  L13:
  pop
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; int j = 0;
  ldc 0
  istore 1
  ;; if (34 bool.< 6 && j bool.< 0)
  ldc 34
  ldc 6
  if_icmplt L18
  ldc 0
  goto L19
  L18:
  ldc 1
  L19:
  ifeq L20
  iload 1
  ldc 0
  if_icmplt L22
  ldc 0
  goto L23
  L22:
  ldc 1
  L23:
  goto L21
  L20:
  ldc 0
  L21:
  ifeq L17
  ;; (void) printInt (i);
  iload 0
  invokestatic Runtime/printInt(I)V
  goto L16
  L17:
  ;; (void) printInt (42);
  ldc 42
  invokestatic Runtime/printInt(I)V
  L16:
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
