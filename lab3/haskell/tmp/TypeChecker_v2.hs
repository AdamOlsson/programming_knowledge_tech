module TypeChecker_v2 where

    import Control.Monad
    
    import Data.Map (Map)
    import qualified Data.Map as Map
    
    import CPP.Abs as C
    import CPP.Print as CP
    import CPP.ErrM
    import Annotated.Abs as A
    import Annotated.Print as An
    
    type Env = (Sig, [Context])
    type Sig = Map C.Id ([C.Type], C.Type)
    type Context = Map C.Id C.Type
    
    --should return Bad s or Ok tree.
    typecheck :: C.Program -> Err A.Program 
    typecheck (C.PDefs []) = fail "Empty program"
    typecheck (C.PDefs defs) = do
            env <- addSignatures defs
            adefs <- checkDef env defs
            return (A.PDefs adefs)
            -- return convertProg defs
            -- if checkDef returns alright, convert CPP.Program to Ann.Program?
    
    addSignatures :: [C.Def] -> Err Env
    addSignatures []     = Ok newEnv
    addSignatures ((C.DFun returnType (C.Id "main") args _):defs) = case (returnType, args) of
        (C.Type_int, []) -> do 
                      env <- addSignatures defs
                      updateFun env (C.Id "main") ((map argToType args),  returnType)
        otherwise -> fail "main() must have returntype int"
    addSignatures ((C.DFun returnType id args _):defs) = do
        env <- addSignatures defs
        updateFun env id ((map argToType args), returnType)
    
    checkDef :: Env -> [C.Def] -> Err [A.Def]
    checkDef env []                                    = do return []
    checkDef env ((C.DFun returnType id args stms):defs) = case (funcEnv (newBlock env) args) of
        Ok (sig, c:con) -> do 
          ((sig1, c1:con1), astmas) <- checkStms (sig, c:con) returnType stms []
          adefs <- checkDef (sig1, con1) defs
          createADefList (A.DFun (convertType returnType) (convertId id) (map convertArg args) astmas) adefs
        Bad s -> Bad s
    
    createADefList :: A.Def -> [A.Def] -> Err [A.Def]
    createADefList adef adefs = Ok (adef:adefs)
    
    checkStms :: Env -> C.Type -> [C.Stm] -> [A.Stm] -> Err (Env, [A.Stm])
    checkStms env returnType [] astms   = Ok (env, astms)
    checkStms env returnType (stm:stms) (astmas) = do
        (newEnv, astma) <- checkStm env returnType stm
        checkStms newEnv returnType stms (astmas ++ [astma])
    
    
    checkStm :: Env -> C.Type -> C.Stm -> Err (Env, A.Stm)
    checkStm env returnType x = case x of
        C.SExp exp -> do
            (atyp, aexp) <- inferExp env exp
            return (env, (A.SExp atyp aexp))
        C.SDecls typ (id:ids) -> do
            newEnv <- updateVar env id typ
            (newestEnv, (A.SDecls atyp list)) <- checkStm newEnv returnType (C.SDecls typ ids)
            return (newestEnv, (A.SDecls atyp ((convertId id):list)))
        C.SDecls typ [] -> do
            return (env, (A.SDecls (convertType typ) []))
        C.SInit t id exp -> do
            aexp <- checkExp env (convertType t) exp
            newEnv <- updateVar env id t
            return (newEnv, (A.SInit (convertType t) (convertId id) aexp))
        C.SReturn exp -> do
            aexp <- checkExp env (convertType returnType) exp
            return (env, (A.SReturn (convertType returnType) aexp))
        C.SWhile exp stm -> do
            aexp <- checkExp env A.Type_bool exp
            ((sig, _:con), astma) <- checkStm (newBlock env) returnType stm
            return ((sig, con), (A.SWhile aexp astma))
        C.SBlock stms -> do
            ((sig, _:con), astmas) <- checkStms (newBlock env) returnType stms []
            return ((sig, con), (A.SBlock astmas))
        C.SIfElse exp stm1 stm2 -> do
            aexp <- checkExp env A.Type_bool exp
            ((sig, _:con), astma) <- checkStm (newBlock env) returnType stm1
            ((sig2, _:con2),astma2) <- checkStm (newBlock (sig, con)) returnType stm2
            return ((sig2, con2), (A.SIfElse aexp astma astma2))
    
    checkExp :: Env -> A.Type -> C.Exp -> Err A.Exp
    checkExp env t exp = do
        (atyp, aexp) <- inferExp env exp
        if (atyp == t) then
            return aexp
        else
            fail $ "type of " ++ CP.printTree exp ++
                   "expected" ++ An.printTree t   ++
                   "but found" ++ An.printTree atyp
    
    inferExp :: Env -> C.Exp -> Err (A.Type, A.Exp)
    inferExp env C.ETrue        = Ok (A.Type_bool, (A.ETrue))
    inferExp env C.EFalse       = Ok (A.Type_bool, (A.EFalse))
    inferExp env (C.EInt     i) = Ok (A.Type_int, (A.EInt i))
    inferExp env (C.EDouble  d) = Ok (A.Type_double, (A.EDouble d))
    inferExp env (C.EId     id) = do 
                            atyp <- lookupVar env id
                            return (atyp, A.EId (convertId id))
    inferExp env (C.EPostIncr id) = do
                            atyp <- lookupVar env id
                            if elem atyp [A.Type_int, A.Type_double] then
                              return (atyp, A.EPostIncr (convertId id))
                            else fail "has to be int or double to do postincr"
    inferExp env (C.EPostDecr id) = do
                            atyp <- lookupVar env id
                            if elem atyp [A.Type_int, A.Type_double] then
                              return (atyp, A.EPostDecr (convertId id))
                            else fail "has to be int or double to do postdecr"
    inferExp env (C.EPreIncr  id) = do
                            atyp <- lookupVar env id
                            if elem atyp [A.Type_int, A.Type_double] then
                              return (atyp, A.EPreIncr (convertId id))
                            else fail "has to be int or double to do preincr"
    inferExp env (C.EPreDecr  id) = do
                            atyp <- lookupVar env id
                            if elem atyp [A.Type_int, A.Type_double] then
                              return (atyp, A.EPreDecr (convertId id))
                            else fail "has to be int or double to do predecr"
    inferExp env (C.ETimes e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (atyp, (A.ETimes atyp aexp a2exp))
    inferExp env (C.EDiv   e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (atyp, (A.EDiv atyp aexp a2exp))
    inferExp env (C.EPlus  e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (atyp, (A.EPlus atyp aexp a2exp))
    inferExp env (C.EMinus e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (atyp, (A.EMinus atyp aexp a2exp))
    inferExp env (C.EApp id exps) = case lookupFun env  id of
                            Ok (ts, t) -> do 
                                aexps <- (f env ts exps t)
                                return ((convertType t), (A.EApp (convertId id) aexps))
                            Bad s   -> Bad s
    inferExp env (C.ELt    e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (A.Type_bool, (A.ELt atyp aexp a2exp))
    inferExp env (C.EGt    e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (A.Type_bool, (A.EGt atyp aexp a2exp))
    inferExp env (C.ELtEq  e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (A.Type_bool, (A.ELtEq atyp aexp a2exp))
    inferExp env (C.EGtEq  e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double] env e1 e2
                            return (A.Type_bool, (A.EGtEq atyp aexp a2exp))
    inferExp env (C.EEq    e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double, A.Type_bool] env e1 e2
                            return (A.Type_bool, (A.EEq atyp aexp a2exp))
    inferExp env (C.ENEq   e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_int, A.Type_double, A.Type_bool] env e1 e2
                            return (A.Type_bool, (A.ENEq atyp aexp a2exp))
    inferExp env (C.EAnd   e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_bool] env e1 e2
                            return (A.Type_bool, (A.EAnd aexp a2exp))
    inferExp env (C.EOr    e1 e2) = do
                            (atyp, aexp, a2exp) <- compareTypes [A.Type_bool] env e1 e2
                            return (A.Type_bool, (A.EOr aexp a2exp))
    inferExp env (C.EAss   id e1) = do
                                t1 <- lookupVar env id
                                (atyp, aexp) <- inferExp env e1
                                if t1 == atyp then return (atyp, (A.EAss (A.EId (convertId id)) aexp))
                                            else fail "Type error"
    
    
    lookupVar :: Env -> C.Id -> Err (A.Type)
    lookupVar (_, [])   id = Bad ("Variable " ++ show id ++ " not found")
    lookupVar (sig, c:cs) id = case Map.lookup id c of
                                Just t -> Ok (convertType t)
                                Nothing -> lookupVar (sig, cs) id
    
    lookupFun :: Env -> C.Id -> Err ([C.Type], C.Type)
    lookupFun (sig, _) id = case Map.lookup id sig of
                                Just (ts, t) -> Ok (ts, t)
                                Nothing -> Bad ("Variable " ++ show id ++ " not found")
    
    updateVar :: Env -> C.Id -> C.Type -> Err Env
    updateVar (sig, []) id t = Ok $ (sig, (Map.insert id t Map.empty):[])
    updateVar (sig, c:cs) id t = case Map.lookup id c of
                                    Just t2 -> Bad "Fuxk off"
                                    Nothing -> Ok $ (sig, (Map.insert id t c):cs)
    
    updateFun :: Env -> C.Id -> ([C.Type], C.Type) -> Err Env
    updateFun (sig, c) id (ts, t) = case Map.lookup id sig of
                                                Just (ts2, t2) -> Bad "Bugger off"
                                                Nothing -> Ok $ (Map.insert id (ts, t) sig, c)
    
    newBlock  :: Env -> Env
    newBlock (sig, cs) = (sig, Map.empty:cs)
    
    emptyEnv  :: Env
    emptyEnv = (Map.empty, [])
    
    newEnv :: Env
    newEnv = case emptyEnv of
        (sig, cons) -> (
                        (Map.insert (C.Id "readDouble") ([], C.Type_double)
                        (Map.insert (C.Id "printDouble") ([C.Type_double], C.Type_void)
                        (Map.insert (C.Id "readInt") ([], C.Type_int)
                        (Map.insert (C.Id "printInt") ([C.Type_int], C.Type_void)
                        sig))))
                        , cons)
    
    funcEnv :: Env -> [C.Arg] -> Err Env
    funcEnv env [] = Ok env
    funcEnv (sig, []) ((C.ADecl t id):args) = funcEnv (sig, (Map.insert id t Map.empty):[]) args
    funcEnv (sig, c:cons) ((C.ADecl t id):args) = case Map.lookup id c of
                                Just t -> fail ("duplicate Variable name" ++ show id)
                                _ -> funcEnv (sig, (Map.insert id t c):cons) args
    
    compareTypes :: [A.Type] -> Env -> C.Exp -> C.Exp -> Err (A.Type, A.Exp, A.Exp)
    compareTypes types env e1 e2 = do
                             (atyp, aexp) <- inferExp env e1
                             if elem atyp types then do 
                                a2exp <- checkExp env atyp e2;
                                return (atyp, aexp, a2exp)
                             else Bad "Type error"
    
    f :: Env -> [C.Type] -> [C.Exp] -> C.Type -> Err [A.Exp]
    f env []   []       t = Ok []
    f env []   (y:ys)   t = Bad "Too few args@"
    f env (x:xs) []     t = Bad "Too few args"
    f env (x:xs) (y:ys) t = do 
                            aexp <- checkExp env (convertType x) y
                            aexps <- (f env xs ys t)
                            return (aexp:aexps)
    
    argToType :: C.Arg -> C.Type
    argToType (C.ADecl typ id) = typ
    
    -- convertProg :: [C.Def] -> [A.Def]
    -- convertProg [] = []
    -- convertProg (c:cs) = (convertDef c):(convertProg cs)
    
    -- convertDef :: C.Def -> A.Def
    -- convertDef (C.DFun t id args stms) = (A.DFun (convertType t) (convertId id) (map convertArg args) (map convertStm stms))
    
    convertArg :: C.Arg -> A.Arg
    convertArg (C.ADecl t id) = (A.ADecl (convertType t) (convertId id))
    
    convertId :: C.Id -> A.Id
    convertId (C.Id s) = (A.Id s)
    
    convertType :: C.Type -> A.Type
    convertType typ = case typ of
      C.Type_bool -> A.Type_bool
      C.Type_double -> A.Type_double
      C.Type_int -> A.Type_int
      C.Type_void -> A.Type_void