module ResponseChannel.Types where

import Prelude

import Effect (Effect)
import MessageHandler.Types (BotResponse)
import Types (ChatId)

type ResponseChannel
  = { respond ∷ ChatId -> BotResponse -> Effect Unit
    }