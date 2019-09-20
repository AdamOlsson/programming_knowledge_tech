module TypeChecker where

import Control.Monad
import Data.Maybe
import Data.Map (Map)
import qualified Data.Map as Map

import CPP.Abs  as C
import CPP.Print as CP
import CPP.ErrM
import Annotated as A hiding (Id(..), Type(..), Arg(..))

type Env     = (Sig,[Context])      -- functions and context stack
type Sig     = Map Id ([Type],Type) -- function type signature
type Context = Map Id Type          -- variables with their types


--- Typechecker
-- Collect all funSigns and then check them
typecheck :: C.Program -> Err A.Program
typecheck (C.PDefs [])   = Bad "Type checker: Empty program"
typecheck (C.PDefs defs) = do
    env <- collectFcnSigns defs
    adefs <- checkDefs env defs
    return (A.PDefs adefs)

-- Collects funSigns
collectFcnSigns :: [C.Def] -> Err Env
collectFcnSigns []                                   = Ok newEnv
collectFcnSigns ((C.DFun typ (Id "main") args _):defs) = do
    unless (null args) $ fail "Function main does not take arguments"
    if typ /= Type_int
        then fail "collectFcnSigns: main must return type in"
        else do
            env <- collectFcnSigns defs
            let listOfFArgTypes = map collectArgTypes args
            updateFun env (Id "main") (listOfFArgTypes, typ)
collectFcnSigns ((C.DFun typ id args stms):defs) = do
    env <- collectFcnSigns defs
    let listOfFArgTypes = map collectArgTypes args
    if elem Type_void listOfFArgTypes
        then fail "collectFcnSigns: arg cant be of type void"
        else do
            envX <- updateFun env id (listOfFArgTypes, typ)
            return envX

-- Checks if functions are okay
checkDefs :: Env -> [C.Def] -> Err [A.Def]
checkDefs env []                             = Ok []
checkDefs env ((C.DFun typ id args stms):defs) = do
    adef <- checkOneFcn env (C.DFun typ id args stms)
    adefs <- checkDefs env defs
    return (adef:adefs)

-- Checks if a function is okay
checkOneFcn :: Env -> C.Def -> Err A.Def
checkOneFcn env (C.DFun t id args stms) = do
    env2          <- addArgsToEnv (newBlock env) args
    (env3, stms') <- evalStms env2 stms t
    return (A.DFun t id args stms')

-- Create new context for function
newBlock :: Env -> Env
newBlock (signatures, cxt) = (signatures, Map.empty:cxt)

addArgsToEnv :: Env -> [Arg] -> Err Env
addArgsToEnv env [] = return env
addArgsToEnv env ((ADecl t id):args) = do
    unless (t /= Type_void) $ fail $ "Arguments can not be void: " ++ (show id)
    env'' <- evalIds env [id] t
    addArgsToEnv env'' args

collectArgTypes :: Arg -> Type
collectArgTypes (ADecl typ id) = typ

--- Environment

-- New environment with built-in functions
newEnv :: Env
newEnv = case emptyEnv of
    (signatures, cxt) -> (
        (Map.insert (Id "readDouble")  ([], Type_double)
        (Map.insert (Id "printDouble") ([Type_double], Type_void)
        (Map.insert (Id "readInt")     ([], Type_int)
        (Map.insert (Id "printInt")    ([Type_int], Type_void)
        signatures)))), cxt)

-- Empty environment
emptyEnv  :: Env
emptyEnv = (Map.empty, [])

--- Statements 

-- Evaluates multiple statements
evalStms :: Env -> [C.Stm] -> Type -> Err (Env, [A.Stm])
evalStms env [] _            = Ok (env, [])
evalStms env (stm:stms) typ  = case checkStm env stm typ of 
    Ok (env', aStm) -> do 
        (env1, stms') <- (evalStms env' stms typ)
        return (env1, aStm:stms') -- will it work?
    Bad s -> Bad s


-- Checks if a statement is ok
checkStm :: Env -> C.Stm -> Type -> Err (Env, A.Stm)
checkStm env s typ = case s of 
    C.SExp exp -> do                -- A.SExp Type Exp
        (t, aexp) <- inferExp env exp
        return (env, (A.SExp t aexp))

    C.SDecls typ ids -> do          -- A.SDecls Type [Id]
        case typ of
            Type_void -> fail "checkStm: Can't assign void type"
            _ -> do 
                env' <- evalIds env ids typ 
                return (env', A.SDecls typ ids)
    C.SInit typ id exp -> do        -- A.SInit Type Id Exp
        case typ of
            Type_void -> fail "checkStm: Can't assign void type"
            _ -> do
                (t, aexp) <- checkExp env typ exp
                env' <- updateVar env id typ
                return (env', A.SInit t id aexp)

    C.SReturn exp -> do             -- A.SReturn Type Exp
        (t, aexp) <- checkExp env typ exp
        return (env, A.SReturn t aexp)

    C.SWhile exp stm -> do          -- A.SWhile Exp Stm
        (t, aexp ) <- checkExp env Type_bool exp
        ((signs, _:ctx), astm) <- checkStm (newBlock env) stm typ
        return ((signs, ctx), A.SWhile aexp astm)

    C.SBlock stms -> do             -- A.SBlock [Stm]
        ((sign, _:cs), astms) <- evalStms (newBlock env) stms typ
        return ((sign, cs), A.SBlock astms)

    C.SIfElse exp stm stm' -> do    -- SIfElse Exp Stm Stm
        (t, aexp ) <- checkExp env Type_bool exp
        ((signs, _:cs), astms) <- checkStm (newBlock env) stm typ
        ((signs1, _:cxts), astms') <- checkStm (newBlock (signs, cs)) stm' typ
        return ((signs1, cxts), A.SIfElse aexp astms astms')

-- Evaluate if the same arguement is provided more than once
evalArgs :: Env -> [Arg] -> Err Env
evalArgs env []                                         = Ok env
evalArgs env@(signatures, cxt:cs) ((ADecl typ id):args) = case Map.lookup id cxt of
    Nothing -> (evalArgs (signatures, (Map.insert id typ cxt):cs) args)
    _       -> Bad "Multiple definitions of the same argument"


--- Expression

checkExp :: Env -> Type -> C.Exp -> Err (Type, A.Exp)
checkExp env typ exp = do
    (typ', aexp) <- inferExp env exp
    if (typ' == typ) 
        then return (typ, aexp)
        else Bad $ "type of " ++ CP.printTree exp

inferExp :: Env -> C.Exp -> Err (Type, A.Exp)
inferExp env exp = case exp of
    C.ETrue           -> return  (Type_bool, A.ETrue)
    C.EFalse          -> return  (Type_bool, A.EFalse)
    C.EInt       n    -> return  (Type_int, A.EInt n)
    C.EDouble    d    -> return  (Type_double, A.EDouble d)
    C.EId        id   -> do
        t <- lookVar env id
        return (t, A.EId id)
    C.EPostDecr  id   -> do
        t <- inferIncrOrDecr env id
        return (t, A.EPostDecr id)
    C.EPostIncr  id   -> do
        t <- inferIncrOrDecr env id
        return (t, A.EPostIncr id)
    C.EPreDecr   id   -> do
        t <- inferIncrOrDecr env id
        return (t, A.EPreDecr id)
    C.EPreIncr   id   -> do
        t <- inferIncrOrDecr env id
        return (t, A.EPreIncr id)
    C.EPlus  exp exp' -> do
        (t, aexp, aexp') <- inferArithmBin env exp exp'
        return (t, A.EPlus t aexp aexp')
    C.EMinus exp exp' -> do
        (t, aexp, aexp') <- inferArithmBin  env exp exp'
        return (t, A.EMinus t aexp aexp')
    C.ETimes exp exp' -> do
        (t, aexp, aexp') <- inferArithmBin  env exp exp'
        return (t, A.ETimes t aexp aexp')
    C.EDiv   exp exp' -> do
        (t, aexp, aexp') <- inferArithmBin  env exp exp'
        return (t, A.EDiv t aexp aexp')
    C.ELt    exp exp' -> do
        (t, aexp, aexp') <- inferComparison  env exp exp'
        return (t, A.ELt t aexp aexp')
    C.EGt    exp exp' -> do
        (t, aexp, aexp') <- inferComparison  env exp exp'
        return (t, A.EGt t aexp aexp')
    C.ELtEq  exp exp' -> do
        (t, aexp, aexp') <- inferComparison  env exp exp'
        return (t, A.ELtEq t aexp aexp')
    C.EGtEq  exp exp' -> do
        (t, aexp, aexp') <- inferComparison  env exp exp'
        return (t, A.EGtEq t aexp aexp')
    C.EEq    exp exp' -> do
        (t, aexp, aexp') <- inferEqOrInEq  env exp exp'
        return (t, A.EEq t aexp aexp')
    C.ENEq   exp exp' -> do
        (t, aexp, aexp') <- inferEqOrInEq  env exp exp'
        return (t, (A.ENEq t aexp aexp'))
    C.EAnd   exp exp' -> do
        (t, aexp, aexp') <- inferLogic     env exp exp'
        return (t, A.EAnd aexp aexp')
    C.EOr    exp exp' -> do
        (t, aexp, aexp') <- inferLogic     env exp exp'
        return (t, A.EOr aexp aexp')
    C.EAss   id  exp' -> inferAss      env id exp'
    C.EApp   id  exp  -> do
        (t, aexps) <- inferFunCall    env id exp
        return (t, A.EApp id aexps)

inferFunCall :: Env -> Id -> [C.Exp] -> Err (Type, [A.Exp])
inferFunCall env id exps = case lookFun env id of
    Ok (argTypes, returnType) -> case compareFunTypes env argTypes exps of 
        Ok aexps  -> return (returnType, aexps)
        Bad s -> Bad ("inferFunCall: compareFunTypes: " ++ s)
    Bad s                     -> Bad ("inferFunCall: error - " ++ s)

compareFunTypes :: Env -> [Type] -> [C.Exp] -> Err [A.Exp]
compareFunTypes _ [] []                     = Ok []
compareFunTypes env (arg:args) (exp:exps)   = case checkExp env arg exp of
    Ok (t, aexp)  -> do 
        aexps <- (compareFunTypes env args exps)
        return (aexp:aexps)
    Bad s -> Bad s 
compareFunTypes _ _ _                       = Bad "compareFunTypes: error - different lengths"

inferIncrOrDecr :: Env -> Id -> Err Type
inferIncrOrDecr env id = do
    idType <- lookVar env id 
    if elem idType [Type_int, Type_double]
        then return idType
        else Bad "inferIncrOrDecr: Variable must be of type int or double"

inferArithmBin :: Env -> C.Exp -> C.Exp -> Err (Type, A.Exp, A.Exp)
inferArithmBin env a b = do
    (typ, aexp) <- inferExp env a
    if elem typ [Type_int, Type_double] then do
        (typ', aexp') <- checkExp env typ b
        return (typ', aexp, aexp')
    else
        Bad "inferArithmBin: Type not of int or double"

inferComparison :: Env -> C.Exp -> C.Exp -> Err (Type, A.Exp, A.Exp)
inferComparison env a b = do
    (typ, aexp) <- inferExp env a
    if elem typ [Type_int, Type_double] then do
        (typ', aexp') <- checkExp env typ b
        if typ == typ'
            then return (Type_bool, aexp, aexp')
            else Bad "inferComparison: Can't compare two different types"
    else
        Bad "inferComparison: Type not of int or double"

inferEqOrInEq :: Env -> C.Exp -> C.Exp -> Err (Type, A.Exp, A.Exp)
inferEqOrInEq env a b = do
    (typ, aexp) <- inferExp env a
    if elem typ [Type_int, Type_double, Type_bool] then do
        (typ', aexp') <- checkExp env typ b
        if typ == typ'
            then return (Type_bool, aexp, aexp')
            else Bad "inferEqOrInEq: Can't compare two different types"
    else
        Bad "inferEqOrInEq: Type not of int, double, or bool"

inferLogic :: Env -> C.Exp -> C.Exp -> Err (Type, A.Exp, A.Exp)
inferLogic env a b = do
    (typ, aexp) <- inferExp env a
    if elem typ [Type_bool] then do
        (typ', aexp')<- checkExp env typ b
        return (typ', aexp, aexp')
    else
        Bad "inferLogic: type not of bool"

inferAss ::Env -> Id -> C.Exp -> Err (Type, A.Exp)
inferAss env id exp = do
    idType <- lookVar env id
    (t, aexp) <- inferExp env exp
    if idType == t
        then return (t, A.EAss id aexp)
        else Bad "inferAss: Type error"
    --checkExp env idType exp 

--- Variables

lookVar :: Env -> Id -> Err Type
lookVar (signs, []) id     = fail "lookVar: Variable not defined"
lookVar (signs, cxt:cs) id =
    case Map.lookup id cxt of
        Nothing -> lookVar (signs, cs) id
        Just idType -> Ok idType

evalIds :: Env -> [Id] -> Type -> Err Env
evalIds env [] typ       = Ok env
evalIds env (id:ids) typ = case updateVar env id typ of
    Ok env' -> evalIds env' ids typ
    Bad s -> Bad s

updateVar :: Env -> Id -> Type -> Err Env
updateVar (signatures, cxt:cs) id typ = 
    case Map.lookup id cxt of 
        Just _ -> Bad "updateVar: Variable already defined"
        Nothing -> Ok $ (signatures, (Map.insert id typ cxt):cs)


-- Given an env and id, return the belonging argTypes and returnType
lookFun :: Env -> Id -> Err ([Type],Type)
lookFun (signatures, cxt) id = 
    case Map.lookup id signatures of
        Nothing -> Bad ("lookFun: Function not defined: " ++ (show id))
        Just (argTypes, returnType) -> Ok (argTypes, returnType)

updateFun :: Env -> Id -> ([Type], Type) -> Err Env
updateFun (signatures, cxt) id (argTypes, returnType) = 
    case Map.lookup id signatures of
        Just (_, _) -> Bad "updateFun: Identical function definition already exist"
        Nothing -> Ok $ (Map.insert id (argTypes, returnType) signatures, cxt)



