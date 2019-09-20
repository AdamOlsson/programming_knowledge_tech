;; BEGIN HEADER

.class public redeclare_after_if
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

  invokestatic redeclare_after_if/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 2
  .limit stack  5
  ;; if (0 bool.<= 2)
  ldc 0
  ldc 2
  if_icmple L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; bool x0 = true;
  ldc 1
  istore 0
  goto L0
  L1:
  ;; (int) 0;
  ldc 0
  pop
  L0:
  ;; int x0 = 0;
  ldc 0
  istore 1
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
