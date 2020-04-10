module Examples.ManagedState exposing (..)


import Browser
import Element
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)
import MaterialUI.Icon as Icon
import MaterialUI.Icons.Content as Content
import MaterialUI.Internal.TextField.Model as TextField
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.Text as Text
import MaterialUI.TextFieldM as TextField
import MaterialUI.Theme as Theme
import MaterialUI.Themes.Dark as Dark


type alias Model =
    { mui : MaterialUI.Model () Msg
    , text1 : String
    , text2 : String
    , copyCount : Int
    }


type Msg
    = Text1 String
    | Text2 String
    | IconButton
    | Mui MaterialUI.Msg


init : Model
init =
    { mui = MaterialUI.defaultModel Mui {-Theme.defaultTheme-} Dark.theme
    , text1 = ""
    , text2 = ""
    , copyCount = 0
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Text1 text ->
            { model | text1 = text }

        Text2 text ->
            { model | text2 = text }

        IconButton ->
            { model | copyCount = model.copyCount + 1 }

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
                , onChange = Text1
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
                , onChange = Text2
                , errorText = Nothing
                , helperText = Nothing
                }
            , Element.row
                [ Element.width Element.fill
                , Element.spacing 8
                ]
                [ Icon.button
                    model.mui
                    [ Events.onClick IconButton
                    ]
                    { index = "iBut"
                    , color = Theme.OnBackground
                    , size = 24
                    , tooltip = "Copy the Id"
                    , icon = Content.content_copy
                    }
                , Text.view [] (String.fromInt model.copyCount) Theme.Body1 theme
                ]
            ]



main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }