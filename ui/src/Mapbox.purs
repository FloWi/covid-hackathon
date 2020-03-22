module Mapbox where 

import Prelude

import Data.Function.Uncurried (Fn1,Fn2, Fn3, runFn1, runFn2, runFn3)
import Effect (Effect)

foreign import data Map :: Type 

foreign import makeMapUncurried :: Fn1 String (Effect Map)

foreign import setCenterUncurried :: Fn3 Map Number Number (Effect Unit) 

foreign import setZoomUncurried :: Fn2 Map Int (Effect Unit)

makeMap :: String -> Effect Map
makeMap = runFn1 makeMapUncurried

setCenter :: Map -> Number -> Number -> Effect Unit
setCenter = runFn3 setCenterUncurried

setZoom :: Map -> Int -> Effect Unit 
setZoom = runFn2 setZoomUncurried