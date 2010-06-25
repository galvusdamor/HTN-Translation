{-# OPTIONS_GHC
    -fcontext-stack=30
  #-}
{-# LANGUAGE
    DeriveDataTypeable,
    FlexibleContexts,
    FlexibleInstances,
    FunctionalDependencies,
    MultiParamTypeClasses,
    OverlappingInstances, 
    RankNTypes,
    ScopedTypeVariables,
    StandaloneDeriving, 
    TypeOperators,
    TypeSynonymInstances
  #-}
module HTNTranslation.HTNPDDL (
    module Planning.PDDL.PDDL3_0,
    StandardHTNDomain,
    Method(..), StandardMethod,
    HAction(..), StandardHAction,
    TaskHead(..), HasTaskHead, getTaskHead, setTaskHead,
    Branches(..), HasBranches, getBranches, setBranches,
    Branch(..), emptyBranch,
    TaskList, taskName, taskArgs, StdTask, StdTaskHead,
    parseHTNPDDL
) where

import Data.List
import Data.Generics (Data, Typeable, Typeable1, Typeable2)
import Data.Maybe
import Text.ParserCombinators.Parsec hiding (space)
import qualified Text.ParserCombinators.Parsec.Token as T
import Text.PrettyPrint

import Planning.PDDL.PDDL3_0
import Planning.PDDL.Parser

data HDomain a b = HDomain
    Name
    Requirements
    (Types TypedConstExpr)
    (Constants TypedConstExpr)
    (Predicates (Expr (Atomic TypedVarExpr)))
    (TaskHead [StdTaskDef])
    (Functions TypedFuncExpr)
    (Constraints a)
    (Items b)
    deriving (Data, Eq, Typeable)

instance (Data a, Data b) => HasName (HDomain a b)
instance (Data a, Data b) => HasRequirements (HDomain a b)
instance (Data a, Data b) => HasTypes TypedConstExpr (HDomain a b)
instance (Data a, Data b) => HasConstants TypedConstExpr (HDomain a b)
instance (Data a, Data b) => HasPredicates (Expr (Atomic TypedVarExpr)) (HDomain a b)
instance (Data a, Data b) => HasTaskHead [StdTaskDef] (HDomain a b)
instance (Data a, Data b) => HasFunctions TypedFuncExpr (HDomain a b)
instance (Data a, Data b) => HasConstraints a (HDomain a b)
instance (Data a, Data b) => HasItems b (HDomain a b)
instance (Data (Expr a), Data (Expr b), PDDLDoc a, PDDLDoc b) =>
    Show (HDomain (Expr a) (Expr b)) where
    show domain = show $ parens $ ($$) (text "define") $ vcat $
        parens (text "domain" <+> text (getName domain)) :
         -- Requirement strings are prefixed with ':'
        (if (null $ getRequirements domain) then empty else parens
            (sep $
             map (text . (':':)) $
             "requirements" : getRequirements domain)) :
        parens (sep $ (text ":types") :
            [pddlDoc t | (In t) <- getTypes domain]) :
        parens (sep $ (text ":predicates") :
            [pddlDoc p | (In p) <- getPredicates domain]) :
        parens (sep $ (text ":tasks") :
            [pddlDoc p | (In p) <- getTaskHead domain]) :
        space :
        intersperse space [pddlDoc x | In x <- getItems domain]

emptyHDomain :: forall a b. HDomain a b
emptyHDomain = HDomain
    (Name "empty")
    (Requirements [])
    (Types [])
    (Constants [])
    (Predicates [])
    (TaskHead [])
    (Functions [])
    (Constraints Nothing)
    (Items [])


type StandardHTNDomain = HDomain ConstraintGDExpr (Expr (DomainItem StandardHAction :+: DomainItem StandardMethod))
--deriving instance Data (Expr (DomainItem StandardHAction :+: DomainItem StandardMethod))

type TaskList = [Either (Expr PDDLAtom) [Expr PDDLAtom]]
taskName :: Expr (Atomic t) -> String
taskName (In (Atomic p _)) = p
taskArgs :: Expr (Atomic t) -> [t]
taskArgs (In (Atomic _ al)) = al

data Branch c = Branch {
    branchName :: String,
    bparameters :: [TypedVarExpr],
    bprecondition :: Maybe c,
    tasks :: TaskList
} deriving (Data, Eq)
deriving instance Typeable1 Branch

emptyBranch :: forall c. Branch c
emptyBranch = Branch {
    branchName = "empty",
    bparameters = [],
    bprecondition = Nothing,
    tasks = []
}

{-
data Method c e = Method {
    methodName :: String,
    mparameters :: [TypedVarExpr],
    taskHead :: Expr (Atomic TermExpr),
    mprecondition :: Maybe c,
    branches :: [Branch c]
} deriving Eq
instance Functor (Method c) where
    fmap f (Method n p t pre b) = Method n p t pre b
instance (Eq c) => FuncEq (Method c) where
    funcEq (Method n1 p1 h1 pre1 b1) (Method n2 p2 h2 pre2 b2) =
        (n1 == n2) && (p1 == p2) && (h1 == h2) && (pre1 == pre2) && (b1 == b2)
method name params task precond branches = inject (Method name params task precond branches)

instance PDDLDoc c => PDDLDoc (Method (Expr c)) where
    pddlDoc (Method name params (In task) precond branches) = parens $
        (text ":method" <+> text name) $$
        (text ":parameters" <+> parens (sep $ map pddlExprDoc params)) $$
        (text ":task" <+> pddlDoc task) $$
        (text ":precondition" <+> (case precond of
            Just (In c) -> pddlDoc c
            _ -> parens empty)) $$
        sep [text ":branches", parens (sep $ map branchDoc branches)]
        where
            branchDoc br = parens $
                (text ":branch" <+> text (branchName br)) $$
                (text ":parameters" <+> parens (sep $ map pddlExprDoc $ bparameters br)) $$
                (text ":precondition" <+> (case (bprecondition br) of
                    Just (In c) -> pddlDoc c
                    _ -> parens empty)) $$
                (text ":tasks" <+> sep [pddlDoc t | In t <- tasks br])
-}

data TaskHead f = TaskHead f deriving (Data, Eq, Typeable)
unTaskHead :: TaskHead t -> t
unTaskHead (TaskHead h) = h
class (Data a, Data f) => HasTaskHead f a | a -> f where
    getTaskHead :: a -> f
    getTaskHead = unTaskHead . fromJust . gfind
    setTaskHead :: f -> a -> a
    setTaskHead h r = fromJust $ greplace r (TaskHead h)

type StdTask = Expr (Atomic TermExpr)
type StdTaskHead = Maybe StdTask 
type StdTaskDef = Expr (Atomic TypedVarExpr)

data Branches c = Branches [Branch c] deriving (Data, Eq)
deriving instance Typeable1 Branches
unBranches :: Branches t -> [Branch t]
unBranches (Branches bl) = bl
class (Data a, Data c) => HasBranches c a | a -> c where
    getBranches :: a -> [Branch c]
    getBranches = unBranches . fromJust . gfind
    setBranches :: [Branch c] -> a -> a
    setBranches bl r = fromJust $ greplace r (Branches bl)

data Method c = Method
    Name
    (Parameters TypedVarExpr)
    (TaskHead StdTaskHead)
    (Precondition c)
    (Branches c)
    deriving (Data, Eq)
deriving instance Typeable1 Method


instance Data c => HasName (Method c)
instance Data c => HasParameters TypedVarExpr (Method c)
instance Data c => HasTaskHead StdTaskHead (Method c)
instance Data c => HasPrecondition c (Method c)
instance Data c => HasBranches c (Method c)

defaultMethod :: forall c. Method c
defaultMethod = Method undefined 
    (Parameters [])
    undefined
    (Precondition Nothing)
    (Branches [])

instance (Data (Expr c), PDDLDoc c) => PDDLDoc (DomainItem (Method (Expr c))) where
    pddlDoc (DomainItem m) = parens $ sep [
        text ":method" <+> text (getName m),
        text ":parameters" <+> parens (sep $ map pddlExprDoc $ getParameters m),
        docMaybe ":task" $ getTaskHead m,
        docMaybe ":precondition" $ getPrecondition m,
        sep [text ":branches", parens ( sep $ map branchDoc $ getBranches m )]]
        where
            branchDoc br = parens $ sep [
                text ":branch" <+> text (branchName br),
                text ":parameters" <+> parens (sep $ map pddlExprDoc $ bparameters br),
                docMaybe ":precondition" $ bprecondition br,
                text ":tasks" <+> parens (sep $ map taskDoc $ tasks br) ]
            taskDoc (Left task) = pddlExprDoc task
            taskDoc (Right tasks) = parens $ sep $ 
                text ":unordered" :
                map pddlExprDoc tasks
                
        

type StandardMethod = Method PreferenceGDExpr

data HAction p e = HAction
    Name
    (Parameters TypedVarExpr)
    (TaskHead StdTaskHead)
    (Precondition p)
    (Effect e)
    deriving (Data, Eq)
deriving instance Typeable2 HAction


instance (Data p, Data e) => HasName (HAction p e)
instance (Data p, Data e) => HasParameters TypedVarExpr (HAction p e)
instance (Data p, Data e) => HasTaskHead StdTaskHead (HAction p e)
instance (Data p, Data e) => HasPrecondition p (HAction p e)
instance (Data p, Data e) => HasEffect e (HAction p e)

defaultHAction :: forall p e. HAction p e
defaultHAction = HAction undefined 
    (Parameters [])
    (TaskHead Nothing)
    (Precondition Nothing)
    (Effect Nothing)

instance (Data (Expr p), Data (Expr e), PDDLDoc p, PDDLDoc e) => 
    PDDLDoc (DomainItem (HAction (Expr p) (Expr e))) where
    pddlDoc (DomainItem a) = parens $ sep [
        text ":action" <+> text (getName a),
        text ":parameters" <+> parens (sep $ map pddlExprDoc $ getParameters a),
        docMaybe ":task" $ getTaskHead a,
        docMaybe ":precondition" $ getPrecondition a,
        docMaybe ":effect" $ getEffect a]
                
        

type StandardHAction = HAction PreferenceGDExpr EffectDExpr


htnLanguage :: forall st. T.LanguageDef st
htnLanguage = pddlLanguage {
    T.reservedNames = T.reservedNames pddlLanguage ++
        [":method", ":task", ":tasks", ":branch", ":branches", ":unordered"]
    }

htnLexer :: forall st. T.TokenParser st
htnLexer = T.makeTokenParser htnLanguage

htnParser :: GenParser Char (StandardHTNDomain) (StandardHTNDomain)
htnParser = let 
        mylex = htnLexer 
        condParser = prefGDParser mylex 
        effParser = effectDParser mylex 
        constraintP = constraintGDParser mylex
        actions =
            (hActionParser mylex condParser effParser)
            <|>
            (methodParser mylex condParser :: CharParser StandardHTNDomain ())
    in
    domainParser mylex (hDomainInfoParser mylex constraintP) actions

hDomainInfoParser :: (HasRequirements st,
        HasTypes TypedConstExpr st,
        HasConstants TypedConstExpr st,
        HasConstraints a st,
        HasTaskHead [StdTaskDef] st,
        Atomic TypedVarExpr :<: f,
        HasPredicates (Expr f) st) =>
    T.TokenParser st
    -> CharParser st a
    -> CharParser st ()
hDomainInfoParser mylex condParser =
    (do
        try $ T.reserved mylex ":tasks"
        tasks <- many $ T.parens mylex (atomicParser mylex (parseTypedVar mylex))
        updateState (setTaskHead tasks))
    <|>
    domainInfoParser mylex condParser


hActionParser :: (Data p, Data e, HasItems (Expr f) st,
    DomainItem (HAction p e) :<: f) =>
    T.TokenParser st -> CharParser st p -> CharParser st e -> GenParser Char st ()
hActionParser mylex condParser effParser = do
    let infoParser = hActionInfoParser mylex condParser effParser
    try $ T.reserved mylex ":action"
    name <- T.identifier mylex
    updates <- many infoParser
    let action = foldl (\ a t -> t a) (setName name defaultHAction) updates
    updateState (\d -> setItems (domainItem action : getItems d) d)

hActionInfoParser :: (HasParameters TypedVarExpr a,
    HasTaskHead (Maybe (Expr f)) a,
    HasPrecondition b a,
    HasEffect c a,
    Atomic TermExpr :<: f) =>
    T.TokenParser st -> CharParser st b -> CharParser st c -> GenParser Char st (a -> a)
hActionInfoParser mylex condParser effParser =
    paramParser mylex
    <|>
    taskHeadParser mylex
    <|>
    precondParser mylex condParser
    <|>
    effectParser mylex effParser

    

methodParser :: forall f a b .
    ((:<:) (DomainItem (Method f)) b, Data f, Data a, Data (Expr b)) => 
    T.TokenParser (HDomain a (Expr b)) -> 
    CharParser (HDomain a (Expr b)) f -> 
    CharParser (HDomain a (Expr b)) ()
methodParser mylex condParser = do
    let 
        infoParser :: CharParser (HDomain a (Expr b)) (Method f -> Method f)
        infoParser = methodInfoParser mylex condParser 
    try $ T.reserved mylex ":method"
    name <- T.identifier mylex
    updates <- many infoParser
    let method = foldl (\a t -> t a) (setName name defaultMethod) updates
    updateState (\d -> setItems (domainItem method : getItems d) d)

methodInfoParser :: (HasParameters TypedVarExpr a,
    HasPrecondition b a,
    HasBranches b a,
    HasTaskHead (Maybe (Expr f)) a,
    Atomic TermExpr :<: f) =>
    T.TokenParser st -> CharParser st b -> CharParser st (a -> a)
methodInfoParser mylex condParser =
    paramParser mylex
    <|>
    precondParser mylex condParser
    <|>
    taskHeadParser mylex
    <|>
    (do
        try $ T.reserved mylex ":branches"
        bl <- T.parens mylex $ many $ branchParser mylex condParser
        return $ setBranches bl)

taskHeadParser :: (Atomic TermExpr :<: f,
        HasTaskHead (Maybe (Expr f)) a) =>
    T.TokenParser st -> GenParser Char st (a -> a)

taskHeadParser mylex = do
    try $ T.reserved mylex ":task"
    task <- maybeParser mylex $ atomicParser mylex (termParser mylex)
    return $ setTaskHead task

branchParser ::
    T.TokenParser st
    -> CharParser st a
    -> CharParser st (Branch a)
branchParser mylex condParser = T.parens mylex $ do
    T.reserved mylex ":branch"
    name <- T.identifier mylex
    collect (emptyBranch { branchName = name }) (\b ->
        (do
            try $ T.reserved mylex ":parameters"
            parameters <- T.parens mylex $ many $ parseTypedVar mylex
            return $ b { bparameters = parameters })
        <|>
        (do
            try $ T.reserved mylex ":precondition"
            cond <- maybeParser mylex condParser
            return $ b { bprecondition = cond })
        <|>
        (do
            try $ T.reserved mylex ":tasks"
            mytasks <- T.parens mylex $ many $ taskLIParser mylex
            return $ b { tasks = mytasks }))


taskLIParser :: (:<:) (Atomic TermExpr) f =>
    T.TokenParser st -> CharParser st (Either (Expr f) [Expr f])
taskLIParser mylex = T.parens mylex $
    (do
        try $ T.reserved mylex ":unordered"
        utasks <- many $ taskParser mylex
        return $ Right utasks)
    <|>
    (do
        task <- taskParser mylex
        return $ Left task)

taskParser :: (:<:) (Atomic TermExpr) f => 
    T.TokenParser st -> CharParser st (Expr f)
taskParser mylex = do
    name <- T.identifier mylex
    terms <- many $ termParser mylex
    return $ eAtomic name terms

parseHTNPDDL :: SourceName -> String -> Either ParseError StandardHTNDomain
parseHTNPDDL source input =
    runParser htnParser emptyHDomain source input
