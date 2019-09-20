;; BEGIN HEADER

.class public state_propagation
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

  invokestatic state_propagation/main()I
  pop
  return

.end method

;; END HEADER

.method public static id(I)I
  .limit locals 1
  .limit stack  1
  ;; return (int) x;
  iload 0
  ireturn
  return

.end method

.method public static main()I
  .limit locals 1
  .limit stack  20
  ;; int z = 0;
  ldc 0
  istore 0
  ;; (int) id (++ z);
  iload 0
  ldc 1
  iadd
  istore 0
  iload 0
  invokestatic state_propagation/id(I)I
  pop
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (int) id (z = z int.+ 1);
  iload 0
  ldc 1
  iadd
  dup
  istore 0
  invokestatic state_propagation/id(I)I
  pop
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (int) z ++ int.+ z ++;
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  iadd
  pop
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; (bool) z ++ bool.== z ++;
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  if_icmpeq L0
  ldc 0
  goto L1
  L0:
  ldc 1
  L1:
  pop
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (++ z bool.== 7)
  iload 0
  ldc 1
  iadd
  istore 0
  iload 0
  ldc 7
  if_icmpeq L4
  ldc 0
  goto L5
  L4:
  ldc 1
  L5:
  ifeq L3
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  goto L2
  L3:
  L2:
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; if (z ++ bool.== 8)
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 8
  if_icmpeq L8
  ldc 0
  goto L9
  L8:
  ldc 1
  L9:
  ifeq L7
  goto L6
  L7:
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  L6:
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; while (++ z bool.== 9)
  L10:
  iload 0
  ldc 1
  iadd
  istore 0
  iload 0
  ldc 9
  if_icmpeq L12
  ldc 0
  goto L13
  L12:
  ldc 1
  L13:
  ifeq L11
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  goto L10
  L11:
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; while (z ++ bool.== 11)
  L14:
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  ldc 11
  if_icmpeq L16
  ldc 0
  goto L17
  L16:
  ldc 1
  L17:
  ifeq L15
  goto L14
  L15:
  ;; (void) printInt (z);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
