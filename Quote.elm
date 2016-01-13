module Quote where

import String
import Html exposing (..)
import Html.Events exposing (onClick)

type alias Model = String

type Action
    = Upper
    
type alias Context =
    { remove : Signal.Address ()
    , modify : Signal.Address Action
    }

update : Action -> Model -> Model
update action model =
    case action of
        Upper -> String.toUpper model

view : Context -> String -> Html
view context quote =
    li []
        [ text quote
        , button [ onClick context.remove () ] [ text "X" ]
        , button [ onClick context.modify Upper ] [ text "POW" ] 
        ]
