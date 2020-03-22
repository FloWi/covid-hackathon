module Main where

import Prelude
import Control.Promise (Promise, fromAff)
import Data.Either (Either(..))
import Data.Semigroup.Foldable (intercalateMap)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log, logShow)
import Foreign (renderForeignError)
import Foreign.Object as FO
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Simple.JSON (readJSON, writeJSON)

type Input
  = { body :: String
    }

type Location
  = { lon :: Number
    , lat :: Number
    }

type VoucherApiRequest
  = { location :: Location
    }

type Store
  = { name :: String
    , location :: Location
    }

type VoucherApiResponse
  = { voucherOffers :: Array Store
    }

type Output
  = { statusCode :: Int
    , body :: String
    , isBase64Encoded :: Boolean
    , headers :: FO.Object String
    }

type EsGeoRequest
  = { distanceMeters :: Int
    , location :: Location
    }

type EsGeoQueryJSON
  = { query ::
        { bool ::
            { filter ::
                { geo_distance ::
                    { distance :: String
                    , "store.location" ::
                        { lat :: Number
                        , lon :: Number
                        }
                    }
                }
            , must ::
                { match_all :: Record ()
                }
            }
        }
    }

toEsQuery :: EsGeoRequest -> EsGeoQueryJSON
toEsQuery r =
  { "query":
      { "bool":
          { "must":
              { "match_all": {}
              }
          , "filter":
              { "geo_distance":
                  { "distance": show r.distanceMeters <> "km"
                  , "store.location":
                      { "lat": r.location.lat
                      , "lon": r.location.lon
                      }
                  }
              }
          }
      }
  }

type VoucherOfferJson
  = { store ::
        { location ::
            { lat :: Number
            , lon :: Number
            }
        , name :: String
        }
    }

type EsQueryResponse
  = { hits ::
        { hits ::
            Array
              { _score :: Int
              , _source :: VoucherOfferJson
              }
        , max_score :: Int
        , total :: Int
        }
    }

example :: String
example =
  """
    { "lat": 50.935, "lon": 6.953 }
  """

fetch :: M.Fetch
fetch = M.fetch nodeFetch

fetchGoogle :: Aff M.Response
fetchGoogle = fetch (M.URL "https://www.google.com") M.defaultFetchOptions

retrieveVoucherStores :: Location -> Aff VoucherApiResponse
retrieveVoucherStores location = do
  let
    geoReq = { distanceMeters: 5, location: location }
  let
    esQuery = toEsQuery geoReq
  esResp <- getElasticSearch $ writeJSON esQuery
  text <- M.text esResp
  case readJSON text of
    Left errors -> log (intercalateMap "\n" renderForeignError errors) $> { voucherOffers: [] }
    Right (ok :: EsQueryResponse) -> pure $ { voucherOffers: map _._source.store ok.hits.hits }

getElasticSearch :: String -> Aff M.Response
getElasticSearch body = fetch (M.URL "https://vpc-covid-es-in-vpc-sattub32j5fqdokoslmc4kjvvi.eu-west-1.es.amazonaws.com/vouchers/_search") opts
  where
  opts =
    { method: M.postMethod
    , body
    , headers: M.makeHeaders { "Content-Type": "application/json" }
    }

main :: Effect Unit
main =
  launchAff_ do
    case readJSON example of
      Left errors -> log (intercalateMap "\n" renderForeignError errors)
      Right ok -> do
        stores <- retrieveVoucherStores ok
        logShow stores

responseHeaders :: FO.Object String
responseHeaders = FO.singleton "Access-Control-Allow-Origin" "*"

run :: Input -> Effect (Promise Output)
run { body } =
  fromAff do
    log $ "Received body " <> body
    output <- case readJSON body of
      Left errors -> log (intercalateMap "\n" renderForeignError errors) $> { voucherOffers: [] }
      Right ok -> retrieveVoucherStores ok
    pure $ { statusCode: 200, body: writeJSON output, isBase64Encoded: false, headers: responseHeaders }
 -- handler :: Input -> Output -- handler = unsafePerformEffect <<< run