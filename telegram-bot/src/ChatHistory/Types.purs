module ChatHistory.Types where

import Prelude

import Data.Newtype (class Newtype)
import Effect.Aff (Aff)
import MessageHandler.Types (Msg)
import Types (ChatId)

newtype ChatHistory
  = ChatHistory (Array Msg)

derive instance ntChatHistory :: Newtype ChatHistory _
derive newtype instance sgChatHistory :: Semigroup ChatHistory
derive newtype instance mdChatHistory :: Monoid ChatHistory

type ChatHistoryRepository
  = { getChatHistory ∷ ChatId -> Aff ChatHistory
    , addToHistory ∷ ChatId -> Msg -> Aff Unit
    , deleteChatHistory ∷ ChatId -> Aff Unit
    }
