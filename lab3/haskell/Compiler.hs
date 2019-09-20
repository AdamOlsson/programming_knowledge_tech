{-# OPTIONS_GHC -Wunused-top-binds #-}

{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}

module Compiler where

import Control.Monad
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.RWS

import Data.Maybe
import Data.Map (Map)
import qualified Data.Map as Map

import Data.Char

import Annotated
import CPP.Abs (Type(..), Id(..), Arg(..))

data St = St
	{ cxt           :: Cxt   -- ^ Context.
	, limitLocals   :: Int   -- ^ Maximal size for locals encountered.
	, currentStack  :: Int   -- ^ Current stack size.
	, limitStack    :: Int   -- ^ Maximal stack size encountered.
	, nextLabel     :: Label -- ^ Next jump label (persistent part of state)
	}

type Sig = Map Id Fun

-- | Function names bundled with their type
data Fun = Fun { funId :: Id, funFunType :: FunType }
	deriving Show

data FunType = FunType {funRet :: Type, funParse :: [Type]}
	deriving Show

type Cxt = [Map Id Var] -- map is easier than list of tuples
type Var = (Addr, Type) -- course book p.111

newtype Label = L { theLabel :: Int }
	deriving (Eq, Enum)

instance Show Label where
	show (L n) = "L" ++ show n

initSt :: St
initSt = St
	{ cxt = [Map.empty]
	, limitLocals   = 0
	, currentStack  = 0
	, limitStack    = 0
	, nextLabel     = L 0
	}

type Output = [String]

type Compile = RWS Sig Output St

-- | Builtin-functions
builtin :: [(Id, Fun)]
builtin =
	[ 	(Id "printInt"   , Fun (Id "Runtime/printInt"   ) $ FunType Type_void [Type_int]),
		(Id "readInt"    , Fun (Id "Runtime/readInt"    ) $ FunType  Type_int  [])
	]

-- | Entry point.

compile
	:: String  -- ^ Class name.
	-> Program -- ^ Type-annotated program.
	-> String  -- ^ Generated jasmin source file content.
compile name prg@(PDefs defs) = unlines w where
	sigEntry def@(DFun _ f@(Id x) _ _ ) = (f, Fun (Id $ name ++ "/" ++ x) $ funType def)
	sig = Map.fromList $ builtin ++ map sigEntry defs 
	w   = snd $ evalRWS (compileProgram name prg) sig initSt

compileProgram :: String -> Program -> Compile ()
compileProgram name (PDefs defs) = do
	tell header
	mapM_ compileFun defs
	where
		header =
			[ ";; BEGIN HEADER"
			, ""
			, ".class public " ++ name
			, ".super java/lang/Object"
			, ""
			, ".method public <init>()V"
			, "  .limit locals 1"
			, ""
			, "  aload_0"
			, "  invokespecial java/lang/Object/<init>()V"
			, "  return"
			, ""
			, ".end method"
			, ""
			, ".method public static main([Ljava/lang/String;)V"
			, "  .limit locals 1"
			, "  .limit stack  1"
			, ""
			, "  invokestatic " ++ name ++ "/main()I"
			, "  pop"
			, "  return"
			, ""
			, ".end method"
			, ""
			, ";; END HEADER"
			]

compileFun :: Def -> Compile ()
compileFun def@(DFun t f args ss) = do
	-- function header
	tell [ "", ".method public static " ++ toJVM (Fun f $ funType def) ]

	-- prepare environment
	lab <- gets nextLabel 
	put initSt{ nextLabel = lab }
	mapM_ (\ (ADecl t' x) -> newVar x t') args

	-- compile statements
	pushNewContext
	w <- grabOutput $ do
		mapM_ compileStm ss
	popContext

	-- output limits
	ll <- gets limitLocals
	ls <- gets limitStack
	tell [ "  .limit locals " ++ show ll
		, "  .limit stack  " ++ show ls
		]

	-- output code, indented by 2
	tell $ map (\ s -> if null s then s else "  " ++ s) w
	-- return stm for void functions
	case t of 
		type_void -> do 
			tell ["  return"]
		_ 		  -> do
			if f == (Id "main")
				then tell ["  ireturn"]
				else tell [""]
	
	tell [ "", ".end method"]

compileStm :: Stm -> Compile ()
compileStm s = do

	-- Printing a comment
	let top = stmTop s
	let nyi = error $ "TODO: " ++ top
	tell $ map (";; " ++) $ lines top
	case s of
		SInit typ id exp -> do
			newVar id typ
			compileExp exp
			(addr, _) <- lookupVar id
			emit $ Store typ addr

		SReturn typ exp -> do
			compileExp exp
			emit $ Return typ
	
		SExp typ exp -> do
			compileExp exp
			emit $ Pop typ

		SDecls typ ids -> mapM_ (\ id -> newVar id typ) ids

		SBlock ss -> do
			pushNewContext
			mapM_ compileStm ss
			popContext

		SWhile e s1 -> do
			start <- newLabel
			done  <- newLabel
			emit $ Label start
			compileExp e
			pushNewContext
			emit $ IfEq done
			compileStm s1
			popContext
			emit $ Goto start
			emit $ Label done
		
		SIfElse exp stm stm' -> do
			start <- newLabel
			done <- newLabel
			compileExp exp
			emit $ IfEq done
			pushNewContext
			compileStm stm
			popContext
			emit $ Goto start
			emit $ Label done
			pushNewContext
			compileStm stm'
			popContext
			emit $ Label start

		_ -> nyi



compileExp :: Exp -> Compile ()
compileExp e = do
  case e of
		ETrue 	-> emit $ IConst 1 -- Bools can be treated as Integers
		EFalse 	-> emit $ IConst 0
		 
		EInt i -> do
			emit $ IConst i

		EId id -> do
			(addr, typ) <- lookupVar id
			emit $ Load typ addr

		EApp f es -> do
			mapM_ compileExp es
			sig <- ask
			let fun = fromMaybe (error "unbound function") $  Map.lookup f sig
			emit $ Call fun
		
		EPostIncr id -> do
			(addr, typ) <- lookupVar id
			emit $ Load typ addr
			emit $ Dup 
			emit $ IConst 1
			emit $ Add typ
			emit $ Store typ addr

		EPostDecr id -> do
			(addr, typ) <- lookupVar id
			emit $ Load typ addr
			emit $ Dup
			emit $ IConst 1
			emit $ Sub typ
			emit $ Store typ addr 

		EPreIncr id -> do
			(addr, typ) <- lookupVar id
			emit $ Load typ addr
			emit $ IConst 1
			emit $ Add typ
			emit $ Store typ addr
			emit $ Load typ addr

		EPreDecr id 		 -> do
			(addr, typ) <- lookupVar id
			emit $ Load typ addr
			emit $ IConst 1
			emit $ Sub typ
			emit $ Store typ addr
			emit $ Load typ addr

		ETimes  typ exp exp' -> do
			compileExp exp
			compileExp exp'
			emit $ Mul typ

		EDiv typ exp exp' 	 -> do
			compileExp exp
			compileExp exp'
			emit $ Div typ

		EPlus typ exp exp' 	 -> do
			compileExp exp
			compileExp exp'
			emit $ Add typ

		EMinus typ exp exp'  -> do
			compileExp exp
			compileExp exp'
			emit $ Sub typ

		ELt typ exp exp'     -> do -- can probably remake this better, multiple equal calls...
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpLt yes
			emit $ IConst 0
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 1
			emit $ Label done
		
		EGt typ exp exp'    -> do
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpGt yes
			emit $ IConst 0
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 1
			emit $ Label done

		ELtEq typ exp exp' -> do
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpLe yes
			emit $ IConst 0
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 1
			emit $ Label done

		EGtEq typ exp exp' -> do
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpGe yes
			emit $ IConst 0
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 1
			emit $ Label done

		EEq typ exp exp' -> do
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpEq yes
			emit $ IConst 0
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 1
			emit $ Label done

		ENEq typ exp exp' -> do
			compileExp exp
			compileExp exp'
			yes  <- newLabel
			done <- newLabel
			emit $ IfCmpNe yes
			emit $ IConst 1
			emit $ Goto done
			emit $ Label yes
			emit $ IConst 0
			emit $ Label done

		EAnd exp exp' -> do
			compileExp exp
			jumpLab <- newLabel
			endLab <- newLabel
			emit $ IfEq jumpLab
			compileExp exp'
			emit $ Goto endLab
			emit $ Label jumpLab
			emit $ IConst 0
			emit $ Label endLab


		EOr exp exp' -> do
			compileExp exp
			jumpLab <- newLabel
			endLab <- newLabel
			emit $ IfEq jumpLab
			emit $ IConst 1
			emit $ Goto endLab
			emit $ Label jumpLab
			compileExp exp'
			emit $ Label endLab

		EAss id exp -> do
			compileExp exp
			emit $ Dup
			(a, t) <- lookupVar id
			emit $ Store t a


-- * Instructions and emitting

type Addr = Int

data Code
	= Store Type Addr  -- ^ Store stack content of type @Type@ in local variable @Addr@.
	| Load  Type Addr  -- ^ Push stack content of type @Type@ from local variable @Addr@.
	| IConst Integer   -- ^ Put integer constant on the stack.
	| Pop Type         -- ^ Pop something of type @Type@ from the stack.
	| Return Type      -- ^ Return from method of type @Type@.
	| Add Type         -- ^ Add 2 top values of stack.
	| Sub Type
	| Mul Type
	| Div Type 		   --   Int division could result in a double...
	| Dup 		   --   Duplicate the top value of the stack
	| Call Fun         -- ^ Call function.
	| Label 	Label      	-- ^ Define label.
	| Goto 		Label       -- ^ Jump to label.
	| IfLt 		Label  		-- ^ If prev <  top, jump.
	| IfGt 		Label
	| IfLtEq  	Label
	| IfGtEq  	Label
	| IfEq 		Label 
	| IfNEq 	Label
    | IfCmpNe   Label
    | IfCmpEq   Label
    | IfCmpGe   Label
    | IfCmpGt   Label
    | IfCmpLe   Label
	| IfCmpLt   Label
	

-- | Print a single instruction.  Also update stack limits
emit :: Code -> Compile ()
emit (Pop Type_void) = return ()
emit c = do
	tell [toJVM c] -- print line of code executed
	case c of
		Store typ addr -> case typ of
			Type_void -> return ()
			_ -> popStack typ
		Load typ addr -> case typ of 
			Type_void -> return ()
			_ -> pushStack typ
		Return typ 	-> popStack typ
		Call fun 	-> popStack fun
		IConst n 	-> pushStack Type_int
		Add typ  	-> popStack typ
		Sub typ 	-> popStack typ
		Mul typ 	-> popStack typ
		Div typ 	-> popStack typ
		Dup   		-> pushStack Type_int
		Pop typ  	-> popStack typ
		_			-> return () 	-- comparisons and label doesn't change stack size


------- Stack modifications -------

{-
http://learnyouahaskell.com/types-and-typeclasses#typeclasses-101
Using typeclasses we can send in something derived from our Size class
	** Just make sure the Size class is defined for that typ **
-}

-- increase the stack pointer
pushStack :: Size a => a -> Compile ()
pushStack typ = changeStackSize (size typ)

-- decrease the stack pointer
popStack :: Size a => a -> Compile ()
popStack typ = changeStackSize (0 - (size typ))

-- change the stack pointer and increase limit if needed
changeStackSize:: Int -> Compile ()
changeStackSize n = do
	newStackSize <- fmap (n+) (gets currentStack)
	limStack <- gets limitStack
	when (limStack < newStackSize)
		(modify (\ stack -> stack {limitStack = newStackSize}))
	modify (\ stack -> stack {currentStack = newStackSize})

-- size class, defined similar to toJVM class
class Size a where
	size :: a -> Int

instance Size Fun where
	size (Fun _ fTyp) = size fTyp

-- No need to allocate stack size for return value in new function
-- will be done in the parent function
instance Size FunType where
	size (FunType retTyp argTyps) = sum (map size argTyps) - size retTyp

-- values taken from course book p.115
instance Size Type where
	size typ = case typ of
		Type_void   -> 0
		Type_bool   -> 1
		Type_int    -> 1
-------------------------------------
------- Context modifications -------

pushNewContext :: Compile ()
pushNewContext = do
	cs <- gets cxt
	modify $ \ stack -> stack { cxt = (Map.empty):cs}

popContext :: Compile ()
popContext = do
	(c:cs) <- gets cxt
	modify $ \ stack -> stack {cxt = cs}

-------------------------------------
-- * Labels

newLabel :: Compile Label
newLabel = do
	l <- gets nextLabel
	modify $ \ st -> st { nextLabel = succ l }
	return $ l

-- | Print top part of statement (for comments)

stmTop :: Stm -> String
stmTop s =
	case s of
		SWhile e _ -> "while (" ++ printTree e ++ ")"
		SIfElse e _ _  -> "if (" ++ printTree e ++ ")"
		SBlock _   -> ""
		_ -> printTree s

-- * Auxiliary functions
-- from lecture
grabOutput :: Compile () -> Compile Output
grabOutput m = do
	r <- ask
	s  <- get
	let ((), s', w) = runRWS m r s
	put s'
	return w

-- * Auxiliary functions

funType :: Def -> FunType
funType (DFun t _ args _) = FunType t $ map (\ (ADecl t' _) -> t') args

class ToJVM a where
	toJVM :: a -> String

instance ToJVM Fun where
	toJVM (Fun (Id f) funTyp) = f ++ toJVM funTyp

instance ToJVM FunType where
	toJVM (FunType retTyp argTyps) = "(" ++ (toJVM =<< argTyps) ++ ")" ++ toJVM retTyp

-- course book p.119
instance ToJVM Type where
	toJVM t = case t of
		Type_void   -> "V"
		Type_int    -> "I"
		Type_bool   -> "Z"

instance ToJVM Code where
	toJVM c = case c of 
		Call 	f 		-> "invokestatic " ++ toJVM f -- as in class header
		Load 	typ addr-> "iload " ++ show addr
		Store 	typ addr-> "istore "++ show addr
		Add 	typ 	-> "iadd"
		Sub 	typ 	-> "isub"
		Mul		typ		-> "imul"
		Div 	typ		-> "idiv"
		Dup 	 		-> "dup"
		Pop 	typ		-> "pop"
		IConst  n		-> "ldc " 	++ show n
		Return  typ  	-> "ireturn"
		Label 	 lab 	-> show lab ++ ":"
		Goto 	 lab   	-> "goto " 	++ show lab
		IfLt 	 lab 	-> "iflt "	++ show lab
		IfGt 	 lab	-> "ifgt "	++ show lab
		IfLtEq 	 lab	-> "iflteq " ++ show lab
		IfGtEq	lab		-> "ifgteq " ++ show lab
		IfEq	lab		-> "ifeq "   ++ show lab
		IfNEq	lab		-> "ifneq "  ++ show lab
		IfCmpNe	lab 	-> "if_icmpeq "  ++ show lab
		IfCmpEq	lab 	-> "if_icmpeq "  ++ show lab
		IfCmpGe	lab 	-> "if_icmpge "  ++ show lab
		IfCmpGt	lab 	-> "if_icmpgt "  ++ show lab
		IfCmpLe	lab 	-> "if_icmple "  ++ show lab
		IfCmpLt	lab 	-> "if_icmplt "  ++ show lab

-- add all local var to the top of the stack and increase the limit local
newVar :: Id -> Type -> Compile ()
newVar id typ = do
	c:cs <- gets cxt
	limloc <- gets limitLocals
	modify $ \ st -> st {cxt = ((Map.insert id (limloc, typ) c ):cs), limitLocals = limloc + 1}

------- Find a variable in a context -------
-- initates recursion
lookupVar :: Id -> Compile (Addr, Type)
lookupVar id = do
	cxt <- gets cxt
	lookupVar' id cxt

-- makes the recursion
lookupVar' :: Id -> Cxt -> Compile (Addr, Type)
lookupVar' _ []     = fail "lookupVar': Variable not found in any context."
lookupVar' id (c:cs)  = case Map.lookup id c of
	Nothing -> lookupVar' id cs
	Just (addr, typ) -> return (addr, typ)
---------------------------------------------