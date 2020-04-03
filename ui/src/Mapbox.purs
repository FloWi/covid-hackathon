module Mapbox where 

import Prelude

import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn5, runFn1, runFn2, runFn3, runFn5)
import Effect (Effect)

foreign import data Map :: Type 

foreign import makeMapUncurried :: Fn1 String (Effect Map)

foreign import setCenterUncurried :: Fn3 Map Number Number (Effect Unit) 

foreign import setZoomUncurried :: Fn2 Map Int (Effect Unit)

foreign import addMarkerUncurried :: Fn5 Map Number Number String String (Effect Unit)

makeMap :: String -> Effect Map
makeMap = runFn1 makeMapUncurried

setCenter :: Map -> Number -> Number -> Effect Unit
setCenter = runFn3 setCenterUncurried

setZoom :: Map -> Int -> Effect Unit 
setZoom = runFn2 setZoomUncurried

addMarker :: Map -> Number -> Number -> String -> String -> Effect Unit
addMarker = runFn5 addMarkerUncurried