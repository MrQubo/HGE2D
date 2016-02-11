module HGE2D.ShapeFactory where

import HGE2D.Settings
import HGE2D.Types
import HGE2D.Datas
import HGE2D.GlFunctions
import HGE2D.Geometry

import qualified Graphics.Rendering.OpenGL as GL

--------------------------------------------------------------------------------


---TODO rename simply to shapes


---TODO to different file

---TODO move these elsewhere and properly define their types

borderedRectangle w h t colorInner colorBorder = RenderMany 
    [ RenderColorize colorInner
    , rectangle w h
    , RenderColorizeAlpha colorBorder
    , wireFrame w h t
    ]

line :: GlPoint2 -> GlPoint2 -> GlThickness -> RenderInstruction
line start end w = RenderLineStrip [start, end] w

wireFrame :: GlWidth -> GlHeight -> GlThickness -> RenderInstruction
wireFrame w h t = RenderLineLoop [ll, lr, ur, ul] t
  where
    ll = point2 xMin yMin
    lr = point2 xMax yMin
    ur = point2 xMax yMax
    ul = point2 xMin yMax

    xMin = - (w/2)
    xMax =   (w/2)
    yMin = - (h/2)
    yMax =   (h/2)


rectangle :: GlWidth -> GlHeight -> RenderInstruction
rectangle w h = RenderTriangle [ll, lr, ur, ur, ul, ll]
  where
    ll = point2 xMin yMin
    lr = point2 xMax yMin
    ur = point2 xMax yMax
    ul = point2 xMin yMax

    xMin = - (w/2)
    xMax =   (w/2)
    yMin = - (h/2)
    yMax =   (h/2)

ring :: GlRadius -> GlThickness -> RenderInstruction
ring r w = RenderLineLoop (buildRing 0 []) w
  where
    buildRing :: Int -> GlShape -> GlShape
    buildRing nVertex prevShape
      | nVertex >= nFacesCircle = prevShape
      | otherwise = buildRing (nVertex+1) (prevShape ++ [vertex])
        where
          vertex = pointOnCircle nVertex

          pointOnCircle :: Int -> GlPoint2 ---TODO defined twice, move somewhere else
          pointOnCircle i = GL.Vertex2 x y
            where
              x = r * cos phi
              y = r * sin phi
              phi = 2.0 * pi * (fromIntegral i / fromIntegral nFacesCircle)


circle :: GlRadius -> RenderInstruction
circle r = RenderTriangle (buildCircle 0 [])
  where
    buildCircle :: Int -> GlShape -> GlShape
    buildCircle nFace prevShape
      | nFace >= nFacesCircle = prevShape
      | otherwise = buildCircle (nFace+1) (prevShape ++ face)
        where
          face   = [(GL.Vertex2 0 0), first, second]
          first  = pointOnCircle nFace
          second = pointOnCircle (nFace+1)

          pointOnCircle :: Int -> GlPoint2
          pointOnCircle i = GL.Vertex2 x y
            where
              x = r * cos phi
              y = r * sin phi
              phi = 2.0 * pi * (fromIntegral i / fromIntegral nFacesCircle)
