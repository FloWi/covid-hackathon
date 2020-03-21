module Main where

import Prelude
import Control.Promise (Promise, fromAff, toAff)
import Data.Either (Either(..))
import Data.Semigroup.Foldable (intercalateMap)
import Effect (Effect)
import Effect.Aff (Aff, forkAff, joinFiber, launchAff_, runAff, attempt)
import Effect.Class.Console (log)
import Effect.Class (liftEffect)
import Foreign (renderForeignError)
import Foreign.Object as FO
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Simple.JSON (readJSON, writeJSON)
import Control.Promise as Promise

type Input
  = { body :: String
    }

type Output
  = { statusCode :: Int
    , body :: String
    , isBase64Encoded :: Boolean
    , headers :: FO.Object String
    }

type Location
  = { lon :: Number
    , lat :: Number
    }

type VoucherOffer
  = { info :: String
    , location :: Location
    }

example :: String
example =
  """
  { "info": "I have vouchers", 
    "location": { "lon": 52.52437, "lat": 13.41053 }
  }
  """

fetch :: M.Fetch
fetch = M.fetch nodeFetch

fetchGoogle :: Aff M.Response
fetchGoogle = fetch (M.URL "https://www.google.com") M.defaultFetchOptions

postElasticSearch :: String -> Aff M.Response
postElasticSearch body = fetch (M.URL "https://vpc-covid-es-in-vpc-sattub32j5fqdokoslmc4kjvvi.eu-west-1.es.amazonaws.com/vouchers/voucherOffer/") opts
  where
  opts =
    { method: M.postMethod
    , body
    , headers: M.makeHeaders { "Content-Type": "application/json" }
    }

logVoucherOffer :: VoucherOffer -> Aff Unit
logVoucherOffer vo = log (writeJSON vo)

responseHeaders :: FO.Object String
responseHeaders = FO.empty

foo :: String -> Aff M.Response
foo body = do
  fiber <- forkAff $ postElasticSearch body
  result <- joinFiber fiber
  pure $ result


run :: Input -> Effect (Promise Output)
run { body } = fromAff do
  log $ "Received body " <> body
  let
    voucherOffer = readJSON example
  case voucherOffer of
    Left errors -> log (intercalateMap "\n" renderForeignError errors)
    Right ok -> logVoucherOffer ok
  maybeText <- attempt $ postElasticSearch body >>= M.text
  log $ "Received this from elasticsearch " <> (show maybeText)
  --log $ "I'm here " <> text
  pure $ { statusCode: 200, body: responseBody, isBase64Encoded: false, headers: responseHeaders }
  where
  responseBody = writeJSON { hello: "World" }
