{-# LANGUAGE FlexibleContexts,OverlappingInstances,RankNTypes,ScopedTypeVariables,UndecidableInstances#-}
{-# OPTIONS
 -fcontext-stack=40
#-}
module Main where

import Control.Monad
import Data.Function
import Data.List
import System.Environment
import System.Random
import Text.Printf

import Planning.PDDL.PDDL3_0
import RandomUtils (mkRandomPaths)

-- Constants for adding stack predicates and items.

newRandomList range = do
    g <- newStdGen
    let l = randomRs range g
    return l

-- Randomly permute a list
permute l = do
    -- generate random list of floats
    rl <- newRandomList (0.0 :: Float, 1.0)
    -- zip and sort list according to floats
    let zl = zip rl l
    let sorted = sort zl
    -- return sorted list.
    return $ map snd sorted

roomName 0 = "c"
roomName n = 'r' : show n
doorName (r1, r2) = 'd' : concatMap show (sort [r1, r2])
pkgName n = 'o' : show n

makeRooms :: forall t f . ((:<:) Const t, (:<:) (Atomic (Expr t)) f) =>
    (Expr t) -> [(Int, Int)] -> [Bool] -> [Expr f]
makeRooms template doors states =
    let bothSides = nub $ sort $ doors ++ [(r2, r1) | (r1, r2) <- doors] in
    [ eAtomic "door" $ map (eConst :: String -> Expr t)
        [roomName $ fst d, roomName $ snd d, doorName d] | d <- bothSides ] ++
    [ eAtomic "closed" [eConst (doorName d) :: Expr t] | (d, t) <- zip doors states, t ]

placePackages :: forall t f . ((:<:) Const t, (:<:) (Atomic (Expr t)) f) =>
    (Expr t) -> String -> [(Int, String)] -> [Expr f]
placePackages template pred packageLocs =
    [ eAtomic pred [eConst p, eConst $ roomName d :: Expr t] | (d, p) <- packageLocs ]

-- Set up the initial and goal states of a problem
makeRobotProblem pname roomCount packageLocs goalLocs doors closedDoors =
    let
        consts = 
            [ eTyped (eConst p :: Expr Const) ["PACKAGE"] | p <- map snd packageLocs ] ++
            [ eTyped (eConst (roomName r) :: Expr Const) ["ROOM"]
                | r <- [0 .. roomCount] ] ++
            [ eTyped (eConst (doorName d) :: Expr Const) ["ROOMDOOR"]
                | d <- doors ]
        initAtoms :: [InitLiteralExpr]
        initAtoms = 
            eAtomic "rloc" [eConst (roomName 0) :: ConstTermExpr] :
            eAtomic "armempty" ([] :: [ConstTermExpr]) :
            makeRooms (undefined :: ConstTermExpr) doors closedDoors ++
            placePackages (undefined :: ConstTermExpr) "in" packageLocs
        goalAtoms :: [PreferenceGDExpr]
        goalAtoms = 
            placePackages (undefined :: TermExpr) "in" goalLocs
    in 
    setName pname $
    setDomainName "robot" $
    setConstants consts $
    setInitial initAtoms $
    setGoal (Just $ eAnd goalAtoms)
        emptyProblem

        

genPackages :: Int -> [String] -> IO [(Int, String)]
genPackages roomCount pkgs = do
    rooms <- newRandomList (1, roomCount)
    return $ zip rooms pkgs

{-
addGoalsAndTask :: [(Int, String)] -> PDDLProblem -> PDDLProblem
addGoalsAndTask goalLocs prob =
    let 
        startTask = eAtomic "start_achieve-goals" ([] :: [ConstTermExpr])
        goals :: [InitLiteralExpr]
        goals = placePackages (undefined :: ConstTermExpr) "goal-in" goalLocs 
        initial = startTask : goals ++ getInitial prob
    in
    setInitial initial prob
-}

stdConnections = [
    (0,1),
    (0,4),
    (0,5),
    (0,6),
    (1,2),
    (2,3),
    (6,7)]

makeProblemFiles :: String -> Int -> Int -> IO ()
makeProblemFiles fname roomCount pkgCount = do
    let basename = printf "%s_%d_%d" fname roomCount pkgCount
    connections <- mkRandomPaths (roomCount + 1) (\x -> x - 1)
    let pkgs = ['o' : show n | n <- [1 .. pkgCount]]
    initState <- genPackages roomCount pkgs
    goalState <- genPackages roomCount pkgs
    closedDoors <- newRandomList (False, True)
    let prob :: PDDLProblem = makeRobotProblem basename roomCount initState goalState connections closedDoors
    putStrLn $ printf "Writing %s" basename
    writeFile (basename ++ ".pddl") (show $ pddlDoc prob)

main = do
    [fname, roomStart, roomEnd, roomStep, packageStart, packageEnd, packageStep] <- getArgs
    sequence_ [
        makeProblemFiles fname rooms packages
        | rooms <- toCount roomStart roomEnd roomStep, 
          packages <- toCount packageStart packageEnd packageStep ]
    where
        toCount startStr endStr stepStr = takeWhile (<= read endStr) $ iterate (+ read stepStr) $ read startStr
    
