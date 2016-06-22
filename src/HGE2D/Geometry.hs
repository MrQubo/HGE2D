module HGE2D.Geometry where

import HGE2D.Math
import HGE2D.Types
import HGE2D.Datas

---TODO rewrite most / all functions to use classes
rad2deg :: Double -> Double
rad2deg rad = rad * 180 / pi

deg2rad :: Double -> Double
deg2rad deg = deg * pi / 180

radRealPos :: RealPosition -> RealPosition -> Radian
radRealPos p1 p2 = atan2 dY dX
  where
    Meter dX = (fst p2) - (fst p1)
    Meter dY = (snd p2) - (snd p1)


velAngle :: Velocity -> Radian
velAngle v = atan2 (velY v) (velX v)


distance :: RealPosition -> RealPosition -> Double
distance v1 v2 = sqrt $ (fst v1 - fst v2)**2 + (snd v1 - snd v2)**2

direction :: RealPosition -> RealPosition -> RealPosition --- TODO define different types?
direction pos1 pos2 = (newX, newY)
  where
    newX = ((fst pos2) - (fst pos1)) / l
    newY = ((snd pos2) - (snd pos1)) / l
    l = distance pos1 pos2


interceptionPos :: (RealPosition, Double) -> (RealPosition, Velocity) -> RealPosition
interceptionPos (p1, v) (p2, v2) = (newX, newY)
  where
    tx = (fst p2) - (fst p1)
    ty = (snd p2) - (snd p1)
    tvx = velX v2
    tvy = velY v2

    a = tvx*tvx + tvy*tvy - v*v :: Double
    b = 2 * (tvx * tx + tvy * ty) :: Double
    c = tx*tx + ty*ty :: Double

    ts = quadraticEquation a b c
    t0 = fst ts
    t1 = snd ts
    temp = min t0 t1
    t | temp > 0 = temp
      | otherwise = max t0 t1

    newX = (fst p2) + (velX v2) * t
    newY = (snd p2) + (velY v2) * t

makeRB :: RealPosition -> Velocity -> Pixel -> Pixel -> RigidBody
makeRB center vel width height = RigidBody { rigidPos = center, rigidVel = vel, rigidBB = sizedBB center width height }

sizedBB :: RealPosition -> Pixel -> Pixel -> BoundingBox
sizedBB center width height = BoundingBox posMin posMax
  where
    posMin = (minX, minY)
    posMax = (maxX, maxY)
    minX = (fst center) - width / 2
    minY = (snd center) - height / 2
    maxX = (fst center) + width / 2
    maxY = (snd center) + height / 2

sizeBB :: BoundingBox -> (Pixel, Pixel)
sizeBB bb = (width, height)
  where
    width  = (fst $ bbMax bb) - (fst $ bbMin bb)
    height = (snd $ bbMax bb) - (snd $ bbMin bb)

centerBB :: BoundingBox -> RealPosition
centerBB bb = (newX, newY)
  where
    newX = (fst $ bbMin bb) + (width / 2)
    newY = (snd $ bbMin bb) + (height / 2)
    (width, height) = sizeBB bb

mergeBB :: BoundingBox -> BoundingBox -> BoundingBox
mergeBB bb1 bb2 = BoundingBox newMin newMax
  where
    newMin = mergeMin (bbMin bb1) (bbMin bb2)
    newMax = mergeMax (bbMax bb1) (bbMax bb2)

    mergeMin :: RealPosition -> RealPosition -> RealPosition
    mergeMin pos1 pos2 = (x, y)
      where
       x = min (fst pos1) (fst pos2)
       y = min (snd pos1) (snd pos2)

    mergeMax :: RealPosition -> RealPosition -> RealPosition
    mergeMax pos1 pos2 = (x, y)
      where
       x = max (fst pos1) (fst pos2)
       y = max (snd pos1) (snd pos2)

{- see above
tilePosToBB :: TilePosition -> BoundingBox
tilePosToBB pos = BoundingBox minPos maxPos
  where
    minPos = toRealPos $ pos
    maxPos = RealPosition maxX maxY
    maxX = (fst minPos) + tileSize
    maxY = (snd minPos) + tileSize
-}


makeBB :: RealPosition -> Pixel -> Pixel -> BoundingBox
makeBB center width height = BoundingBox newMin newMax
  where
    newMin = ((fst center - width / 2), (snd center - height / 2))
    newMax = ((fst center + width / 2), (snd center + height / 2))

applyVelocity :: RealPosition -> Velocity -> Millisecond -> RealPosition
applyVelocity oldPos vel time =
    (((fst oldPos) + (fromIntegral time) * (velX vel)),
    ((snd oldPos) + (fromIntegral time) * (velY vel)))
