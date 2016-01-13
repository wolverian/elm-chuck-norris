module QuotesList where

import Quote
import Array exposing (Array)
import Effects exposing (Effects)
import Http
import Task
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Json

type alias ID = Int
type alias Model =
    { quotes : Array (ID, String)
    , nextID : ID}

type Action
    = NewQuote (Maybe Quote.Model)
    | RemoveQuote ID
    | ModifyQuote ID Quote.Action
    | RequestMore

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NewQuote maybeQuote -> case maybeQuote of
        Nothing -> (model, Effects.none)
        Just quote -> (appendQuote quote model, Effects.none)
    ModifyQuote id quoteAction ->
        let updateQuote (quoteId, quoteModel) =
            if quoteId == id
                then (quoteId, Quote.update quoteAction quoteModel)
                else (quoteId, quoteModel)
        in
            ({ model | quotes = Array.map updateQuote model.quotes}, Effects.none)
    RemoveQuote id ->
        ({ model | quotes = Array.filter (\(quoteId, _) -> quoteId /= id) model.quotes }, Effects.none)
    RequestMore -> (model, getRandomQuote)

appendQuote quote model =
    { model |
        quotes = Array.push (model.nextID, quote) model.quotes,
        nextID = model.nextID + 1
    }

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ ul [] (renderQuotes address model.quotes)
    , button [ (onClick address RequestMore) ] [ text "Get New Quote" ]
    ]

renderQuotes address quotes =
    quotes
        |> Array.map (renderQuote address)
        |> Array.toList

renderQuote address (id, quote) =
    let context =
        { modify = Signal.forwardTo address (ModifyQuote id)
        , remove = Signal.forwardTo address (always (RemoveQuote id)) }
    in Quote.view context quote

getRandomQuote : Effects Action
getRandomQuote =
    Http.get parseQuote "http://api.icndb.com/jokes/random"
        |> Task.toMaybe
        |> Task.map NewQuote
        |> Effects.task

parseQuote : Json.Decoder String
parseQuote = Json.at ["value", "joke"] Json.string

init : (Model, Effects Action)
init = ({ quotes = Array.empty, nextID = 1 }, getRandomQuote)
