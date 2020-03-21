module Types where

import Prelude

import Data.Newtype (class Newtype)

newtype ChatId
  = ChatId Int

derive instance ntChatId :: Newtype ChatId _
derive newtype instance eqChatId :: Eq ChatId
derive newtype instance ordChatId :: Ord ChatId
