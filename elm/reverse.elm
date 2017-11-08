module Main exposing (..)

import Html exposing (Html, div, input, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }


type alias Model =
    { content : String
    }


type Msg
    = Change String


model : Model
model =
    { content = "" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change newContent ->
            { model | content = newContent }


view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "Text to reverse", onInput Change ] []
        , div [] [ text (String.reverse model.content) ]
        ]
