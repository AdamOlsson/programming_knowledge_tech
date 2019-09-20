;; BEGIN HEADER

.class public core017
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

  invokestatic core017/main()I
  pop
  return

.end method

;; END HEADER

.method public static main()I
  .limit locals 1
  .limit stack  27
  ;; int x = 4;
  ldc 4
  istore 0
  ;; if (3 bool.<= x && 4 bool.!= 2 && true)
  ldc 3
  iload 0
  if_icmple L2
  ldc 0
  goto L3
  L2:
  ldc 1
  L3:
  ifeq L4
  ldc 4
  ldc 2
  if_icmpeq L6
  ldc 1
  goto L7
  L6:
  ldc 0
  L7:
  goto L5
  L4:
  ldc 0
  L5:
  ifeq L8
  ldc 1
  goto L9
  L8:
  ldc 0
  L9:
  ifeq L1
  ;; (void) printBool (true);
  ldc 1
  invokestatic core017/printBool(Z)V
  goto L0
  L1:
  L0:
  ;; (void) printBool (eq_bool (true, true) || dontCallMe (1));
  ldc 1
  ldc 1
  invokestatic core017/eq_bool(ZZ)Z
  ifeq L10
  ldc 1
  goto L11
  L10:
  ldc 1
  invokestatic core017/dontCallMe(I)Z
  L11:
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (4 bool.> 50 && dontCallMe (2));
  ldc 4
  ldc 50
  if_icmpgt L12
  ldc 0
  goto L13
  L12:
  ldc 1
  L13:
  ifeq L14
  ldc 2
  invokestatic core017/dontCallMe(I)Z
  goto L15
  L14:
  ldc 0
  L15:
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (4 bool.== x && eq_bool (true, false) && true);
  ldc 4
  iload 0
  if_icmpeq L16
  ldc 0
  goto L17
  L16:
  ldc 1
  L17:
  ifeq L18
  ldc 1
  ldc 0
  invokestatic core017/eq_bool(ZZ)Z
  goto L19
  L18:
  ldc 0
  L19:
  ifeq L20
  ldc 1
  goto L21
  L20:
  ldc 0
  L21:
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (implies (false, false));
  ldc 0
  ldc 0
  invokestatic core017/implies(ZZ)Z
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (implies (false, true));
  ldc 0
  ldc 1
  invokestatic core017/implies(ZZ)Z
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (implies (true, false));
  ldc 1
  ldc 0
  invokestatic core017/implies(ZZ)Z
  invokestatic core017/printBool(Z)V
  ;; (void) printBool (implies (true, true));
  ldc 1
  ldc 1
  invokestatic core017/implies(ZZ)Z
  invokestatic core017/printBool(Z)V
  ;; return (int) 0;
  ldc 0
  ireturn
  return

.end method

.method public static dontCallMe(I)Z
  .limit locals 1
  .limit stack  1
  ;; (void) printInt (x);
  iload 0
  invokestatic Runtime/printInt(I)V
  ;; return (bool) true;
  ldc 1
  ireturn
  return

.end method

.method public static printBool(Z)V
  .limit locals 1
  .limit stack  2
  ;; if (b)
  iload 0
  ifeq L23
  ;; (void) printInt (1);
  ldc 1
  invokestatic Runtime/printInt(I)V
  goto L22
  L23:
  ;; (void) printInt (0);
  ldc 0
  invokestatic Runtime/printInt(I)V
  L22:
  return

.end method

.method public static implies(ZZ)Z
  .limit locals 2
  .limit stack  4
  ;; return (bool) not (x) || eq_bool (x, y);
  iload 0
  invokestatic core017/not(Z)Z
  ifeq L24
  ldc 1
  goto L25
  L24:
  iload 0
  iload 1
  invokestatic core017/eq_bool(ZZ)Z
  L25:
  ireturn
  return

.end method

.method public static not(Z)Z
  .limit locals 2
  .limit stack  3
  ;; bool r;
  ;; if (x)
  iload 0
  ifeq L27
  ;; (bool) r = false;
  ldc 0
  dup
  istore 1
  pop
  goto L26
  L27:
  ;; (bool) r = true;
  ldc 1
  dup
  istore 1
  pop
  L26:
  ;; return (bool) r;
  iload 1
  ireturn
  return

.end method

.method public static eq_bool(ZZ)Z
  .limit locals 3
  .limit stack  3
  ;; bool r;
  ;; if (x)
  iload 0
  ifeq L29
  ;; (bool) r = y;
  iload 1
  dup
  istore 2
  pop
  goto L28
  L29:
  ;; (bool) r = not (y);
  iload 1
  invokestatic core017/not(Z)Z
  dup
  istore 2
  pop
  L28:
  ;; return (bool) r;
  iload 2
  ireturn
  return

.end method
