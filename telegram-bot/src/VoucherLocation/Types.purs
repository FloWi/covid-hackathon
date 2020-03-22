module VoucherLocation.Types where

import Prelude

import Effect.Aff (Aff)
import TelegramBot (Location)

type VoucherLocationRepository = {
    create :: Location -> String -> Aff Boolean
}