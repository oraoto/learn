module Main exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Time


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )



-- UPDATE


type Msg
    = Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            let
                _ =
                    Debug.log "NewTime" newTime

                _ =
                    Debug.log "Hours" (Time.inHours newTime)
            in
            ( newTime, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        cts = model

        angleHour =
            turns (Time.inHours cts) / 12

        handHourX =
            toString (50 + 20 * cos angleHour)

        handHourY =
            toString (50 + 20 * sin angleHour)

        angleMinute =
            turns (Time.inMinutes cts) / 60

        handMinuteX =
            toString (50 + 30 * cos angleMinute)

        handMinuteY =
            toString (50 + 30 * sin angleMinute)

        angleSecond =
            turns (Time.inSeconds cts) / 60

        handSecondX =
            toString (50 + 40 * cos angleSecond)

        handSecondY =
            toString (50 + 40 * sin angleSecond)
    in
    svg [ viewBox "0 0 100 100", width "300px" ]
        [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
        -- , line [ x1 "50", y1 "50", x2 handMinuteX, y2 handMinuteY, stroke "#023963" ] []
        -- , line [ x1 "50", y1 "50", x2 handSecondX, y2 handSecondY, stroke "#17c295" ] []
        , line [ x1 "50", y1 "50", x2 handHourX, y2 handHourY, stroke "#f2725e" ] []
        ]
