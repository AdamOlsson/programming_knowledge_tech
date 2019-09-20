;; BEGIN HEADER

.class public core103
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

  invokestatic core103/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  11
  ;; int j = 4;
  ldc 4
  istore 0
  ;; while (j bool.< 6)
  L0:
  iload 0
  ldc 6
  if_icmplt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; int i = 0;
  ldc 0
  istore 1
  ;; (int) i ++;
  iload 1
  dup
  ldc 1
  iadd
  istore 1
  pop
  ;; (void) printInt (i);
  iload 1
  invokestatic Runtime/printInt(I)V
  ;; (int) j ++;
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  pop
  goto L0
  L1:
  ;; if (j bool.< 7)
  iload 0
  ldc 7
  if_icmplt L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L5
  ;; (int) j ++;
  iload 0
  dup
  ldc 1
  iadd
  istore 0
  pop
  goto L4
  L5:
  ;; (int) j --;
  iload 0
  dup
  ldc 1
  isub
  istore 0
  pop
  L4:
  ;; (void) printInt (j);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (int) j;
  iload 0
  ireturn
  return

.end method
