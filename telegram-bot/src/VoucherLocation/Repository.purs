module VoucherLocation.Repository where

import Prelude

import Debug.Trace (spy)
import Effect.Class.Console (log)
import Milkis as M
import Simple.JSON (writeJSON)
import VoucherLocation.Types (VoucherLocationRepository)

voucherLocationRepoDummy ∷ VoucherLocationRepository
voucherLocationRepoDummy = { create }
  where
  create loc name = do
    log $ "I should persist a shop called " <> name <> " at "
      <> show loc
      <> " but I'm not."
    pure true

mkVoucherLocationRepo :: M.Fetch -> VoucherLocationRepository
mkVoucherLocationRepo fetch = { create }
  where
  url = M.URL "https://8x8chv60ad.execute-api.eu-west-1.amazonaws.com/prod/sms"
  fetchOptions body = { body: writeJSON body, method: M.postMethod }
  create location name = do
    let body = { name, location }
    response <- fetch url (fetchOptions body)
    let _ = spy "response" response
    pure (M.statusCode response # between 200 299)