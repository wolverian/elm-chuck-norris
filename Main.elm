import StartApp

import Html exposing (..)
import QuotesList
import Task exposing (Task)
import Effects exposing (Never)        
        
view address model =
    div []
        [ h1 [] [ text "Chuck Norris Quotes" ]
        , QuotesList.view address model ]        
        
app = StartApp.start
  { init = QuotesList.init
  , update = QuotesList.update
  , view = view
  , inputs = []
  }

main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks