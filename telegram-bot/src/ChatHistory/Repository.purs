module ChatHistory.Repository where

import Prelude
import ChatHistory.Types (ChatHistory(..), ChatHistoryRepository)
import Data.Array (fold, (:))
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (modify_, new, read)

-- | Constructs a repository that is simply a Mutable Map
-- | Eventually this will lead us to go out of memory!
mkChatHistoryRepoInMemory :: Effect ChatHistoryRepository
mkChatHistoryRepoInMemory = do
  ref <- new mempty
  let
    getChatHistory chatId =
      liftEffect do
        fold <<< Map.lookup chatId <$> read ref

    addToHistory chatId msg =
      liftEffect do
        ref # modify_ (Map.alter upsert chatId)
      where
      upsert = case _ of
        Nothing -> Just (ChatHistory [ msg ])
        Just (ChatHistory ch) -> Just (ChatHistory (msg : ch))

    deleteChatHistory chatId =
      liftEffect do
        ref # modify_ (Map.delete chatId)
  pure
    { getChatHistory
    , addToHistory
    , deleteChatHistory
    }

type ChatbotHistoryElasticsearchEndpointUrl
  = String

mkChatHistoryRepoInElasticsearch :: ChatbotHistoryElasticsearchEndpointUrl -> Effect ChatHistoryRepository
mkChatHistoryRepoInElasticsearch esEndpoint = do
  ref <- new mempty
  let
    getChatHistory chatId =
      liftEffect do
        fold <<< Map.lookup chatId <$> read ref

    addToHistory chatId msg =
      liftEffect do
        ref # modify_ (Map.alter upsert chatId)
      where
      upsert = case _ of
        Nothing -> Just (ChatHistory [ msg ])
        Just (ChatHistory ch) -> Just (ChatHistory (msg : ch))

    deleteChatHistory chatId =
      liftEffect do
        ref # modify_ (Map.delete chatId)
  pure
    { getChatHistory
    , addToHistory
    , deleteChatHistory
    }
