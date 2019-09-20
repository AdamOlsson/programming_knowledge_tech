;; BEGIN HEADER

.class public fibonacci
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

  invokestatic fibonacci/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 3
  .limit stack  6
  ;; int lo, hi, mx;
  ;; (int) lo = 1;
  ldc 1
  dup
  istore 0
  pop
  ;; (int) hi = lo;
  iload 0
  dup
  istore 1
  pop
  ;; (int) mx = 5000000;
  ldc 5000000
  dup
  istore 2
  pop
  ;; (void) printInt (lo);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; while (hi bool.< mx)
  L0:
  iload 1
  iload 2
  if_icmplt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; (void) printInt (hi);
  iload 1
  invokestatic Runtime/printInt(I)V
  ;; (int) hi = lo int.+ hi;
  iload 0
  iload 1
  iadd
  dup
  istore 1
  pop
  ;; (int) lo = hi int.- lo;
  iload 1
  iload 0
  isub
  dup
  istore 0
  pop
  goto L0
  L1:
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
