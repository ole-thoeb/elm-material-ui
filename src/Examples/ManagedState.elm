module Examples.ManagedState exposing (..)


import Browser
import Element
import Element.Background as Background
import Element.Font as Font
import Json.Decode as Decode
import MaterialUI.ColorStateList as ColorStateList exposing (ColorStateList)
import MaterialUI.Icon as Icon
import MaterialUI.Icons.Content as Content
import MaterialUI.Internal.TextField.Model as TextField
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.Snackbar as Snackbar
import MaterialUI.Text as Text
import MaterialUI.TextFieldM as TextField
import MaterialUI.Theme as Theme
import MaterialUI.Themes.Dark as Dark
import MaterialUI.Tooltip as Tooltip


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
    | SnackbarAction


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { mui = MaterialUI.defaultModel Mui {-Theme.defaultTheme--} Dark.theme
            , text1 = ""
            , text2 = ""
            , copyCount = 0
            }
        snackbar =
            { text = "Snackbar test"
            , duration = Snackbar.short
            , position = Snackbar.centered
            , action = Nothing
            }

        ( mui, effects ) = Snackbar.enqueue snackbar "snackbar" model.mui
    in
    ( { model | mui = mui }
    , effects
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Text1 text ->
            ( { model | text1 = text }, Cmd.none )

        Text2 text ->
            ( { model | text2 = text }, Cmd.none )

        IconButton ->
            let
                ( mui, effects ) = Snackbar.enqueue
                    { text = "Copied!!! Yay some longer text that really is super long"
                    , duration = Snackbar.short
                    , position = Snackbar.centered
                    , action = Just
                        { text = "Action Baby +10"
                        , color = Theme.Primary
                        , action = SnackbarAction
                        }
                    }
                    "snackbar"
                    model.mui
            in
            ( { model | copyCount = model.copyCount + 1, mui = mui }, effects )

        Mui mui ->
            MaterialUI.update mui model.mui
             |> Tuple.mapFirst (\upMui -> { model | mui = upMui })

        SnackbarAction ->
            ( { model | copyCount = model.copyCount + 10}, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        theme = model.mui.theme
    in
    { title = "Example"
    , body = List.singleton <| Element.layout
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
            , Tooltip.view model.mui
                [ Element.width Element.fill
                ]
                { index = "tttf1"
                , text = "Textfield with tooltip that has a super long tooltip u now"
                , position = Tooltip.bottom
                }
                <| TextField.managed model.mui
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
                [ Icon.button model.mui []
                    { index = "iBut"
                    , onClick = IconButton
                    , color =
                        { transparentCSL
                        | idle = ColorStateList.Color 0.9 Theme.OnBackground
                        , hovered = ColorStateList.Color 0.9 Theme.Primary
                        , mouseDown = ColorStateList.Color 1 Theme.Primary
                        }
                    , background = transparentCSL
                    , size = 24
                    , tooltip = "Copy the Id gogoggogogo"
                    , icon = Content.content_copy
                    }
                , Text.view [] (String.fromInt model.copyCount) Theme.Body1 theme
                ]
            , Snackbar.view model.mui "snackbar"
            ]
    }



transparentCSL : ColorStateList a
transparentCSL =
    ColorStateList.all ColorStateList.transparent


subscriptions : Model -> Sub Msg
subscriptions model =
    MaterialUI.subscriptions model.mui


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }