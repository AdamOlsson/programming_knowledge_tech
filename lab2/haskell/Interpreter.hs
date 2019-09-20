module Interpreter where

import Control.Monad

import Data.Map (Map)
import qualified Data.Map as Map

import CPP.Abs
import CPP.Print
import CPP.ErrM

data Val
  = VBool   Bool
  | VInt    Integer
  | VDouble Double
  | VVoid    

type Env = (Sig,[Context])      -- functions and context stack
type Sig = Map Id Def          -- function type signature
type Context = Map Id Val      -- variables with their types

interpret :: Program -> IO ()
interpret (PDefs defs) = do
    env <- addFcnSigns defs         -- add function signatures to env
    main@(DFun rType id args stms) <- findFcn env (Id "main") -- find main function
    execFcn (newBlock env) main                -- execute main func statements
    return ()


-- Top level function to add all function signatures to env
addFcnSigns:: [Def] -> IO Env
addFcnSigns [] = newEnv
addFcnSigns (def:defs) = do
    env <- addFcnSigns defs
    addFcn env def

newEnv ::IO Env
newEnv = case emptyEnv of
    env@(signs, cxt) -> do
        env1 <- addFcn env  (DFun Type_double (Id "readDouble")  [] [])
        env2 <- addFcn env1 (DFun Type_int    (Id "readInt")     [] [])
        env3 <- addFcn env2 (DFun Type_void   (Id "printDouble") [(ADecl Type_double (Id "x"))] [])
        addFcn env3         (DFun Type_void   (Id "printInt")    [(ADecl Type_int (Id "x"))]    [])

execFcn:: Env -> Def -> IO Env
execFcn env def@(DFun rType id args []) = return env
execFcn env def@(DFun rType id args (stm:stms)) = do
    --env'@(signs, (cxt:cs)) <- execStm env stm
    env'@(signs, (cxt:cs)) <- execStm env stm
    --case cxts of 
        --(cxt:_) -> do 
    case Map.lookup (Id "return") cxt of
            Nothing -> execFcn env' (DFun rType id args stms)
            Just _ -> return env' -- if return stm executed, block is done
      --  otherwise -> fail "execFcn: no context found"


execStm:: Env -> Stm -> IO Env
execStm env stm = case stm of
    SExp exp             -> do 
        (_,env) <- execExp env exp
        return env
    SDecls typ ids       -> addMultipleVars env ids   -- int x;
    SInit typ id exp     -> do                        -- int x = 2;
        (val, env') <- execExp env exp
        addVar env' id val
    SReturn exp          -> do
        (val, env'@(sign, cs)) <- execExp env exp
        addVar env' (Id "return") val
    SWhile exp stm       -> do
        ((VBool b), env') <- execExp env exp
        if b
            then do -- WHEN TO CREATE NEW BLOCKS?
                (sign', (ctx:cs)) <- execStm (newBlock env') stm  --execute all statements in loop, one iteration 
                case Map.lookup (Id "return") ctx of
                    (Just val) -> do
                        (val, env1) <- pop' (sign', (ctx:cs))
                        addVar env1 (Id "return") val
                    Nothing -> execStm (sign', cs) (SWhile exp stm)
--                execStm env'' (SWhile exp stm)
            else do
                return env'
    SBlock stms          -> do 
        env'@(signs, cxt:cs) <- execBlock (newBlock env) stms
        case Map.lookup (Id "return") cxt of
            Just val -> do
                (rVal, env'') <- pop' env'
                addVar env'' (Id "return") rVal
            Nothing -> do 
                (_, env'') <- pop' env'
                return env''
    SIfElse exp stm stm' -> do
        ((VBool b), env') <- execExp env exp
        if b
            then do 
                env''@(signs, cxt:cs) <- execStm (newBlock env') stm
                case Map.lookup (Id "return") cxt of 
                    Just val -> do 
                        (rVal, env2) <- pop' env''
                        addVar env2 (Id "return") rVal
                    Nothing -> do
                        (_, env2) <- pop' env''
                        return env2
            else do 
                env''@(signs, cxt:cs) <- execStm (newBlock env') stm'
                case Map.lookup (Id "return") cxt of 
                    Just val -> do 
                        (rVal, env2) <- pop' env''
                        addVar env2 (Id "return") rVal
                    Nothing -> do
                        (_, env2) <- pop' env''
                        return env2
    otherwise -> fail "execStm: Could not match stm pattern"


--wrong
{-
pop :: Env -> IO Env
pop env@(sign, []) = fail "pop: can't pop any more"
pop (sign, (cxt:cs)) = case Map.lookup (Id "return") cxt of
    Nothing -> return (sign, cs)
    Just val -> addVar (sign, cs) (Id "return") val
-}
pop' :: Env -> IO (Val, Env)
pop' env@(sign, []) = fail "pop: can't pop any more"
pop' (sign, (cxt:cs)) = case Map.lookup (Id "return") cxt of
    Nothing -> return (VVoid, (sign, cs)) -- might be problem with VVoid
    Just val -> return (val, (sign, cs))


execBlock:: Env ->[Stm] -> IO Env
execBlock env [] = return env
execBlock env (stm:stms) = do
    env'@(sign, cxt:cs) <- execStm env stm
    case Map.lookup (Id "return") cxt of 
        Just val -> return env'
        Nothing -> execBlock env' stms

    

execExp:: Env -> Exp -> IO (Val, Env)
execExp env exp = case exp of 
    ETrue            -> return (VBool True, env)
    EFalse           -> return (VBool False, env)
    EInt n           -> return (VInt n, env)
    EDouble d        -> return (VDouble d, env)
    EId id           -> findVar env id
    EPostIncr id      -> do
        (val, env') <- findVar env id
        case val of 
            VInt i    -> do
                env'' <- updateVar env' id (VInt (i +1))
                return (val, env'')
            VDouble d    -> do
                env'' <- updateVar env' id (VDouble (d +1.0))
                return (val, env'')
            otherwise -> fail "EPostIncr: error"
    EPostDecr id      -> do
        (val, env') <- findVar env id
        case val of 
            VInt i    -> do
                env'' <- updateVar env' id (VInt (i -1))
                return (val, env'')
            VDouble d    -> do
                env'' <- updateVar env' id (VDouble (d -1.0))
                return (val, env'')
    EPreIncr id      -> do
        (val, env') <- findVar env id
        case val of 
            VInt i    -> do
                env'' <- updateVar env' id (VInt (i +1))
                return ((VInt (i +1)), env'')
            VDouble d    -> do
                env'' <- updateVar env' id (VDouble (d +1))
                return ((VDouble (d +1)), env'')
            otherwise -> fail "EPreIncr: error"
    EPreDecr id      -> do
        (val, env') <- findVar env id
        case val of 
            VInt i    -> do
                env'' <- updateVar env' id (VInt (i -1))
                return ((VInt (i -1)), env'')
            VDouble d    -> do
                env'' <- updateVar env' id (VDouble (d -1))
                return ((VDouble (d -1)), env'')
    ETimes exp exp'  -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VInt (i1 * i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VDouble (d1 * d2)), env2)
    EDiv exp exp'    -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VInt (i1 `div` i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VDouble (d1 / d2)), env2)
    EPlus exp exp'   -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VInt (i1 + i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VDouble (d1 + d2)), env2)
    EMinus exp exp'  -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VInt (i1 - i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VDouble (d1 - d2)), env2)
    ELt exp exp'     -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 < i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 < d2)), env2)
    EGt exp exp'     -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 > i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 > d2)), env2)
    ELtEq exp exp'   -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 <= i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 <= d2)), env2)
    EGtEq exp exp'   -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 >= i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 >= d2)), env2)
    EEq exp exp'     -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 == i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 == d2)), env2)
            (VBool b1, VBool b2)     -> return ((VBool (b1 == b2)), env2)
    ENEq exp exp'    -> do
        (val1, env1) <- execExp env exp
        (val2, env2) <- execExp env1 exp'
        case (val1,val2) of
            (VInt i1, VInt i2)       -> return ((VBool (i1 /= i2)), env2)
            (VDouble d1, VDouble d2) -> return ((VBool (d1 /= d2)), env2)
            (VBool b1, VBool b2)     -> return ((VBool (b1 /= b2)), env2)
    EAnd exp exp'    -> do
        (val1, env1) <- execExp env exp
        case val1 of
            VBool True -> do
                (val2, env2) <- execExp env1 exp'
                case val2 of 
                    VBool True -> return ((VBool True), env2)
                    VBool False -> return ((VBool False), env2)
            VBool False -> return ((VBool False), env1)
    EOr exp exp'     -> do
        (val1, env1) <- execExp env exp
        case val1 of
            VBool True -> return ((VBool True), env1)
            VBool False -> do
                (val2, env2) <- execExp env1 exp'
                case val2 of 
                    VBool True -> return ((VBool True), env2)
                    VBool False -> return ((VBool False), env2)
    EAss id exp     -> do
        (val, env') <- execExp env exp
        env'' <- updateVar env' id val
        return (val, env'')
    EApp id exps     -> case id of
        (Id "readDouble")  -> case exps of
            [] -> do
                line <- getLine
                return (VDouble (read line), env)
            otherwise -> fail "EApp: To many arguments"
        (Id "readInt")     -> case exps of 
            [] -> do
                line <- getLine
                return (VInt (read line), env)
            otherwise -> fail "EApp: To many arguments"
        (Id "printDouble") -> case exps of 
            (exp':[]) -> do
                ((VDouble val), env') <- execExp env exp'
                putStrLn (show val)
                return (VVoid, env')
            otherwise -> fail "EApp: fail print double"
        (Id "printInt")    -> case exps of 
            (exp':[]) -> do
                ((VInt val), env') <- execExp env exp'
                putStrLn (show val)
                return (VVoid, env')
            otherwise -> fail "EApp: fail print int"
        otherwise    -> do
            def@(DFun rType id args stms) <- findFcn env id
            env' <- transferArgsToNewCxt' (newBlock env) args exps
            env''@(sign, cxt:cs) <- execFcn env' def
            (val, env1) <- pop' env''
            return (val, env1)
    otherwise -> fail "execExp: failed to match expression"

transferArgsToNewCxt':: Env -> [Arg] -> [Exp] -> IO Env
transferArgsToNewCxt' env [] [] = return env
transferArgsToNewCxt' env@(signs, (cxt:cs)) ((ADecl typ id):args) (exp:exps) = do
    (val', env'@(signs', cs')) <- execExp (signs, cs) exp
    env'' <- addVar (signs', cxt:cs') id val'
    transferArgsToNewCxt' env'' args exps
    

addFcn:: Env -> Def -> IO Env
addFcn (signs, cxt) def@(DFun rType id args stms) = case Map.lookup id signs of
    Nothing -> return ((Map.insert id def signs), cxt)
    Just _ -> fail "addFcn: Function already defined"

findFcn :: Env -> Id -> IO Def
findFcn (signs, cxt) id = case Map.lookup id signs of 
    Just def -> return def
    Nothing -> fail "findFcn: Function not defined"

findVar :: Env -> Id -> IO (Val, Env)
findVar (sign, []) id = fail "findVar: uninitialized variable"
findVar env@(sign, cxt:cs) id = case Map.lookup id cxt of
    Nothing -> do
        ( val, (sign', cs')) <- findVar (sign, cs) id
        return (val, (sign', cxt:cs'))
    Just val -> return (val, env)
    --Just _ -> fail "findVar: uninitialized variable"

addMultipleVars:: Env -> [Id] -> IO Env
addMultipleVars env [] = return env
addMultipleVars env (id:ids) = do
    env' <- addVar env id VVoid
    addMultipleVars env' ids


addVar:: Env -> Id -> Val -> IO Env
addVar (sign, []) _ _ = fail "addVar: no context"
addVar env@(signs, cxt:cs) id val = case Map.lookup id cxt of 
    Nothing -> return (signs, (Map.insert id val cxt):cs)
    Just _ -> fail "addVar: Variable already declared"
  
    

updateVar:: Env -> Id -> Val -> IO Env
updateVar (sign, []) _ _ = fail "updateVar: Variable not defined"
updateVar (sign, cxt:cs) id val = case Map.lookup id cxt of
    Just _ -> return (sign, (Map.insert id val cxt):cs)
    Nothing -> do -- check previous contexts. In the case var is defined before loop etc
        (sign', cs') <- updateVar (sign, cs) id val
        return (sign, cxt:cs')
    

emptyEnv :: Env
emptyEnv = (Map.empty, [])

newBlock :: Env -> Env
newBlock (signs, cxt) = (signs, Map.empty:cxt)