module Utils exposing (..)

import Html exposing (..)
import Html.Events exposing (onWithOptions, Options, defaultOptions)
import Json.Decode as Json
import Http exposing (..)
import Json.Decode as Decode

-- TODO Move somewhere else?


onNoBubbleClick : msg -> Attribute msg
onNoBubbleClick msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Json.succeed msg)

authedGet : String -> String -> Decode.Decoder a -> Request a
authedGet url token decoder =
  request
    { method = "GET"
    , headers = [Http.header "Authorization" ("Token " ++ token)]
    , url = url
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }

authedPost : String -> String -> Body -> Decode.Decoder a -> Request a
authedPost url token body decoder =
  request
    { method = "POST"
    , headers = [Http.header "Authorization" token]
    , url = url
    , body = body
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }