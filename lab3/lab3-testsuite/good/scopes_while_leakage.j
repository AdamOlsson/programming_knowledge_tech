;; BEGIN HEADER

.class public scopes_while_leakage
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

  invokestatic scopes_while_leakage/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 4
  .limit stack  8
  ;; bool var = true;
  ldc 1
  istore 0
  ;; int n = 0;
  ldc 0
  istore 1
  ;; while (n ++ bool.< 1)
  L0:
  iload 1
  dup
  ldc 1
  iadd
  istore 1
  ldc 1
  if_icmplt L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; int var = 1;
  ldc 1
  istore 2
  goto L0
  L1:
  ;; (bool) var bool.== true;
  iload 0
  ldc 1
  if_icmpeq L4
  ldc 0
  goto L5
  L4:
  ldc 1
  L5:
  pop
  ;; bool var2 = var;
  iload 0
  istore 3
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
