;; BEGIN HEADER

.class public cmp
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

  invokestatic cmp/main()I
  pop
  return

.end method

;; END HEADER

.method public static printBool(Z)V
  .limit locals 1
  .limit stack  2
  ;; if (b)
  iload 0
  ifeq L1
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  goto L0
  L1:
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  L0:
  return

.end method

.method public static main()I
  .limit locals 0
  .limit stack  37
  ;; (void) printBool (30 bool.== 40);
  ldc 30
  ldc 40
  if_icmpeq L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (30 bool.== 30);
  ldc 30
  ldc 30
  if_icmpeq L4
  ldc 0
  goto L5
  L4:
  ldc 1
  L5:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (30 bool.!= 30);
  ldc 30
  ldc 30
  if_icmpeq L6
  ldc 1
  goto L7
  L6:
  ldc 0
  L7:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (40 bool.!= 40);
  ldc 40
  ldc 40
  if_icmpeq L8
  ldc 1
  goto L9
  L8:
  ldc 0
  L9:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (3 bool.> 4);
  ldc 3
  ldc 4
  if_icmpgt L10
  ldc 0
  goto L11
  L10:
  ldc 1
  L11:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (3 bool.> 3);
  ldc 3
  ldc 3
  if_icmpgt L12
  ldc 0
  goto L13
  L12:
  ldc 1
  L13:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (4 bool.< 3);
  ldc 4
  ldc 3
  if_icmplt L14
  ldc 0
  goto L15
  L14:
  ldc 1
  L15:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (4 bool.< 4);
  ldc 4
  ldc 4
  if_icmplt L16
  ldc 0
  goto L17
  L16:
  ldc 1
  L17:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (400 bool.>= 300);
  ldc 400
  ldc 300
  if_icmpge L18
  ldc 0
  goto L19
  L18:
  ldc 1
  L19:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (400 bool.>= 400);
  ldc 400
  ldc 400
  if_icmpge L20
  ldc 0
  goto L21
  L20:
  ldc 1
  L21:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (400 bool.<= 300);
  ldc 400
  ldc 300
  if_icmple L22
  ldc 0
  goto L23
  L22:
  ldc 1
  L23:
  invokestatic cmp/printBool(Z)V
  ;; (void) printBool (400 bool.<= 400);
  ldc 400
  ldc 400
  if_icmple L24
  ldc 0
  goto L25
  L24:
  ldc 1
  L25:
  invokestatic cmp/printBool(Z)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method
