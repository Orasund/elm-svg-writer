module Main exposing (..)


type alias Model =
    {}


type Msg
    = NoOp


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
