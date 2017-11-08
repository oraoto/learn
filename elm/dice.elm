module Main exposing (..)

import Html exposing (Html, button, div, h1)
import Html.Events exposing (onClick)
import Process
import Random
import Svg exposing (svg, text, text_)
import Svg.Attributes
import Task exposing (andThen, perform, succeed)


main : Program Never Model Msg
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model =
    { dieFace : Int
    , rolling : Int
    }


type Msg
    = Roll
    | RollingFace Int
    | NewFace Int
    | SleepFinish


view : Model -> Html Msg
view model =
    div []
        [ svg [ Svg.Attributes.width "50", Svg.Attributes.height "50"]
            [ text_
                [ Svg.Attributes.x "25"
                , Svg.Attributes.y "25"
                , Svg.Attributes.fontSize "30"
                ]
                [ text (toString model.dieFace) ]
            ]
        , button [ onClick Roll ] [ Html.text "Roll" ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        sleep =
            perform (\() -> SleepFinish) (Process.sleep 16)

        rolling =
            Random.generate RollingFace (Random.int 1 6)
    in
    case msg of
        Roll ->
            ( { model | rolling = 15 }, rolling )

        NewFace newFace ->
            ( { model | dieFace = newFace }, Cmd.none )

        RollingFace s ->
            if model.rolling == 0 then
                ( model, Random.generate NewFace (Random.int 1 6) )
            else
                ( { model | rolling = model.rolling - 1, dieFace = s }, sleep )

        SleepFinish ->
            ( model, rolling )


init : ( Model, Cmd Msg )
init =
    ( Model 1 0, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
