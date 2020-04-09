module Examples.ManagedState exposing (..)


import Browser
import Element
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import MaterialUI.Internal.TextField.Model as TextField
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.TextFieldM as TextField
import MaterialUI.Theme as Theme
import MaterialUI.Themes.Dark as Dark


type alias Model =
    { mui : MaterialUI.Model () Msg
    , text1 : String
    , text2 : String
    }


type Msg
    = Text String
    | Mui MaterialUI.Msg


init : Model
init =
    { mui = MaterialUI.defaultModel Mui {-Theme.defaultTheme-} Dark.theme
    , text1 = ""
    , text2 = ""
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Text text ->
            { model | text1 = text }

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
            [ TextField.managed model.mui
                [ Element.width Element.fill
                ]
                { index = "tf1"
                , label = "TextField"
                , hideLabel = False
                , type_ = TextField.Outlined
                , color = Theme.Primary
                , text = model.text1
                , onChange = Text
                , errorText = Nothing
                , helperText = Nothing
                }
            , TextField.managed model.mui
                [ Element.width Element.fill
                ]
                { index = "tf2"
                , label = "TextField"
                , hideLabel = False
                , type_ = TextField.Filled
                , color = Theme.Primary
                , text = model.text2
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