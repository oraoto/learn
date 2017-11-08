module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }


type Msg
    = Increment
    | Decrement
    | Reset


type alias Model =
    Int


model : Model
model =
    0


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1

        Reset ->
            0


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        , button [ onClick Reset ] [ text "Reset" ]
        ]
