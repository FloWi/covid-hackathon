module Reducer where

import Prelude
import Affjax as AX
import Affjax as Ax
import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat as ResponseFormat
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Now as Now
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, stopPropagation, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, element, memo, useReducer, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Simple.JSON as JSON

data Action
  = SendLocation Number Number

type Location
  = { lat :: Number
    , lon :: Number
    }

type State
  = { location :: Maybe Location
    }

reducer :: State -> Action -> State
reducer state (SendLocation lat lon) = state { location = Just { lat, lon } }

mkReducer :: String -> Effect (ReactComponent {})
mkReducer url = do
  let
    initialState = { location: Nothing }
  tweetInput <- memo mkTweetInput
  component "Tweets" \props -> React.do
    state /\ dispatch <- useReducer initialState reducer
    -- There is probably a way to use just one hook for posting & updating state, haven't figured out though
    useAff state do
      liftEffect $ log $ "State: " <> (show state)
      case state.location of
        Just location -> do
          maybeResponse <- AX.post ResponseFormat.string (url <> "/api/tweet") (Just (RequestBody.string (JSON.writeJSON { lat: location.lat, lon: location.lon }))) <#> lmap (Ax.printError)
          case maybeResponse of
            Left err -> liftEffect $ log $ "Failed to post tweet" <> err
            Right response -> liftEffect $ log $ show response.body
        Nothing -> pure unit
    pure
      $ R.div
          { children:
            [ element tweetInput { dispatch }
            ]
          , className: "container"
          }

mkTweetInput :: Effect (ReactComponent { dispatch :: Action -> Effect Unit })
mkTweetInput = do
  component "LocationInput" \props -> React.do
    value /\ setValue <- useState ""
    pure
      $ R.form
          { onSubmit:
            handler (preventDefault >>> stopPropagation) \_ -> do
              props.dispatch $ SendLocation 50.912915 6.961424
              setValue $ const ""
          , children:
            [ R.input
                { value
                , onChange:
                  handler (preventDefault >>> stopPropagation >>> targetValue)
                    $ traverse_ (setValue <<< const)
                , className: "tweet"
                , placeholder: "Enter an kaese"
                }
            ]
          , className: "tweet"
          }
