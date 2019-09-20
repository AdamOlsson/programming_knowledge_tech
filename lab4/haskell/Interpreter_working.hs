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
      v <- eval mainExp `runReaderT` cxt  -- with Reader monad
      --v <- eval cxt mainExp  -- without Reader monad
    
      -- Inspect the result.
      case v of
        VInt i  -> return i
        VClos{} -> Bad "main should return an integer"
    
    -- * Data structures for the interpreter.
    
    -- | Values.
    
    data Value
      = VInt  Integer
      | VClos Ident Exp Env
      deriving (Show)
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
    
    --type Env = Map Ident Entry
    type Env = Map Ident Value
    -- | Evaluation monad.
    
    type Eval = ReaderT Cxt Err
    
    -- * Interpreter.
    
    todo = error "not yet implemented, TODO!"
    
    -- | Evaluation.
    eval :: Exp -> Eval Value
    eval e = case e of
    
      EInt i    -> return $ VInt i

      EVar x    -> do
        env <- asks cxtEnv
        case Map.lookup x env of
            -- local variables
            Just val -> do
                --fail $ show val
                strat <- asks cxtStrategy
                case strat of
                    CallByValue -> return val
                    CallByName -> case val of
                        VInt _  -> return val
                        VClos x' f env' -> evalValue env' $ eval f  
            -- look among signatures
            Nothing    -> do
                sig <- asks cxtSig
                case Map.lookup x sig of
                    Just exp -> evalValue Map.empty $ eval exp
                    Nothing  -> fail $ "\nINTERPRETATION ERROR: Could not find identifier " ++ show x 
               
      EAbs x e  -> do
        env <- asks cxtEnv
        return $ VClos x e env
    
      EApp f a  -> do 
        v <- eval f
        strat <- asks cxtStrategy
        case v of 
          VClos x e env -> case strat of
            CallByValue -> do
                v' <- eval a
                evalValue (Map.insert x v' env) $ eval e
            CallByName  -> do
                v' <- eval (EAbs x a)
                evalValue (Map.insert x v' env) $ eval e
          VInt{}        -> fail $ "\nINTERPRETATION ERROR: Applying non-function to expression"
    
      EAdd e e' -> mathOp (+) e e'
      ESub e e' -> mathOp (-) e e'
  
      ELt  e e' -> do
        v  <- eval e
        v' <- eval e'
        case (v, v') of
          (VInt a, VInt b) -> if a < b then return $ VInt 1 else return $ VInt 0
          _                -> fail $ "\nINTERPRETATION ERROR: Could not evaluate '<'"
      EIf c t e -> do
        v <- eval c
        case v of 
          VInt a -> if a == 1 then eval t else eval e
          _      -> fail $ "\nINTERPRETATION ERROR: If statement did not evaluate to Int"
  
    -- | Evaluation of an environment entry.

    --evalEntry :: Cxt -> Entry -> Err Value
    --evalEntry cxt (Val v)      = return v
    --evalEntry cxt (Clos e env) = eval (cxt { cxtEnv = env }) e
  
    mathOp :: (Integer -> Integer -> Integer) -> Exp -> Exp -> Eval Value
    mathOp op e e' = do
      v  <- eval e
      v' <- eval e'
      case (v, v') of
        (VInt a, VInt b) -> return $ VInt( a `op` b)
        _                -> fail $ "\nINTERPRETATION ERROR: Could not perform mathOp"

    evalValue :: Env -> Eval a -> Eval a
    evalValue env computation = do
    local (\ cxt -> cxt { cxtEnv = env}) computation
