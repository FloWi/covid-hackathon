module Main where

import Prelude
import Data.Either (Either(..))
import Data.Semigroup.Foldable (intercalateMap)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log)
import Foreign (renderForeignError)
import Foreign.Object as FO
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Simple.JSON (readJSON, writeJSON)

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
    , body: body
    , headers: M.makeHeaders { "Content-Type": "application/json" }
    }

logVoucherOffer :: VoucherOffer -> Aff Unit
logVoucherOffer vo = log (writeJSON vo)

responseHeaders :: FO.Object String
responseHeaders = FO.empty

run :: Input -> Effect Output
run { body } = do
  log $ "Received body " <> body
  launchAff_ do
    let
      voucherOffer = readJSON example
    case voucherOffer of
      Left errors -> log (intercalateMap "\n" renderForeignError errors)
      Right ok -> logVoucherOffer ok
    response <- postElasticSearch body
    text <- M.text response
    log $ "Received this from elasticsearch " <> text
  pure $ { statusCode: 200, body: responseBody, isBase64Encoded: false, headers: responseHeaders }
  where
  responseBody = writeJSON { hello: "World" }
 -- handler :: Input -> Output -- handler = unsafePerformEffect <<< run
