;; BEGIN HEADER

.class public large_program_fac
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

  invokestatic large_program_fac/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  1
  ;; (void) printInt (fac (10));
  ldc 10
  invokestatic large_program_fac/fac(I)I
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (rfac (10));
  ldc 10
  invokestatic large_program_fac/rfac(I)I
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (mfac (10));
  ldc 10
  invokestatic large_program_fac/mfac(I)I
  invokestatic Runtime/printInt(I)V
  ;; (void) printInt (ifac (10));
  ldc 10
  invokestatic large_program_fac/ifac(I)I
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static fac(I)I
  .limit locals 3
  .limit stack  6
  ;; int r;
  ;; int n;
  ;; (int) r = 1;
  ldc 1
  dup
  istore 1
  pop
  ;; (int) n = a;
  iload 0
  dup
  istore 2
  pop
  ;; while (n bool.> 0)
  L0:
  iload 2
  ldc 0
  if_icmpgt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; (int) r = r int.* n;
  iload 1
  iload 2
  imul
  dup
  istore 1
  pop
  ;; (int) n = n int.- 1;
  iload 2
  ldc 1
  isub
  dup
  istore 2
  pop
  goto L0
  L1:
  ;; return (int) r;
  iload 1
  ireturn
  return

.end method

.method public static rfac(I)I
  .limit locals 2
  .limit stack  7
  ;; int f;
  ;; if (n bool.== 0)
  iload 0
  ldc 0
  if_icmpeq L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L5
  ;; (int) f = 1;
  ldc 1
  dup
  istore 1
  pop
  goto L4
  L5:
  ;; (int) f = n int.* rfac (n int.- 1);
  iload 0
  iload 0
  ldc 1
  isub
  invokestatic large_program_fac/rfac(I)I
  imul
  dup
  istore 1
  pop
  L4:
  ;; return (int) f;
  iload 1
  ireturn
  return

.end method

.method public static mfac(I)I
  .limit locals 2
  .limit stack  7
  ;; int f;
  ;; if (n bool.== 0)
  iload 0
  ldc 0
  if_icmpeq L10
  ldc 0
  goto L11
  L10:
  ldc 1
  L11:
  ifeq L9
  ;; (int) f = 1;
  ldc 1
  dup
  istore 1
  pop
  goto L8
  L9:
  ;; (int) f = n int.* nfac (n int.- 1);
  iload 0
  iload 0
  ldc 1
  isub
  invokestatic large_program_fac/nfac(I)I
  imul
  dup
  istore 1
  pop
  L8:
  ;; return (int) f;
  iload 1
  ireturn
  return

.end method

.method public static nfac(I)I
  .limit locals 2
  .limit stack  6
  ;; int f;
  ;; if (n bool.!= 0)
  iload 0
  ldc 0
  if_icmpeq L14
  ldc 1
  goto L15
  L14:
  ldc 0
  L15:
  ifeq L13
  ;; (int) f = mfac (n int.- 1) int.* n;
  iload 0
  ldc 1
  isub
  invokestatic large_program_fac/mfac(I)I
  iload 0
  imul
  dup
  istore 1
  pop
  goto L12
  L13:
  ;; (int) f = 1;
  ldc 1
  dup
  istore 1
  pop
  L12:
  ;; return (int) f;
  iload 1
  ireturn
  return

.end method

.method public static ifac(I)I
  .limit locals 1
  .limit stack  2
  ;; return (int) ifac2f (1, n);
  ldc 1
  iload 0
  invokestatic large_program_fac/ifac2f(II)I
  ireturn
  return

.end method

.method public static ifac2f(II)I
  .limit locals 4
  .limit stack  11
  ;; int f;
  ;; if (l bool.== h)
  iload 0
  iload 1
  if_icmpeq L18
  ldc 0
  goto L19
  L18:
  ldc 1
  L19:
  ifeq L17
  ;; (int) f = l;
  iload 0
  dup
  istore 2
  pop
  goto L16
  L17:
  ;; if (l bool.> h)
  iload 0
  iload 1
  if_icmpgt L22
  ldc 0
  goto L23
  L22:
  ldc 1
  L23:
  ifeq L21
  ;; (int) f = 1;
  ldc 1
  dup
  istore 2
  pop
  goto L20
  L21:
  ;; int m;
  ;; (int) m = (l int.+ h) int./ 2;
  iload 0
  iload 1
  iadd
  ldc 2
  idiv
  dup
  istore 3
  pop
  ;; (int) f = ifac2f (l, m) int.* ifac2f (m int.+ 1, h);
  iload 0
  iload 3
  invokestatic large_program_fac/ifac2f(II)I
  iload 3
  ldc 1
  iadd
  iload 1
  invokestatic large_program_fac/ifac2f(II)I
  imul
  dup
  istore 2
  pop
  L20:
  L16:
  ;; return (int) f;
  iload 2
  ireturn
  return

.end method
