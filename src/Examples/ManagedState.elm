module Examples.ManagedState exposing (..)


import Browser
import Element
import Element.Background as Background
import Element.Font as Font
import Json.Decode as Decode
import MaterialUI.Button as Button
import MaterialUI.ColorStateList as ColorStateList exposing (ColorStateList)
import MaterialUI.Icon as Icon
import MaterialUI.Icons.Content as Content
import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Internal.TextField.Model as TextField
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.Snackbar as Snackbar
import MaterialUI.Text as Text
import MaterialUI.TextFieldM as TextField
import MaterialUI.Theme as Theme
import MaterialUI.Themes.Default as DefaultTheme
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
    | SnackbarSet
    | SnackbarEnqueue
    | SnackbarEnqueueFirst


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { mui = MaterialUI.defaultModel Mui DefaultTheme.light
            , text1 = ""
            , text2 = ""
            , copyCount = 0
            }
        startSnackbar =
            { text = "Snackbar test"
            , duration = Snackbar.short
            , position = Snackbar.centered
            , action = Nothing
            }

        ( mui, effects ) = Snackbar.enqueue startSnackbar "snackbar" model.mui
    in
    ( { model | mui = mui }
    , effects
    )


snackbar : String -> Snackbar.Snackbar a Msg
snackbar text =
    { text = text
    , duration = Snackbar.short
    , position = Snackbar.leading
    , action = Just
        { text = "Action Baby +10"
        , color = Theme.Primary
        , action = SnackbarAction
        }
    }


addSnackbar : Model
    -> (Snackbar.Snackbar a Msg -> Index -> MaterialUI.Model () Msg -> ( MaterialUI.Model () Msg, Cmd Msg ))
    -> String
    -> ( Model, Cmd Msg )
addSnackbar model method text =
    let
        ( mui, effects ) = method (snackbar text) "snackbar" model.mui
    in
    ( { model | copyCount = model.copyCount + 1, mui = mui }, effects )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Text1 text ->
            ( { model | text1 = text }, Cmd.none )

        Text2 text ->
            ( { model | text2 = text }, Cmd.none )

        Mui mui ->
            MaterialUI.update mui model.mui
             |> Tuple.mapFirst (\upMui -> { model | mui = upMui })

        IconButton ->
            addSnackbar model Snackbar.enqueue "Copied !!"


        SnackbarAction ->
            ( { model | copyCount = model.copyCount + 10}, Cmd.none )

        SnackbarSet ->
            addSnackbar model Snackbar.set "Set"

        SnackbarEnqueue ->
            addSnackbar model Snackbar.enqueue "Queued"

        SnackbarEnqueueFirst ->
            addSnackbar model Snackbar.enqueueFirst "EnqueueFirst"



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
            , Element.row
                [ Element.width Element.fill
                , Element.spacing 8
                ]
                [ Button.outlined
                    [ Element.width <| Element.fillPortion 1
                    ]
                    { icon = Nothing
                    , text = "enqueue Snack"
                    , onPress = Just SnackbarEnqueue
                    , disabled = False
                    , color = Theme.Secondary
                    }
                    theme
                , Button.outlined
                     [ Element.width <| Element.fillPortion 1
                     ]
                     { icon = Nothing
                     , text = "set Snack"
                     , onPress = Just SnackbarSet
                     , disabled = False
                     , color = Theme.Secondary
                     }
                     theme
                , Button.outlined
                    [ Element.width <| Element.fillPortion 1
                    ]
                    { icon = Nothing
                    , text = "enqueueFirst Snack"
                    , onPress = Just SnackbarEnqueueFirst
                    , disabled = False
                    , color = Theme.Secondary
                    }
                    theme
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