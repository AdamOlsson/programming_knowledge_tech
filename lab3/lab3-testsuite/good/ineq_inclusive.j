;; BEGIN HEADER

.class public ineq_inclusive
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

  invokestatic ineq_inclusive/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 0
  .limit stack  17
  ;; if (0 bool.>= 0)
  ldc 0
  ldc 0
  if_icmpge L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L1
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  goto L0
  L1:
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  L0:
  ;; if (1 bool.>= 1)
  ldc 1
  ldc 1
  if_icmpge L6
  ldc 0
  goto L7
  L6:
  ldc 1
  L7:
  ifeq L5
  ;; (void) printInt (2);
  ldc 2
  invokestatic Runtime/printInt(I)V
  goto L4
  L5:
  ;; (void) printInt (3);
  ldc 3
  invokestatic Runtime/printInt(I)V
  L4:
  ;; if (2 bool.<= 2)
  ldc 2
  ldc 2
  if_icmple L10
  ldc 0
  goto L11
  L10:
  ldc 1
  L11:
  ifeq L9
  ;; (void) printInt (4);
  ldc 4
  invokestatic Runtime/printInt(I)V
  goto L8
  L9:
  ;; (void) printInt (5);
  ldc 5
  invokestatic Runtime/printInt(I)V
  L8:
  ;; if (0 bool.<= 0)
  ldc 0
  ldc 0
  if_icmple L14
  ldc 0
  goto L15
  L14:
  ldc 1
  L15:
  ifeq L13
  ;; (void) printInt (6);
  ldc 6
  invokestatic Runtime/printInt(I)V
  goto L12
  L13:
  ;; (void) printInt (7);
  ldc 7
  invokestatic Runtime/printInt(I)V
  L12:
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
