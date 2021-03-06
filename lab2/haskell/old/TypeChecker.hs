module TypeChecker where

import Control.Monad

import Data.Map (Map)
import qualified Data.Map as Map

import CPP.Abs
import CPP.Print
import CPP.ErrM

-- Brought from course book
type Env = (Sig,[Context])      -- functions and context stack
type Sig = Map Id ([Type],Type) -- function type signature
type Context = Map Id Type      -- variables with their types

-- First collect all function singatures then check types
typecheck :: Program -> Err ()
typecheck (PDefs [])        = Bad "Type checker: Empty program"
typecheck prgm@(PDefs defs) = do
    env <- collectFcnSigns defs
    checkDef env defs

collectFcnSigns :: [Def] -> Err Env
collectFcnSigns [] = Ok newEnv
collectFcnSigns ((DFun typ (Id "main") args _):defs) = do
    if typ /= Type_int
        then fail "collectFcnSigns: main must return type in"
        else do
            env <- collectFcnSigns defs
            let listOfFArgTypes = map collectArgTypes args
            updateFun env (Id "main") (listOfFArgTypes, typ)
collectFcnSigns ((DFun typ id args _):defs) = do
    env <- collectFcnSigns defs
    let listOfFArgTypes = map collectArgTypes args
    if elem Type_void listOfFArgTypes
        then fail "collectFcnSigns: arg cant be of type void"
        else updateFun env id (listOfFArgTypes, typ)

collectArgTypes:: Arg -> Type
collectArgTypes (ADecl typ id) = typ

newEnv :: Env
newEnv = case emptyEnv of
    (signatures, cxt) -> (
        (Map.insert (Id "readDouble") ([], Type_double)
        (Map.insert (Id "printDouble") ([Type_double], Type_void)
        (Map.insert (Id "readInt") ([], Type_int)
        (Map.insert (Id "printInt") ([Type_int], Type_void)
        signatures)))), cxt)

emptyEnv  :: Env
emptyEnv = (Map.empty, [])


checkDef::Env -> [Def] -> Err ()
checkDef env [] = Ok ()
checkDef env@(signatures, cxt) ((DFun typ id args ss):defs) = case evalArgs (newBlock env) args of
    Ok env' -> do 
        env'' <- evalStms env' ss typ
        checkDef env'' defs
    Bad s -> Bad s

checkExp :: Env -> Type -> Exp -> Err Type
checkExp env typ exp = do
    typ2 <- inferExp env exp
    if (typ2 == typ) 
        then return typ
        else Bad $ "type of " ++ printTree exp


checkStm::Env -> Stm -> Type -> Err Env
checkStm env s typ = case s of
    SExp exp -> do
        inferExp env exp
        return env
    SDecls typ ids -> 
        case typ of
            Type_void -> fail "checkStm: Can't assign void type"
            _ -> evalIds env ids typ
    SInit typ id exp -> do
        case typ of
            Type_void -> fail "checkStm: Can't assign void type"
            _ -> do
                checkExp env typ exp
                updateVar env id typ
    SReturn exp -> do
        checkExp env typ exp
        return env
    SWhile exp stm -> do
        checkExp env Type_bool exp
        (signs, _:ctx) <- checkStm (newBlock env) stm typ
        return (signs, ctx)
    SBlock stms -> do
        (sign, _:cs) <- evalStms (newBlock env) stms typ
        return (sign, cs)
    SIfElse exp stm stm' -> do
        checkExp env Type_bool exp
        (signs, _:cs) <- checkStm (newBlock env) stm typ
        (signs1, _:cxts) <- checkStm (newBlock (signs, cs)) stm' typ
        return (signs1, cxts)
    
evalStms::Env -> [Stm] -> Type -> Err Env
evalStms env [] _                = Ok env
evalStms env (stm:stms) typ     = case checkStm env stm typ of 
    Ok env' -> evalStms env' stms typ
    Bad s -> Bad s
        
evalIds:: Env -> [Id] -> Type -> Err Env
evalIds env [] typ = Ok env
evalIds env (id:ids) typ = case updateVar env id typ of
    Ok env' -> evalIds env' ids typ
    Bad s -> Bad s

-- Evaluate if the same arguement is provided more than once
evalArgs::Env->[Arg]->Err Env
evalArgs env [] = Ok env
evalArgs env@(signatures, cxt:cs) ((ADecl typ id):args) = case Map.lookup id cxt of
    Nothing -> (evalArgs (signatures, (Map.insert id typ cxt):cs) args)
    _ -> Bad "Multiple definitions of the same argument"

-- Create new context for function
newBlock :: Env -> Env
newBlock (signatures, cxt) = (signatures, Map.empty:cxt)

inferExp :: Env -> Exp -> Err Type
inferExp env exp = case exp of
    ETrue           -> return Type_bool
    EFalse          -> return Type_bool
    EInt n          -> return Type_int
    EDouble double  -> return Type_double
    EId id          -> lookVar env id
    EPostDecr id    -> inferIncrOrDecr env id
    EPostIncr id    -> inferIncrOrDecr env id
    EPreDecr id     -> inferIncrOrDecr env id
    EPreIncr id     -> inferIncrOrDecr env id
    EPlus exp exp'  -> inferArithmBin env exp exp'
    EMinus exp exp' -> inferArithmBin env exp exp'
    ETimes exp exp' -> inferArithmBin env exp exp'
    EDiv exp exp'   -> inferArithmBin env exp exp'
    ELt exp exp'    -> inferComparison env exp exp'
    EGt exp exp'    -> inferComparison env exp exp'
    ELtEq exp exp'  -> inferComparison env exp exp'
    EGtEq exp exp'  -> inferComparison env exp exp'
    EEq exp exp'    -> inferEqualityOrInequality env exp exp'
    ENEq exp exp'   -> inferEqualityOrInequality env exp exp'
    EAnd exp exp'   -> inferLogic env exp exp'
    EOr exp exp'    -> inferLogic env exp exp'
    EAss id exp'    -> inferAss env id exp'
    EApp id exp     -> inferFcnCall env id exp


inferFcnCall:: Env -> Id -> [Exp] -> Err Type
inferFcnCall env id exps = case lookFun env id of
    Ok (argTypes, returnType) -> case compareFcnTypes env argTypes exps of 
        Ok _ -> return returnType
        Bad s -> Bad s
    Bad s -> Bad s

compareFcnTypes:: Env -> [Type] -> [Exp] -> Err ()
compareFcnTypes _ [] []                     = Ok ()
compareFcnTypes _ args []                   = Bad "Lengths do not match"
compareFcnTypes _ [] exps                   = Bad "Lengths do not match"
compareFcnTypes env (arg:args) (exp:exps)   = case checkExp env arg exp of
    Ok _  -> compareFcnTypes env args exps
    Bad s -> Bad s 

inferIncrOrDecr:: Env -> Id -> Err Type
inferIncrOrDecr env id = do
    idType <- lookVar env id 
    if elem idType [Type_int, Type_double]
        then return idType
        else Bad "inferIncrOrDecr: Variable must be of type int or double"

inferArithmBin :: Env -> Exp -> Exp -> Err Type
inferArithmBin env a b = do
    typ <- inferExp env a
    if elem typ [Type_int, Type_double] then do
        checkExp env typ b
    else
        Bad "inferArithmBin: type not of int or double"


inferComparison :: Env -> Exp -> Exp -> Err Type
inferComparison env a b = do
    typ <- inferExp env a
    if elem typ [Type_int, Type_double] then do
        typ' <- checkExp env typ b
        if typ == typ'
            then return Type_bool
            else Bad "inferComparison: Can't compare two different types"
    else
        Bad "inferComparison: type not of int or double"

inferEqualityOrInequality:: Env -> Exp -> Exp -> Err Type
inferEqualityOrInequality env a b = do
    typ <- inferExp env a
    if elem typ [Type_int, Type_double, Type_bool] then do
        typ' <- checkExp env typ b
        if typ == typ'
            then return Type_bool
            else Bad "inferEqualityOrInequality: Can't compare two different types"
    else
        Bad "inferEqualityOrInequality: type not of int, double or bool"

inferLogic:: Env -> Exp -> Exp -> Err Type
inferLogic env a b = do
    typ <- inferExp env a
    if elem typ [Type_bool] then do
        checkExp env typ b
    else
        Bad "inferLogic: type not of bool"

inferAss::Env -> Id -> Exp -> Err Type
inferAss env id exp = do
    idType <- lookVar env id
    checkExp env idType exp

-- Given an env and id, return the belonging argTypes and returnType
lookFun :: Env -> Id -> Err ([Type],Type)
lookFun (signatures, cxt) id = 
    case Map.lookup id signatures of
        Nothing -> Bad "lookFun: Function not defined"
        Just (argTypes, returnType) -> Ok (argTypes, returnType) 

lookVar :: Env -> Id -> Err Type
lookVar (signs, []) id = Bad "lookVar: Variable not defined"
lookVar (signs, cxt:cs) id =
    case Map.lookup id cxt of
        Nothing -> lookVar (signs, cs) id
        Just idType -> Ok idType

updateVar :: Env -> Id -> Type -> Err Env
updateVar (signatures, cxt:cs) id typ = 
    case Map.lookup id cxt of 
        Just _ -> Bad "updateVar: Variable already defined"
        Nothing -> Ok $ (signatures, (Map.insert id typ cxt):cs)

updateFun :: Env -> Id -> ([Type], Type) -> Err Env
updateFun (signatures, cxt) id (argTypes, returnType) = 
    case Map.lookup id signatures of
        Just (_, _) -> Bad "updateFun: Identical function definition already exist"
        Nothing -> Ok $ (Map.insert id (argTypes, returnType) signatures, cxt)

