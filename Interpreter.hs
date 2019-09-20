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
  -- v <- eval mainExp `runReaderT` cxt  -- with Reader monad
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

-- | Evaluation monad.

type Eval = ReaderT Cxt Err

-- * Interpreter.

todo = error "not yet implemented, TODO!"

-- -- | Evaluation (with reader monad).
-- eval :: Exp -> Eval Value
-- eval e = todo

-- | Evaluation.
eval :: Cxt -> Exp -> Err Value
eval cxt e = case e of

  EInt i    -> todo

  EVar x    -> todo

  EAbs x e  -> todo

  EApp f a  -> todo

  EAdd e e' -> todo

  ESub e e' -> todo
  ELt  e e' -> todo
  EIf c t e -> todo

-- | Evaluation of an environment entry.

evalEntry :: Cxt -> Entry -> Err Value
evalEntry cxt (Val v)      = return v
evalEntry cxt (Clos e env) = eval (cxt { cxtEnv = env }) e
