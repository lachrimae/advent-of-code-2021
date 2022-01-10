{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Data.Attoparsec.Text
import Data.List
import Data.Maybe
import Data.Text (pack)
import System.IO

data CrabCrew = CrabCrew
  { crewPosition :: Int
  , crewCount :: Int
  }
  deriving (Eq, Show)
newtype Crabs = Crabs [CrabCrew]
  deriving Show

-- this is a pathological Ord instance but it's fine for
-- a one-off script like this
instance Ord CrabCrew where
  compare (CrabCrew c1 _) (CrabCrew c2 _) = compare c1 c2

parseFile :: Parser Crabs
parseFile = do
  res <- decimal `sepBy'` char ','
  endOfLine
  endOfInput
  pure . Crabs . sort . getCrabCrews $ res
  where
    -- | first argument is crab positions
    getCrabCrews :: [Int] -> [CrabCrew]
    getCrabCrews [] = []
    getCrabCrews ns@(n : _) =
      let (crew, leftover) = countCrabsInPosn n ns
       in crew : getCrabCrews leftover
    countCrabsInPosn :: Int -> [Int] -> (CrabCrew, [Int])
    countCrabsInPosn posn as =
      let res = countCrabsInPosn' posn as
          count' = length . filter isNothing $ res
          leftover = catMaybes res
       in (CrabCrew posn count', leftover)
    -- replace matching positions with Nothing, as though
    -- deleting them from the list
    countCrabsInPosn' _ [] = []
    countCrabsInPosn' posn (a : as)
      | posn == a = Nothing : countCrabsInPosn' posn as
      | otherwise = Just a : countCrabsInPosn' posn as

cheapestLocationCost :: (Int -> CrabCrew -> Int) -> Crabs -> [Int]
cheapestLocationCost costFunction (Crabs crabs) =
  let minPosn = minimum . fmap crewPosition $ crabs
      maxPosn = maximum . fmap crewPosition $ crabs
      posns = [minPosn..maxPosn]
      locationCost posn = sum . fmap (costFunction posn) $ crabs
   in fmap locationCost posns

part1Cost :: Int -> CrabCrew -> Int
part1Cost posn CrabCrew {..} =
  abs $ crewCount * (posn - crewPosition)

part2Cost :: Int -> CrabCrew -> Int
part2Cost posn CrabCrew {..} =
  let n = abs $ crewPosition - posn
      numerator = n * (n + 1)
   in crewCount * numerator `div` 2

main :: IO ()
main = do
  handle <- openFile "input.txt" ReadMode
  contents <- pack <$> hGetContents handle
  let mCrabs = parse parseFile contents
  crabs <- case mCrabs of
    Done _ res -> pure res
    Partial c -> case c "" of
      Done _ res -> pure res
      x -> error $ show x
    x -> error $ show x
  putStrLn $ show . minimum $ cheapestLocationCost part1Cost crabs
  putStrLn $ show . minimum $ cheapestLocationCost part2Cost crabs
