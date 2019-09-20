

module AbsCpp where

-- Haskell module generated by the BNF converter




newtype Id = Id String deriving (Eq, Ord, Show, Read)
data Program = PDefs [Def]
  deriving (Eq, Ord, Show, Read)

data Def
    = DUsing QConsts
    | DTypeDefId Type Id
    | DAssignment Type [Ass]
    | DFun Type Id [Arg] [Stm]
    | DFunDeclare Type Id [Arg]
  deriving (Eq, Ord, Show, Read)

data Ass = DAssId Id | DAssIdEqId Id Exp | DAssRefIdEqExp Id Id
  deriving (Eq, Ord, Show, Read)

data Arg
    = ADecl Type
    | ADeclId Type Id
    | ADeclIdAss Type Id Exp
    | ADeclRefId Type Id
    | ADeclRef Type
    | ADeclConstRefId Type Id
    | ADeclConstRef Type
    | ADeclConstTypeId Type Id
  deriving (Eq, Ord, Show, Read)

data Stm
    = SExp Exp
    | SConstRefDecl Type Id
    | SConstDeclsAss Type [Id] Exp
    | SConstRefDeclAss Type Id Exp
    | SConstDecls Type [Id]
    | SInit Type [RecAss]
    | SReturn Exp
    | SWhileStm While Stm
    | SWhileDumb While
    | SDo Stm While
    | SBlock [Stm]
    | SFor Type Id Exp Exp Exp Stm
    | SForDum Type Id Exp Exp Stm
    | SForDum2 Type Id Exp Exp Exp Stm
    | SIfElse Exp Stm Else
    | STypeDef Type Id
  deriving (Eq, Ord, Show, Read)

data RecAss = SRecursiveAss Id Exp | SRecursiveDec Id
  deriving (Eq, Ord, Show, Read)

data While = SWhile Exp
  deriving (Eq, Ord, Show, Read)

data Else = NoSElse | YesSElse Stm
  deriving (Eq, Ord, Show, Read)

data QConsts = QConsts [QConst]
  deriving (Eq, Ord, Show, Read)

data QConst = QConst Id
  deriving (Eq, Ord, Show, Read)

data Exp
    = EChar Char
    | EInt Integer
    | EDouble Double
    | EString LStrings
    | EConst QConsts
    | ETrue
    | EFalse
    | EIndex Exp Exp
    | EApp Exp [Exp]
    | EPIncr Exp
    | EPDecr Exp
    | EDot Exp Exp
    | EArrow Exp Exp
    | EIncr Exp
    | EDecr Exp
    | EDeref Exp
    | ENeg Exp
    | EMod Exp Exp
    | ETimes Exp Exp
    | EDiv Exp Exp
    | EPlus Exp Exp
    | EMinus Exp Exp
    | ELts Exp Exp
    | EGts Exp Exp
    | ELt Exp Exp
    | EGt Exp Exp
    | ELtEq Exp Exp
    | EGtWq Exp Exp
    | EEq Exp Exp
    | ENEq Exp Exp
    | EAnd Exp Exp
    | EOr Exp Exp
    | EAss Exp Exp
    | EAssNeg Exp Exp
    | EAssPos Exp Exp
    | EIf Exp Exp Exp
    | EThrow Exp
  deriving (Eq, Ord, Show, Read)

data LStrings = LStrings [String]
  deriving (Eq, Ord, Show, Read)

data Type = Tbool | Tdouble | Tint | Tvoid | TConst QConsts
  deriving (Eq, Ord, Show, Read)

