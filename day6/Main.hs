{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

import Data.Attoparsec.Text
import Data.Text (pack)
import System.IO

data FishLifetimes = FishLifetimes
  { zeroes :: Int
  , ones :: Int
  , twos :: Int
  , threes :: Int
  , fours :: Int
  , fives :: Int
  , sixes :: Int
  , sevens :: Int
  , eights :: Int
  }
  deriving Show

sumFish :: FishLifetimes -> Int
sumFish FishLifetimes {..} = zeroes + ones + twos + threes + fours + fives + sixes + sevens + eights

iterateFish :: FishLifetimes -> FishLifetimes
iterateFish FishLifetimes {..} =
  FishLifetimes
    { zeroes = ones
    , ones = twos
    , twos = threes
    , threes = fours
    , fours = fives
    , fives = sixes
    , sixes = zeroes + sevens
    , sevens = eights
    , eights = zeroes
    }

iterN :: Int -> FishLifetimes -> FishLifetimes
iterN 0 = id
iterN n = iterN (n - 1) . iterateFish

parseFile :: Parser FishLifetimes
parseFile = do
  res <- decimal `sepBy'` char ','
  endOfLine
  endOfInput
  let zeroes = length $ filter (== 0) res
      ones = length $ filter (== 1) res
      twos = length $ filter (== 2) res
      threes = length $ filter (== 3) res
      fours = length $ filter (== 4) res
      fives = length $ filter (== 5) res
      sixes = length $ filter (== 6) res
      sevens = length $ filter (== 7) res
      eights = length $ filter (== 8) res
  pure $ FishLifetimes {..}

main :: IO ()
main = do
  handle <- openFile "input.txt" ReadMode
  contents <- pack <$> hGetContents handle
  let mFish = parse parseFile contents
  fish <- case mFish of
    Done _ res -> pure res
    Partial c -> case c "" of
      Done _ res -> pure res
      x -> error $ show x
    x -> error $ show x
  let eightiethIteration = iterN 80 fish
      twoHundredFiftySixthIteration = iterN (256 - 80) eightiethIteration
  putStrLn $ show $ sumFish $ eightiethIteration
  putStrLn $ show $ sumFish $ twoHundredFiftySixthIteration
