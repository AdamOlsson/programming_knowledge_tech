;; BEGIN HEADER

.class public bool_return
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

  invokestatic bool_return/main()I
  pop
  return

.end method

;; END HEADER

.method public static c(I)Z
  .limit locals 1
  .limit stack  4
  ;; return (bool) d bool.< d;
  iload 0
  iload 0
  if_icmplt L0
  ldc 0
  goto L1
  L0:
  ldc 1
  L1:
  ireturn
  return

.end method

.method public static main()I
  .limit locals 0
  .limit stack  2
  ;; if (c (0))
  ldc 0
  invokestatic bool_return/c(I)Z
  ifeq L3
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  goto L2
  L3:
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  L2:
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
