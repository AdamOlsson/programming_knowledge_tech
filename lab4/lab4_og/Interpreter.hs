-- | Interpreter for lambda-calculus with if, +, -, <.
--
--   Strategy can be either call-by-value or call-by-name.

module Interpreter where

    import Control.Applicative
    import Control.Monad.Reader
    
    import Data.Functor
    import Data.Map (Map)
    import qualified Data.Map as Map
    
    import Fun.Abs
    import Fun.ErrM
    import Fun.Print
    
    -- | Evaluation strategy.
    
    data Strategy
      = CallByName
      | CallByValue
    
    -- | Entry point: Program computes a number.
    
    interpret :: Strategy -> Program -> Err Integer
    interpret strategy (Prog defs (DMain mainExp)) = do
    
      -- Create initial environment
      let defToSigEntry (DDef f xs e) = (f, foldr EAbs e xs)
      let sig = Map.fromList (map defToSigEntry defs)
      let cxt = Cxt
            { cxtStrategy = strategy
            , cxtSig      = sig
            , cxtEnv      = Map.empty
            }
    
      -- Run the interpreter.
      --v <- eval mainExp `runReaderT` cxt  -- with Reader monad
      v <- eval cxt mainExp  -- without Reader monad
    
      -- Inspect the result.
      case v of
        VInt i  -> return i
        VClos{} -> Bad "main should return an integer"
    
    -- * Data structures for the interpreter.
    -- | Context.
    
    data Cxt = Cxt
      { cxtStrategy :: Strategy  -- ^ Evaluation strategy (fixed).
      , cxtSig      :: Sig       -- ^ Binds function identifiers to expression.
      , cxtEnv      :: Env       -- ^ Binds local variables to values.
      }
    
    -- | Signature.
    
    type Sig = Map Ident Exp  -- ^ 'Exp' is closed.
    type Env = Map Ident Value

    data Value
      = VInt  Integer
      | VClos Ident Exp Env

    {-
    data Entry
      = Clos Exp Env  -- ^ For call-by-name.
      | Val  Value    -- ^ For call-by-value.
    -}
    
    -- | Evaluation monad.
    
    --type Eval = ReaderT Cxt Err
    
    -- * Interpreter.
    
    todo = error "not yet implemented, TODO!"
    
    -- | Evaluation.
    eval :: Cxt -> Exp -> Err Value
    eval cxt e = case e of
    
      EInt i    -> return $ VInt i
      EAdd e e' -> mathOp cxt (+) e e'
      ESub e e' -> mathOp cxt (-) e e'
      EAbs x e  -> return $ VClos x e (cxtEnv cxt)

      EApp f a  -> do 
        v <- eval cxt f
        case v of 
          VClos x e env -> case cxtStrategy cxt of
            CallByValue -> do
                v' <- eval cxt a
                eval (cxt { cxtEnv = (Map.insert x v' env)}) e
            CallByName  -> do
                v' <- eval cxt (EAbs x a)
                eval (cxt { cxtEnv = (Map.insert x v' env)}) e
          VInt _        -> fail $ "\nINTERPRETATION ERROR: Applying non-function to expression"

      EVar x    -> do
        case Map.lookup x (cxtEnv cxt) of
            -- local variables
            Just val -> do
                case cxtStrategy cxt of
                    CallByValue -> return val
                    CallByName -> case val of
                        VInt _  -> return val
                        VClos x' f env' -> eval (cxt { cxtEnv = env'}) f
            -- look amongst signatures
            Nothing    -> do
                case Map.lookup x (cxtSig cxt) of
                    Just exp -> eval (cxt { cxtEnv = Map.empty}) exp
                    Nothing  -> fail $ "\nINTERPRETATION ERROR: Could not find identifier " ++ show x 
      
      ELt  e e' -> do
        v  <- eval cxt e
        v' <- eval cxt e'
        case (v, v') of
          (VInt a, VInt b) -> if a < b then return $ VInt 1 else return $ VInt 0
          _                -> fail $ "\nINTERPRETATION ERROR: Could not evaluate '<'"
      
      EIf c t e -> do
        v <- eval cxt c
        case v of 
          VInt a -> if a == 1 then eval cxt t else eval cxt e
          _      -> fail $ "\nINTERPRETATION ERROR: If statement did not evaluate to Int"
  
    -- | Evaluation of an environment entry.

    --evalEntry :: Cxt -> Entry -> Err Value
    --evalEntry cxt (Val v)      = return v
    --evalEntry cxt (Clos e env) = eval (cxt { cxtEnv = env }) e
  
    mathOp :: Cxt -> (Integer -> Integer -> Integer) -> Exp -> Exp -> Err Value
    mathOp cxt op e e' = do
      v  <- eval cxt e
      v' <- eval cxt e'
      case (v, v') of
        (VInt a, VInt b) -> return $ VInt( a `op` b)
        _                -> fail $ "\nINTERPRETATION ERROR: Could not perform mathOp"