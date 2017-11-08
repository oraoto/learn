module Main exposing (..)

import Char exposing (isDigit, isLower, isUpper)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List
import String exposing (..)
import Tuple


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    , age : String
    , submit : Bool
    , passwordAgainEntered : Bool
    }


model : Model
model =
    Model "" "" "" "" False False


type Msg
    = Name String
    | Password String
    | PasswordAgain String
    | Age String
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        PasswordAgain password ->
            { model | passwordAgain = password, passwordAgainEntered = True }

        Age age ->
            { model | age = age }

        Submit ->
            { model | submit = True }


view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Name" Name
        , viewInput "text" "Age" Age
        , viewInput "password" "Password" Password
        , viewInput "password" "Re-enter Password" PasswordAgain
        , viewValidation model
        , button [ onClick Submit ] [ text "Submit" ]
        ]


viewInput : String -> String -> (String -> Msg) -> Html Msg
viewInput inputType inputPlaceholder inputOnInput =
    input [ type_ inputType, placeholder inputPlaceholder, onInput inputOnInput ] []


viewValidation : Model -> Html msg
viewValidation model =
    let
        rules =
            [ ( length model.password > 8, "Password must longer than 8 characters" )
            , ( any isUpper model.password, "Password must contains upper case" )
            , ( any isLower model.password, "Password must contains lower case" )
            , ( any isDigit model.password, "Password must contains numeric characters" )
            , ( all isDigit model.age, "Age must be number" )
            , ( model.password == model.passwordAgain, "Passwords do not match" )
            ]

        valid =
            List.all Tuple.first rules

        messages =
            List.map Tuple.second (List.filter (not << Tuple.first) rules)

        entered =
            model.passwordAgainEntered

        color =
            if valid then
                "green"
            else
                "red"

        messageView message =
            li [] [ text message ]
    in
    if not model.submit then
        div [] []
    else if valid then
        div [ style [ ( "color", color ) ] ] [ text "OK" ]
    else
        div [ style [ ( "color", color ) ] ] (List.map messageView messages)
