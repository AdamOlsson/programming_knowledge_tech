;; BEGIN HEADER

.class public good13
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

  invokestatic good13/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 4
  .limit stack  23
  ;; int n, i;
  ;; (int) n = readInt ();
  invokestatic Runtime/readInt()I
  dup
  istore 0
  pop
  ;; (int) i = 2;
  ldc 2
  dup
  istore 1
  pop
  ;; while (i bool.<= n)
  L0:
  iload 1
  iload 0
  if_icmple L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; bool iPrime = true;
  ldc 1
  istore 2
  ;; int j = 2;
  ldc 2
  istore 3
  ;; while (j int.* j bool.<= i && iPrime)
  L4:
  iload 3
  iload 3
  imul
  iload 1
  if_icmple L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L8
  iload 2
  goto L9
  L8:
  ldc 0
  L9:
  ifeq L5
  ;; if (i int./ j int.* j bool.== i)
  iload 1
  iload 3
  idiv
  iload 3
  imul
  iload 1
  if_icmpeq L12
  ldc 0
  goto L13
  L12:
  ldc 1
  L13:
  ifeq L11
  ;; (bool) iPrime = false;
  ldc 0
  dup
  istore 2
  pop
  goto L10
  L11:
  L10:
  ;; (int) j ++;
  iload 3
  dup
  ldc 1
  iadd
  istore 3
  pop
  goto L4
  L5:
  ;; if (iPrime && n int./ i int.* i bool.== n)
  iload 2
  ifeq L16
  iload 0
  iload 1
  idiv
  iload 1
  imul
  iload 0
  if_icmpeq L18
  ldc 0
  goto L19
  L18:
  ldc 1
  L19:
  goto L17
  L16:
  ldc 0
  L17:
  ifeq L15
  ;; (void) printInt (i);
  iload 1
  invokestatic Runtime/printInt(I)V
  ;; (int) n = n int./ i;
  iload 0
  iload 1
  idiv
  dup
  istore 0
  pop
  goto L14
  L15:
  ;; (int) i ++;
  iload 1
  dup
  ldc 1
  iadd
  istore 1
  pop
  L14:
  goto L0
  L1:
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
