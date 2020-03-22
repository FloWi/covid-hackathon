module MessageHandler where

import Prelude

import ChatHistory (findLatestMessage)
import ChatHistory as History
import ChatHistory.Types (ChatHistory, ChatHistoryRepository)
import Data.Maybe (Maybe(..))
import Data.String as String
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import MessageHandler.Types (BotResponse(..), CallToAction(..), Msg(..))
import ResponseChannel.Types (ResponseChannel)
import TelegramBot (Message)
import Types (ChatId(..))
import VoucherLocation.Types (VoucherLocationRepository)

-- | The context that the `handle` function needs to operate
type Ctx r
  = ( historyRepo ∷ ChatHistoryRepository
    , responseChannel ∷ ResponseChannel
    , voucherLocationRepo ∷ VoucherLocationRepository
    | r
    )

-- | Parses incoming messages and replies through a supplied
-- | responseChannel. Previous messages are being kept track of
-- | by the historyRepo.
handle ∷ ∀ r. { | Ctx r } -> Message -> Aff Unit
handle { historyRepo, responseChannel, voucherLocationRepo } rawMessage = do
  let chatId = ChatId rawMessage.chat.id
  oldChatHistory <- historyRepo.getChatHistory chatId
  let msg = parseMessageWithHistory oldChatHistory rawMessage
  case msg of
    ConfirmationMsg _ -> handleConfirmation voucherLocationRepo oldChatHistory
    InvalidationMsg _ -> historyRepo.deleteChatHistory chatId
    _ -> pure unit 
  historyRepo.addToHistory chatId msg
  newChatHistory <- historyRepo.getChatHistory chatId
  let response = craftResponseFromHistory newChatHistory msg
  case response of
    ThankYou -> historyRepo.deleteChatHistory chatId
    _ -> pure unit
  responseChannel.respond chatId response # liftEffect

-- | This doesn't do much yet, but it should eventually save the data in the
-- | Database. In order for that to happen, provide a real implementation of
-- | the voucheLocationRepo to the `handle` function
handleConfirmation :: VoucherLocationRepository -> ChatHistory -> Aff Unit
handleConfirmation vouchers history = do
      let 
        maybeLocationAndName = do 
          loc <- History.findLatestLocation history
          name <- History.findLatestInfo history
          pure { loc, name }
      case maybeLocationAndName of
        Just { loc, name } -> vouchers.create loc name >>= (\x -> unless x $ log "oh shit!")
        Nothing -> 
          log "Got confirmation, but can't find location and name"

-- | Parses incoming messages based on the previous call to action
parseMessageWithHistory ∷ ChatHistory -> Message -> Msg
parseMessageWithHistory chatHistory msg = do
  let
    previous = findLatestMessage chatHistory
    response = craftResponseFromHistory chatHistory <$> previous
    previousCta = response >>= ctaFromResponse

  case msg, previousCta of

    start, _ | start.text == Just "/start" -> 
      FirstMsg start

    { text: Just txt }, Just PleaseSendInfo -> 
      InfoMsg txt msg

    { location: Nothing }, Just PleaseSendLocation -> 
      LocationStringMsg msg

    { location: Just loc }, Just PleaseSendLocation -> 
      LocationMsg loc msg

    { text: Just txt }, Just PleaseAnswerYesOrNo ->
      if isInvalidation txt then
        InvalidationMsg msg
      else if 
        isConfirmation txt then
          ConfirmationMsg msg
      else
          NeitherConfirmationNorInvalidation msg

    { text: Just txt }, Just (PleaseSendConfirmation _ _)->
      if isConfirmation txt then
        ConfirmationMsg msg
      else
        if isInvalidation txt then
          InvalidationMsg msg
        else
          NeitherConfirmationNorInvalidation msg

    other, _ -> UselessMsg other

isConfirmation :: String -> Boolean
isConfirmation s = String.contains (String.Pattern "ja") (String.toLower s)

isInvalidation :: String -> Boolean
isInvalidation s = String.contains (String.Pattern "nein") (String.toLower s)

craftResponseFromHistory ∷ ChatHistory -> Msg -> BotResponse
craftResponseFromHistory ch = 
  case _ of
    FirstMsg m -> Welcome (m.from >>= _.first_name) cta
    InfoMsg i _ -> ReceivedInfo i cta
    LocationStringMsg m -> LocationIsAString cta
    LocationMsg l m -> ReceivedLocation l cta
    InvalidationMsg _ -> StartOver cta
    ConfirmationMsg _ -> ThankYou
    NeitherConfirmationNorInvalidation _ -> Confused PleaseAnswerYesOrNo
    UselessMsg _ -> Confused cta
  where
    latestInfo = History.findLatestInfo ch
    latestLocation = History.findLatestLocation ch
    cta = case latestInfo, latestLocation of
      Nothing, Nothing -> PleaseSendInfo
      Just info, Nothing -> PleaseSendLocation
      Nothing, Just loc -> PleaseSendInfo
      Just info, Just loc -> PleaseSendConfirmation info loc

ctaFromResponse :: BotResponse -> Maybe CallToAction
ctaFromResponse = case _ of
    Welcome _ cta -> Just cta
    ReceivedInfo _ cta -> Just cta
    ReceivedLocation _ cta -> Just cta
    StartOver cta -> Just cta
    LocationIsAString cta -> Just cta
    Confused cta -> Just cta
    ThankYou -> Nothing
