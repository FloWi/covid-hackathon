module ResponseChannel where

import Prelude

import Data.Foldable (foldMap, intercalate)
import Data.Maybe (Maybe)
import MessageHandler.Types (BotResponse(..), CallToAction(..))
import ResponseChannel.Types (ResponseChannel)
import TelegramBot (Bot, Location, sendMessage)
import Types (ChatId(..))

mkResponseChannel ∷ Bot -> ResponseChannel
mkResponseChannel bot = { respond }
  where
  send = sendMessage bot
  respond (ChatId chatId) botResponse = send chatId (translateResponse de botResponse)

translateCta ∷ CallToAction -> (Translations -> String)
translateCta = case _ of
  PleaseSendInfo -> _.pleaseSendInfo
  PleaseSendLocation -> _.pleaseSendLocation
  PleaseSendConfirmation name loc -> \x -> x.pleaseSendConfirmation name loc
  PleaseAnswerYesOrNo -> _.pleaseAnswerYesOrNo

de ∷ Translations
de =
  { welcome: \user -> "Willkommen beim Gutschein-Bot"<> (foldMap (\u -> ", " <> u) user) <>". Beantworte einfach meine Fragen und biete so im Handumdrehen deine Gutscheine an."
  , pleaseSendInfo: "Bitte schick' mir den Namen deines Geschäfts!"
  , pleaseSendLocation: "Bitte teile deinen deinen Standort mit mir. Das geht über das Büroklammer-Symbol am unteren Bildschirmrand."
  , pleaseSendConfirmation: \name loc -> "Der Name deines Geschäfts ist: '" <> name <> "'. Sind diese Informationen korrekt?"
  , pleaseAnswerYesOrNo: "Bitte antworte mit ja oder nein."
  , receivedInfo: \shopName -> "Ein schöner Name: " <> shopName <> "."
  , receivedLocation: "Danke für deinen Ort."
  , startOver: "Gar kein Problem, wir fangen einfach noch mal von vorne an."
  , locationMustNotBeString: "Orte, die du mir mit Wörtern beschreibst, verstehe ich nicht. Ich komme nur mit Orten klar, die du über die 'Standort teilen'-Funktionalität von Telegram sendest."
  , confused: "Wie bitte?"
  , thankYou: "Vielen Dank. Nun können Menschen in deiner Nachbarschaft deine Gutscheine online finden!"
  }

translate ∷ Translations -> Array (Translations -> String) -> String
translate translations fns =
  intercalate " " do
    fns <#> \f -> f translations

type Translations
  = { pleaseSendConfirmation ∷ String -> Location -> String
    , pleaseSendInfo ∷ String
    , pleaseSendLocation ∷ String
    , welcome ∷ Maybe String -> String
    , receivedInfo ∷ String -> String
    , receivedLocation ∷ String
    , pleaseAnswerYesOrNo :: String
    , startOver ∷ String
    , locationMustNotBeString ∷ String
    , confused ∷ String
    , thankYou ∷ String
    }

translateResponse ∷ Translations -> BotResponse -> String
translateResponse translations response = case response of
  Welcome u cta -> translate translations [ \ts -> ts.welcome u, translateCta (cta) ]
  ReceivedInfo name cta -> translate translations [ \n -> n.receivedInfo name, translateCta (cta) ]
  ReceivedLocation _ cta -> translate translations [ _.receivedLocation, translateCta (cta) ]
  StartOver cta -> translate translations [ _.startOver, translateCta (cta) ]
  LocationIsAString cta -> translate translations [ _.locationMustNotBeString, translateCta (cta) ]
  Confused cta -> translate translations [ _.confused, translateCta (cta) ]
  ThankYou -> translate translations [ _.thankYou ]
