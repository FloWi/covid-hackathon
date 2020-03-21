module ChatHistory where

import Prelude

import ChatHistory.Types (ChatHistory(..))
import Data.Array as A
import Data.Maybe (Maybe(..))
import Data.Newtype (over)
import MessageHandler.Types (Msg(..))
import TelegramBot (Location)

findLatestMessage ∷ ChatHistory -> Maybe Msg
findLatestMessage (ChatHistory ch) = A.head ch

onlyUnderstandable ∷ ChatHistory -> ChatHistory
onlyUnderstandable = over ChatHistory removeUseless
  where
  removeUseless = A.filter case _ of
    UselessMsg _ -> false
    other -> true

findLatestUnderstandableMessage ∷ ChatHistory -> Maybe Msg
findLatestUnderstandableMessage = onlyUnderstandable >>> findLatestMessage

findLatestLocation ∷ ChatHistory -> Maybe Location
findLatestLocation (ChatHistory ch) = findLoc ch
  where
  findLoc = A.findMap case _ of
    LocationMsg loc _ -> Just loc
    other -> Nothing

findLatestInfo ∷ ChatHistory -> Maybe String
findLatestInfo (ChatHistory ch) = findInfo ch
  where
  findInfo = A.findMap case _ of
    InfoMsg info _ -> Just info
    other -> Nothing