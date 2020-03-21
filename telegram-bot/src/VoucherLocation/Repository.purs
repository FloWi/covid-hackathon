module VoucherLocation.Repository where

import Prelude
import Effect.Class.Console (log)
import VoucherLocation.Types (VoucherLocationRepository)

voucherLocationRepoDummy ∷ VoucherLocationRepository
voucherLocationRepoDummy = { create }
  where
  create loc name =
    log $ "I should persist a shop called " <> name <> " at "
      <> show loc
      <> " but I'm not."
