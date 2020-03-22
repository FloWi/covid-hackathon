module Main where

import Prelude

import ChatHistory.Repository (mkChatHistoryRepoInMemory)
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
import VoucherLocation.Repository (mkVoucherLocationRepo)

getToken :: Effect Token
getToken = lookupEnv "TELEGRAM_BOT_TOKEN" <#> fromMaybe' (\_ -> unsafeCrashWith "Can't get token")

main :: Effect Unit
main = do
  token <- getToken
  bot <- connect token
  ctx <- mkContext bot
  onMessage bot (handle ctx)

type Ctx = Record (MessageHandler.Ctx ())

mkContext :: Bot -> Effect Ctx
mkContext bot = do
  historyRepo <- mkChatHistoryRepoInMemory
  let responseChannel = mkResponseChannel bot
  let voucherLocationRepo = mkVoucherLocationRepo (M.fetch nodeFetch)
  pure
      { responseChannel
      , historyRepo
      , voucherLocationRepo
      }

handle :: Ctx -> F Message -> Effect Unit
handle ctx messageOrError = launchAff_ do
  case runExcept messageOrError of
    Right m -> MessageHandler.handle ctx m
    Left e1 -> do
      log "failed decoding:"
      logShow e1