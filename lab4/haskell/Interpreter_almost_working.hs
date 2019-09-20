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
    
      --fail $ show mainExp
      -- Run the interpreter.
      --v <- eval mainExp `runReaderT` cxt  -- with Reader monad
      v <- eval cxt mainExp  -- without Reader monad
    
      -- Inspect the result.
      case v of
        VInt i  -> return i
        VClos{} -> Bad "main should return an integer"
    
    -- * Data structures for the interpreter.
    
    -- | Values.
    
    data Value
      = VInt  Integer
      | VClos Ident Exp Env
    -- | Context.
    
    data Cxt = Cxt
      { cxtStrategy :: Strategy  -- ^ Evaluation strategy (fixed).
      , cxtSig      :: Sig       -- ^ Binds function identifiers to expression.
      , cxtEnv      :: Env       -- ^ Binds local variables to values.
      }
    
    -- | Signature.
    
    type Sig = Map Ident Exp  -- ^ 'Exp' is closed.
    
    -- | Environment.
    
    data Entry
      = Clos Exp Env  -- ^ For call-by-name.
      | Val  Value    -- ^ For call-by-value.
    
    type Env = Map Ident Entry
    --type Env = Map Ident Value
    -- | Evaluation monad.
    
    type Eval = ReaderT Cxt Err
    
    -- * Interpreter.
    
    todo = error "not yet implemented, TODO!"
    
    -- | Evaluation.
    eval :: Cxt -> Exp -> Err Value
    eval cxt e = case e of
    
      EInt i    -> return $ VInt i
    
      EVar x    -> do
        case Map.lookup x (cxtEnv cxt) of
            -- local variables
            Just val -> evalEntry cxt val

            -- look among signatures
            Nothing    -> case Map.lookup x (cxtSig cxt) of
                Just exp -> eval (cxt { cxtEnv = Map.empty }) exp
                Nothing  -> fail $ "\nINTERPRETATION ERROR: Could not find identifier " ++ show x 

      EAbs x e  -> return $ VClos x e (cxtEnv cxt)
    
      EApp f a  -> do 
        v <- eval cxt f
        case v of 
          VClos x e env -> case cxtStrategy cxt of
            CallByValue -> do
                v' <- eval cxt a
                eval (cxt { cxtEnv = Map.insert x (Val v') env }) e
            CallByName  -> do -- THis is not working
                v' <- eval cxt (EAbs x a) -- v' is VClos
                eval (cxt { cxtEnv = Map.insert x (Val v') env }) e -- this line is not working
                
          VInt _        -> fail $ "\nINTERPRETATION ERROR: Applying non-function to expression"

      EAdd e e' -> mathOp cxt (+) e e'
      ESub e e' -> mathOp cxt (-) e e'
  
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

    evalEntry :: Cxt -> Entry -> Err Value
    evalEntry cxt (Val v)      = return v
    evalEntry cxt (Clos e env) = eval (cxt { cxtEnv = env }) e
  
    mathOp :: Cxt -> (Integer -> Integer -> Integer) -> Exp -> Exp -> Err Value
    mathOp cxt op e e' = do
      v  <- eval cxt e
      v' <- eval cxt e'
      case (v, v') of
        (VInt a, VInt b) -> return $ VInt( a `op` b)
        _                -> fail $ "\nINTERPRETATION ERROR: Could not perform mathOp"

