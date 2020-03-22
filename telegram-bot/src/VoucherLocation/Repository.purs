module VoucherLocation.Repository where

import Prelude
import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.JSDate as JSDate
import Data.JSDate as JSDate
import Debug.Trace (spy)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Milkis as M
import Simple.JSON (writeJSON)
import VoucherLocation.Types (VoucherLocationRepository)

type VoucherRepoEndpointUrl
  = String

voucherLocationRepoDummy ∷ VoucherLocationRepository
voucherLocationRepoDummy = { create }
  where
  create loc name = do
    log $ "I should persist a shop called " <> name <> " at "
      <> show loc
      <> " but I'm not."
    pure true

mkVoucherLocationRepo :: VoucherRepoEndpointUrl -> M.Fetch -> VoucherLocationRepository
mkVoucherLocationRepo endpointUrl fetch = { create }
  where
  url = M.URL endpointUrl

  fetchOptions body = { body: writeJSON body, method: M.postMethod }

  create location@{ longitude, latitude } name = do
    createdAt <- JSDate.now >>= JSDate.toISOString # liftEffect
    let
      body = { createdAt, store: { name, location: { lon: longitude, lat: latitude } } }
    response <- fetch url (fetchOptions body)
    pure (M.statusCode response # between 200 299)
