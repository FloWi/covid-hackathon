module Main where

import Prelude
import ChatHistory.Repository (EsEndpointUrl(..), mkChatHistoryRepoInElasticsearch)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Maybe (fromMaybe')
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (log, logShow)
import Foreign (F)
import MessageHandler as MessageHandler
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Node.Process (lookupEnv)
import Partial.Unsafe (unsafeCrashWith)
import ResponseChannel (mkResponseChannel)
import TelegramBot (Bot, Message, Token, connect, onMessage)
import VoucherLocation.Repository (VoucherRepoEndpointUrl, mkVoucherLocationRepo)

getToken :: Effect Token
getToken = lookupEnv "TELEGRAM_BOT_TOKEN" <#> fromMaybe' (\_ -> unsafeCrashWith "Can't get token")

-- "https://8x8chv60ad.execute-api.eu-west-1.amazonaws.com/prod/sms"
getVoucherRepoEndpoint :: Effect VoucherRepoEndpointUrl
getVoucherRepoEndpoint = lookupEnv "VOUCHER_LOCATION_REPO_ENDPOINT_URL" <#> fromMaybe' (\_ -> unsafeCrashWith "Can't get voucher repo endpoint 'VOUCHER_LOCATION_REPO_ENDPOINT_URL'")

getChatbotHistoryEndpoint :: Effect EsEndpointUrl
getChatbotHistoryEndpoint = map EsEndpointUrl (lookupEnv "CHATBOT_HISTORY_ELASTICSEARCH_ENDPOINT_URL" <#> fromMaybe' (\_ -> unsafeCrashWith "Can't get chatbot history endpoint 'CHATBOT_HISTORY_ELASTICSEARCH_ENDPOINT_URL'"))

main :: Effect Unit
main = do
  token <- getToken
  voucherRepoEndpointUrl <- getVoucherRepoEndpoint
  chatbotHistoryEndpoint <- getChatbotHistoryEndpoint
  bot <- connect token
  ctx <- mkContext bot voucherRepoEndpointUrl chatbotHistoryEndpoint
  onMessage bot (handle ctx)

type Ctx
  = Record (MessageHandler.Ctx ())

mkContext :: Bot -> VoucherRepoEndpointUrl -> EsEndpointUrl -> Effect Ctx
mkContext bot voucherRepoEndpointUrl chatbotHistoryEndpointUrl = do
  historyRepo <- mkChatHistoryRepoInElasticsearch chatbotHistoryEndpointUrl
  let
    responseChannel = mkResponseChannel bot
  let
    voucherLocationRepo = mkVoucherLocationRepo voucherRepoEndpointUrl (M.fetch nodeFetch)
  pure
    { responseChannel
    , historyRepo
    , voucherLocationRepo
    }

handle :: Ctx -> F Message -> Effect Unit
handle ctx messageOrError =
  launchAff_ do
    case runExcept messageOrError of
      Right m -> MessageHandler.handle ctx m
      Left e1 -> do
        log "failed decoding:"
        logShow e1
