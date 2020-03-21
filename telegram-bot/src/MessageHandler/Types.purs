module MessageHandler.Types where

import Prelude

import Data.Maybe (Maybe)
import TelegramBot (Message, Location)

data Msg
  = FirstMsg Message
  | InfoMsg String Message
  | LocationMsg Location Message
  | LocationStringMsg Message
  | ConfirmationMsg Message
  | InvalidationMsg Message
  | NeitherConfirmationNorInvalidation Message
  | UselessMsg Message

data CallToAction
  = PleaseSendInfo
  | PleaseSendLocation
  | PleaseSendConfirmation String Location
  | PleaseAnswerYesOrNo

derive instance eqCallToAction :: Eq CallToAction

data BotResponse
  = Welcome (Maybe String) CallToAction
  | ReceivedInfo String CallToAction
  | ReceivedLocation Location CallToAction
  | StartOver CallToAction
  | LocationIsAString CallToAction
  | Confused CallToAction
  | ThankYou