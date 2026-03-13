-- TSP_Zadacha_Romanchuk.hs
-- Traveling Salesperson Problem (TSP) — Romanchuk Anna

module TSP where

import Data.List (permutations, minimumBy, delete)
import Data.Ord  (comparing)

type Matrix = [[Int]]
type City   = Int
type Tour   = [City]

sampleMatrix :: Matrix
sampleMatrix =
  [ [0,  10, 15, 20, 10, 25]
  , [10, 0,  35, 25, 17, 30]
  , [15, 35, 0,  30, 28, 14]
  , [20, 25, 30, 0,  16, 18]
  , [10, 17, 28, 16, 0,  12]
  , [25, 30, 14, 18, 12, 0 ]
  ]

dist :: Matrix -> City -> City -> Int
dist m i j = (m !! (i - 1)) !! (j - 1)

cost :: Matrix -> Tour -> Int
cost m xs = sum $ zipWith (dist m) xs (tail xs)

tspBruteforce :: Matrix -> City -> (Tour, Int)
tspBruteforce m start =
  minimumBy (comparing snd)
    [ (tour, cost m tour)
    | perm <- permutations others
    , let tour = start : perm ++ [start]
    ]
  where
    n      = length m
    cities = [1..n]
    others = filter (/= start) cities

tspGreedy :: Matrix -> City -> (Tour, Int)
tspGreedy m start = (tourClosed, cost m tourClosed)
  where
    n        = length m
    cities   = [1..n]
    rem0     = delete start cities
    tourPath = go start rem0 [start]      
    tourClosed = tourPath ++ [start]

    go _    []   acc = acc
    go curr rem acc =
      let next = minimumBy (comparing (dist m curr)) rem
      in go next (delete next rem) (acc ++ [next])

-- Quick demo prints (for GHCi)
demo :: IO ()
demo = do
  let (tOpt, cOpt) = tspBruteforce sampleMatrix 1
  putStrLn $ "Brute force optimum: " ++ show cOpt ++ " " ++ show tOpt
  let (tG, cG) = tspGreedy sampleMatrix 1
  putStrLn $ "Greedy: " ++ show cG ++ " " ++ show tG