module Reducer where

import Prelude

import Affjax as Ax
import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat as ResponseFormat
import Data.Array (fold, take)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Foldable (traverse_,for_)
import Data.List.Types (NonEmptyList)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign (ForeignError, renderForeignError)
import Global.Unsafe (unsafeEncodeURIComponent)
import Mapbox (addMarker, makeMap, setCenter, setZoom)
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, stopPropagation, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (JSX, ReactComponent,Hook, UseState, coerceHook, component, element, memo, useEffect, useReducer, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (UseAff, useAff)
import Simple.JSON as JSON
import Simple.JSON as Json

import Data.Newtype (class Newtype)
import Data.Tuple (Tuple)

newtype UseAffReducer state action hooks
  = UseAffReducer
  ( UseAff (Maybe action) Unit
      ( UseState (Maybe action)
          (UseState state hooks)
      )
  )

derive instance ntUseAffReducer ∷ Newtype (UseAffReducer state action hooks) _
useAffReducer ∷ ∀ state action. Eq action => state -> (state -> action -> Aff state) -> Hook (UseAffReducer state action) (Tuple state (action -> Effect Unit))
useAffReducer initialState reducer =
  coerceHook React.do
    state /\ modifyState <- useState initialState
    maybeAction /\ modifyAction <- useState Nothing
    let
      dispatch = modifyAction <<< const <<< Just
    useAff maybeAction
      $ for_ maybeAction \action -> do
          newState <- reducer state action
          liftEffect do
            modifyState (const newState)
            modifyAction (const Nothing)
    pure (state /\ dispatch)

type Location
  = { lat :: Number
    , lon :: Number
    }

type UserAddress
  = { name :: String
    , location :: Location
    }

type VoucherApiRequest
  = { location :: Location
    }

type Store
  = { name :: String
    , location :: Location
    }

type VoucherApiResponse
  = { voucherOffers :: Array Store
    }

type AppState
  = { query :: Maybe String
    , address :: Maybe UserAddress
    , stores :: Array Store
    }

type MapboxFeature
  = { place_name :: String
    , center :: Array Number
    }

type MapboxResponse
  = { features :: Array MapboxFeature
    }

data Action
  = SendQuery String
  | SendUserAddress UserAddress
  | SendStores (Array Store)

reducer :: AppState -> Action -> AppState
reducer state (SendQuery query) = state { query = Just query }

reducer state (SendUserAddress address) = state { address = Just address }

reducer state (SendStores stores) = state { stores = stores }

convert :: MapboxResponse -> Either String UserAddress
convert { features } = case take 1 features of
  [ feature ] -> case feature.center of
    [ lon, lat ] -> Right { name: feature.place_name, location: { lat: lat, lon: lon } }
    other -> Left "No coordinates found"
  other -> Left ("Address not found: " <> show other)

renderErrors :: NonEmptyList ForeignError -> String
renderErrors err = fold x
  where
  x = map renderForeignError err

constractRequestUri :: String -> String
constractRequestUri query = mapboxUri <> encodedQuery <> params
  where
  mapboxUri = "https://api.mapbox.com/geocoding/v5/mapbox.places/"

  encodedQuery = unsafeEncodeURIComponent query

  params = ".json?countries=de&limit=1&access_token=pk.eyJ1IjoiamFudHh1IiwiYSI6ImNrODF0NjMzZDBiOTMzaG93YWc2YXV2NnUifQ.WMxyoiOInTp6UNS2zJyKrg"

retrieveLocation :: String -> Aff (Either String UserAddress)
retrieveLocation query = do
  maybeResp <- Ax.get ResponseFormat.string (constractRequestUri query) <#> lmap (Ax.printError)
  pure
    $ do
        resp <- maybeResp
        let
          maybeMapboxResponse :: Either (NonEmptyList ForeignError) MapboxResponse
          maybeMapboxResponse = JSON.readJSON resp.body
        mapboxResponse <- lmap renderErrors maybeMapboxResponse
        userAddress <- convert mapboxResponse
        pure userAddress

retrieveStores :: Location -> Aff (Either String (Array Store))
retrieveStores location = do
  maybeResp <- Ax.post ResponseFormat.string voucherApiUri request <#> lmap (Ax.printError)
  pure
    $ do
        resp <- maybeResp
        let
          maybeVoucherApiResponse :: Either (NonEmptyList ForeignError) VoucherApiResponse
          maybeVoucherApiResponse = JSON.readJSON resp.body
        voucherResponse <- lmap renderErrors maybeVoucherApiResponse
        pure voucherResponse.voucherOffers
  where
  request = Just $ RequestBody.string $ Json.writeJSON location

  voucherApiUri = "https://kqz6zq6i08.execute-api.eu-west-1.amazonaws.com/prod/api"


mkReducer :: String -> Effect (ReactComponent {})
mkReducer url = do
  let
    initialState = { query: Nothing, address: Nothing, stores: [] }
  tweetInput <- memo mkTweetInput
  mapContainer <- mkMap
  stores <- mkStores
  component "VoucherUI" \props -> React.do
    state /\ dispatch <- useReducer initialState reducer
    -- There is probably a way to use just one hook for posting & updating state, haven't figured out though
    useAff state do
      liftEffect $ log $ "State: " <> (show state)
      case state.query of
        Just query -> do
          maybeResponse <- retrieveLocation query
          --maybeResponse <- AX.post ResponseFormat.string (url <> "/api/tweet") (Just (RequestBody.string (JSON.writeJSON { lat: location.lat, lon: location.lon }))) <#> lmap (Ax.printError)
          case maybeResponse of
            Left err -> liftEffect $ log $ "Failed to post tweet" <> err
            Right resp -> do
              _ <- liftEffect $ log $ show resp
              liftEffect $ dispatch (SendUserAddress resp)
        Nothing -> pure unit
    useAff state do
      liftEffect $ log $ "State: " <> (show state)
      case state.address of
        Just { location, name } -> do
          maybeResponse <- retrieveStores location
          --maybeResponse <- AX.post ResponseFormat.string (url <> "/api/tweet") (Just (RequestBody.string (JSON.writeJSON { lat: location.lat, lon: location.lon }))) <#> lmap (Ax.printError)
          case maybeResponse of
            Left err -> liftEffect $ log $ "Failed to get vouchers" <> err
            Right resp -> do
              _ <- liftEffect $ log $ show resp
              liftEffect $ dispatch (SendStores resp)
        Nothing -> pure unit
    pure
      $ R.div
          { className: "container"
          , children:
            [ R.div
                { className: "row"
                , children:
                  [ R.div
                      { className: "col s3"
                      , children:
                        [ R.img
                            { src: "/assets/header-logo.svg"
                            }
                        ]
                      }
                  , R.div
                      { className: "col s9"
                      , children:
                        [ R.div
                            { className: "row"
                            , children: [ R.h3 { children: [ R.text "Finden und unterstützen Sie Geschäfte aus Ihrer Gegend." ] } ]
                            }
                        , R.div
                            { className: "row"
                            , children:
                              [ R.text "Auf cheeraty können Sie Gutscheine für lokale Geschäfte erwerben, um diesen über die Zeit der Schließung zu helfen.\nSo haben Ihre Lieblingsgeschäfte weiterhin genug Umsatz um zu überleben und können Ihnen in einigen Worten wie gewohnt die Türen öffnen.\n#stayathome #flattenthecurve #supportyourlocalstores"
                              ]
                            }
                        ]
                      }
                  ]
                }
            , R.div
                { className: "row"
                , children:
                  [ R.div
                      { className: "col s12"
                      , children: [ element tweetInput { query: state.query, dispatch } ]
                      }
                  ]
                }
            , R.div
                { className: "row"
                , children:
                  [ R.div
                      { className: "col s3"
                      , children: [ element stores { stores: state.stores } ]
                      }
                  , R.div
                      { className: "col s9"
                      , children: [ element mapContainer { address: state.address , stores : state.stores} ]
                      }
                  ]
                }
            ]
          }

storeHtml :: Store -> JSX
storeHtml { name, location } =
  R.div
    { className: "row"
    , children:
      [ R.h6 { children: [ R.text name ] }
      --, R.text description
      ]
    }

mkStores :: Effect (ReactComponent { stores :: Array Store })
mkStores = do
  component "Stores" \props -> React.do
    pure
      $ R.div
          { children: map storeHtml props.stores
          , className: "container"
          }

mkMap :: Effect (ReactComponent { address :: Maybe UserAddress, stores :: Array Store })
mkMap = do
  component "Map" \props -> React.do
    let
      location = fromMaybe { lon: 6.961424, lat: 50.912915 } $ map (\a -> a.location) props.address
    useEffect location do
      log "Loading map"
      m <- makeMap "map"
      setCenter m location.lat location.lon
      setZoom m 15
      log $ "Adding markers" <> (show props.stores)
      addMarker m 50.912915 6.961424 "Hello" "World"
      stores <- traverse (\s -> log "Adding marker" *> addMarker m s.location.lat s.location.lat s.name "" ) props.stores
      log $ "Added stores" <> show stores
      log "Map loaded!"
      pure (pure unit)
    pure
      $ R.div
          { children: []
          , className: "map"
          , id: "map"
          }

mkTweetInput :: Effect (ReactComponent { query :: Maybe String, dispatch :: Action -> Effect Unit })
mkTweetInput = do
  component "LocationInput" \props -> React.do
    value /\ setValue <- useState $ fromMaybe "" $ props.query
    pure
      $ R.form
          { onSubmit:
            handler (preventDefault >>> stopPropagation) \_ -> do
              props.dispatch $ SendQuery value
          --setValue $ const ""
          , children:
            [ R.input
                { value
                , id: "address-search"
                , onChange:
                  handler (preventDefault >>> stopPropagation >>> targetValue)
                    $ traverse_ (setValue <<< const)
                , className: "tweet"
                , placeholder: "PLZ oder Stadt/Ort eingeben"
                }
            , R.label
                { htmlFor: "address-search"
                , children: [ R.text "In welcher Stadt wohnen Sie?" ]
                }
            ]
          , className: "tweet"
          }
