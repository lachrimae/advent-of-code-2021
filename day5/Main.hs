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
data Relation = Positive | Negative
  deriving Eq

orientation :: Edge -> Orientation
orientation (Edge start end)
  | projectX start == projectX end = Vertical
  | projectY start == projectY end = Horizontal
  | otherwise                      = Diagonal

points1 :: Edge -> [Coordinate]
points1 edge@(Edge start end) =
  fmap (uncurry Coordinate) $
    case orientation edge of
      Vertical ->
        let high = projectY start `max` projectY end
            low = projectY start `min` projectY end
         in [(projectX start, y) | y <- [low..high]]
      Horizontal ->
        let high = projectX start `max` projectX end
            low = projectX start `min` projectX end
         in [(x, projectY start) | x <- [low..high]]
      Diagonal ->
        []

points2 :: Edge -> [Coordinate]
points2 edge@(Edge start end) =
  fmap (uncurry Coordinate) $
    case orientation edge of
      Vertical ->
        let high = projectY start `max` projectY end
            low = projectY start `min` projectY end
         in [(projectX start, y) | y <- [low..high]]
      Horizontal ->
        let high = projectX start `max` projectX end
            low = projectX start `min` projectX end
         in [(x, projectY start) | x <- [low..high]]
      Diagonal ->
        let xDelta = (projectX end - projectX start)
            yDelta = (projectY end - projectY start)
            relation = if xDelta * yDelta >= 0 then Positive else Negative
            highX = projectX start `max` projectX end
            highY = projectY start `max` projectY end
            lowX = projectX start `min` projectX end
            lowY = projectY start `min` projectY end
            ys = [lowY..highY]
            orderedYs =
              case relation of
                Positive -> ys
                Negative -> reverse ys
         in zip [lowX..highX] orderedYs

getPointsWithTwoOverlaps :: (Edge -> [Coordinate]) -> [Edge] -> Set Coordinate
getPointsWithTwoOverlaps _ [] = empty
getPointsWithTwoOverlaps points as = getPointsWithTwoOverlaps' as empty empty
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
  let overlappedEdges1 = getPointsWithTwoOverlaps points1 edges
  let overlappedEdges2 = getPointsWithTwoOverlaps points2 edges
  putStrLn $ show $ size $ overlappedEdges1
  putStrLn $ show $ size $ overlappedEdges2
