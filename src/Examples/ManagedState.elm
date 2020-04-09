module Examples.ManagedState exposing (..)


import Browser
import Element
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import MaterialUI.Internal.TextField.Model as TextField
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.TextFieldM as TestField
import MaterialUI.Theme as Theme


type alias Model =
    { mui : MaterialUI.Model () Msg
    , text : String
    }


type Msg
    = Text String
    | Mui MaterialUI.Msg


init : Model
init =
    { mui = MaterialUI.defaultModel Mui Theme.defaultTheme
    , text = ""
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Text text ->
            { model | text = text }

        Mui mui ->
            { model | mui = MaterialUI.update mui model.mui }


view : Model -> Html Msg
view model =
    let
        theme = model.mui.theme
    in
    Element.layout
        [ Background.color <| theme.color.background
        , Font.color <| theme.color.onBackground
        ]
        <| Element.column
            [ Element.width <| Element.maximum 900 Element.fill
            , Element.spacing 8
            , Element.padding 10
            , Element.centerX
            ]
            [ TestField.managed model.mui
                [ Element.width Element.fill
                ]
                { index = "tf1"
                , label = "TextField"
                , hideLabel = False
                , type_ = TextField.Outlined
                , color = Theme.Primary
                , text = model.text
                , onChange = Text
                , errorText = Nothing
                , helperText = Nothing
                }
            ]


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }