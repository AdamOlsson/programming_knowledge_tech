module SkelCpp where

-- Haskell module generated by the BNF converter

import AbsCpp
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transId :: Id -> Result
transId x = case x of
  Id string -> failure x
transProgram :: Program -> Result
transProgram x = case x of
  PDefs defs -> failure x
transDef :: Def -> Result
transDef x = case x of
  DUsing qconsts -> failure x
  DTypeDefId type_ id -> failure x
  DAssignment type_ asss -> failure x
  DFun type_ id args stms -> failure x
  DFunDeclare type_ id args -> failure x
transAss :: Ass -> Result
transAss x = case x of
  DAssId id -> failure x
  DAssIdEqId id exp -> failure x
  DAssRefIdEqExp id1 id2 -> failure x
transArg :: Arg -> Result
transArg x = case x of
  ADecl type_ -> failure x
  ADeclId type_ id -> failure x
  ADeclIdAss type_ id exp -> failure x
  ADeclRefId type_ id -> failure x
  ADeclRef type_ -> failure x
  ADeclConstRefId type_ id -> failure x
  ADeclConstRef type_ -> failure x
  ADeclConstTypeId type_ id -> failure x
transStm :: Stm -> Result
transStm x = case x of
  SExp exp -> failure x
  SConstRefDecl type_ id -> failure x
  SConstDeclsAss type_ ids exp -> failure x
  SConstRefDeclAss type_ id exp -> failure x
  SConstDecls type_ ids -> failure x
  SInit type_ recasss -> failure x
  SReturn exp -> failure x
  SWhileStm while stm -> failure x
  SWhileDumb while -> failure x
  SDo stm while -> failure x
  SBlock stms -> failure x
  SFor type_ id exp1 exp2 exp3 stm -> failure x
  SForDum type_ id exp1 exp2 stm -> failure x
  SForDum2 type_ id exp1 exp2 exp3 stm -> failure x
  SIfElse exp stm else_ -> failure x
  STypeDef type_ id -> failure x
transRecAss :: RecAss -> Result
transRecAss x = case x of
  SRecursiveAss id exp -> failure x
  SRecursiveDec id -> failure x
transWhile :: While -> Result
transWhile x = case x of
  SWhile exp -> failure x
transElse :: Else -> Result
transElse x = case x of
  NoSElse -> failure x
  YesSElse stm -> failure x
transQConsts :: QConsts -> Result
transQConsts x = case x of
  QConsts qconsts -> failure x
transQConst :: QConst -> Result
transQConst x = case x of
  QConst id -> failure x
transExp :: Exp -> Result
transExp x = case x of
  EChar char -> failure x
  EInt integer -> failure x
  EDouble double -> failure x
  EString lstrings -> failure x
  EConst qconsts -> failure x
  ETrue -> failure x
  EFalse -> failure x
  EIndex exp1 exp2 -> failure x
  EApp exp exps -> failure x
  EPIncr exp -> failure x
  EPDecr exp -> failure x
  EDot exp1 exp2 -> failure x
  EArrow exp1 exp2 -> failure x
  EIncr exp -> failure x
  EDecr exp -> failure x
  EDeref exp -> failure x
  ENeg exp -> failure x
  EMod exp1 exp2 -> failure x
  ETimes exp1 exp2 -> failure x
  EDiv exp1 exp2 -> failure x
  EPlus exp1 exp2 -> failure x
  EMinus exp1 exp2 -> failure x
  ELts exp1 exp2 -> failure x
  EGts exp1 exp2 -> failure x
  ELt exp1 exp2 -> failure x
  EGt exp1 exp2 -> failure x
  ELtEq exp1 exp2 -> failure x
  EGtWq exp1 exp2 -> failure x
  EEq exp1 exp2 -> failure x
  ENEq exp1 exp2 -> failure x
  EAnd exp1 exp2 -> failure x
  EOr exp1 exp2 -> failure x
  EAss exp1 exp2 -> failure x
  EAssNeg exp1 exp2 -> failure x
  EAssPos exp1 exp2 -> failure x
  EIf exp1 exp2 exp3 -> failure x
  EThrow exp -> failure x
transLStrings :: LStrings -> Result
transLStrings x = case x of
  LStrings strings -> failure x
transType :: Type -> Result
transType x = case x of
  Tbool -> failure x
  Tdouble -> failure x
  Tint -> failure x
  Tvoid -> failure x
  TConst qconsts -> failure x

