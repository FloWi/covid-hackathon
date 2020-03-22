module Main where

import Prelude
import Control.Promise (Promise, fromAff)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Class.Console (log)
import Foreign.Object as FO
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Simple.JSON (writeJSON)

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
  = { name :: String
    , location :: Location
    }

fetch :: M.Fetch
fetch = M.fetch nodeFetch

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

run :: Input -> Effect (Promise Output)
run { body } =
  fromAff do
    log $ "Received body " <> body
    maybeText <- attempt $ postElasticSearch body >>= M.text
    log $ "Received this from elasticsearch " <> show maybeText
    pure case maybeText of
      Left e -> { statusCode: 500, body: show e, isBase64Encoded: false, headers: responseHeaders }
      Right _ -> { statusCode: 200, body: successResponseBody, isBase64Encoded: false, headers: responseHeaders }
  where
  successResponseBody = writeJSON { result: "Posted request successfully to elasticsearch" }
