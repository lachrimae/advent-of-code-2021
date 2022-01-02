{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE MultiWayIf #-}

import Data.Attoparsec.Text
import Data.Set
import Data.Text (pack)
import System.IO

data Coordinate = Coordinate { projectX :: Int, projectY :: Int }
  deriving (Eq, Ord, Show)
data Edge = Edge Coordinate Coordinate
  deriving (Eq, Ord, Show)
data Orientation = Vertical | Horizontal | Diagonal
  deriving Eq

orientation :: Edge -> Orientation
orientation (Edge start end)
  | projectX start == projectX end = Vertical
  | projectY start == projectY end = Horizontal
  | otherwise                      = Diagonal

points :: Edge -> [Coordinate]
points edge@(Edge start end) =
  case orientation edge of
    Vertical ->
      let high = projectY start `max` projectY end
          low = projectY start `min` projectY end
          raw = [(projectX start, y) | y <- [low..high]]
       in fmap (uncurry Coordinate) raw
    Horizontal ->
      let high = projectX start `max` projectX end
          low = projectX start `min` projectX end
          raw = [(x, projectY start) | x <- [low..high]]
       in fmap (uncurry Coordinate) raw
    Diagonal -> []

getPointsWithTwoOverlaps :: [Edge] -> Set Coordinate
getPointsWithTwoOverlaps [] = empty
getPointsWithTwoOverlaps as = getPointsWithTwoOverlaps' as empty empty
  where
    getPointsWithTwoOverlaps' [] _ pointsWithTwoOverlaps = pointsWithTwoOverlaps
    getPointsWithTwoOverlaps' (edge : edges) pointsWithOneOverlap pointsWithTwoOverlaps =
      let newPoints = fromList $ points edge
          newPointsWithOneOverlap =
            pointsWithOneOverlap `union` newPoints
          newPointsWithTwoOverlaps =
            pointsWithTwoOverlaps `union`
              (pointsWithOneOverlap `intersection` newPoints)
       in getPointsWithTwoOverlaps'
            edges
            newPointsWithOneOverlap
            newPointsWithTwoOverlaps

parsePair :: Parser Coordinate
parsePair = Coordinate <$> decimal <* char ',' <*> decimal

parseLine :: Parser Edge
parseLine = Edge <$> parsePair <* string " -> " <*> parsePair

parseFile :: Parser [Edge]
parseFile = do
  res <- sepBy' parseLine $ char '\n'
  endOfLine
  endOfInput
  pure res

main :: IO ()
main = do
  handle <- openFile "input.txt" ReadMode
  contents <- pack <$> hGetContents handle
  let mEdges = parse parseFile contents
  edges <- case mEdges of
    Done _ res -> pure res
    Partial c -> case c "" of
      Done _ res -> pure res
      x -> error $ show x
    x -> error $ show x
  let overlappedEdges = getPointsWithTwoOverlaps edges
  putStrLn $ show $ size $ overlappedEdges
