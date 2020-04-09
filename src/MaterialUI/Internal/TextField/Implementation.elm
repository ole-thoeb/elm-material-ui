module MaterialUI.Internal.TextField.Implementation exposing
    ( text
    , view
    , update)


import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import MaterialUI.Internal as Internal
import MaterialUI.Internal.Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.TextField.Model as TextField exposing (TextField)
import MaterialUI.Theme as Theme exposing (Theme)


view : MaterialUI.Model a msg -> List (Element.Attribute msg) -> TextField.TextFieldManged a msg -> Element msg
view mui attr textField =
    let
        index = textField.index
        lift = mui.lift << Message.TextFieldMsg index
        model = Maybe.withDefault TextField.defaultModel (Dict.get index mui.textfield)
        state = if (model.focused) then TextField.Focused else TextField.Idle
    in
    text
        ( attr ++
            [ Events.onFocus <| lift TextField.ComponentFocused
            , Events.onLoseFocus <| lift TextField.ComponentFocusedLost
            ]
        )
        { label = textField.label
        , hideLabel = textField.hideLabel
        , type_ = textField.type_
        , color = textField.color
        , text = textField.text
        , onChange = textField.onChange
        , state = state
        , errorText = textField.errorText
        , helperText = textField.helperText
        }
        mui.theme



text : List (Attribute msg) -> TextField a msg -> Theme a -> Element msg
text attrs field theme =
    let
        hasError =
            field.errorText /= Nothing

        labelInFront =
            -- is the label in front of the input ?
            not field.hideLabel && field.state /= TextField.Focused && field.text == ""

        labelText =
            if hasError then
                field.label ++ "*"

            else
                field.label

        labelPosition =
            Element.alignBottom
                :: (case ( field.type_, labelInFront ) of
                        ( TextField.Outlined, True ) ->
                            [ Element.moveRight 10
                            , Element.moveUp 20
                            ]

                        ( TextField.Outlined, False ) ->
                            [ Element.moveRight 10
                            , Background.color theme.color.surface
                            , Element.moveUp 48
                            ]

                        ( TextField.Filled, True ) ->
                            [ Element.moveRight 8
                            , Element.moveUp <| 28 - toFloat theme.typescale.subtitle1.size / 2
                            ]

                        ( TextField.Filled, False ) ->
                            [ Element.moveRight 8
                            , Element.moveUp 36
                            ]
                   )

        labelColor =
            case ( hasError, field.state ) of
                ( True, _ ) ->
                    [ Font.color theme.color.error
                    ]

                ( False, TextField.Focused ) ->
                    [ Font.color (Theme.getColor field.color theme)
                    ]

                ( False, _ ) ->
                    [ Font.color (theme.color.onSurface |> Theme.setAlpha 0.6)
                    ]

        labelFont =
            if labelInFront then
                Theme.fontToAttributes theme.typescale.subtitle1

            else
                Theme.fontToAttributes theme.typescale.caption

        label =
            if field.hideLabel && not labelInFront then
                Element.none

            else
                Element.el
                    (labelPosition
                        ++ labelColor
                        ++ labelFont
                        ++ [ Element.htmlAttribute (Html.Attributes.style "transition" "all 0.15s")
                           , Element.width Element.shrink
                           , Element.paddingXY 4 0
                           ]
                    )
                    (Element.text labelText)

        borderColor =
            case ( hasError, field.state ) of
                ( True, _ ) ->
                    [ Border.color theme.color.error
                    ]

                ( False, TextField.Focused ) ->
                    [ Border.color <| Theme.getColor field.color theme
                    ]

                ( False, TextField.Idle ) ->
                    [ Border.color <| Theme.setAlpha 0.3 theme.color.onSurface
                    , Element.mouseOver
                        [ Border.color <| Theme.setAlpha 0.6 theme.color.onSurface
                        ]
                    ]

                ( False, TextField.Disabled ) ->
                    [ Border.color <| Theme.setAlpha 0.3 theme.color.onSurface
                    ]

        borders =
            case field.type_ of
                TextField.Outlined ->
                    Theme.shapeToAttributes 56 56 theme.shape.textField.outlined
                        ++ [ Border.width 1
                           , Element.focused
                                [ Border.glow theme.color.onSurface 0
                                ]
                           , Element.behindContent <|
                                Element.el
                                    (Theme.shapeToAttributes 56 56 theme.shape.textField.outlined
                                        ++ [ Border.width
                                                (if field.state == TextField.Focused then
                                                    2

                                                 else
                                                    1
                                                )
                                           , Element.width Element.fill
                                           , Element.height Element.fill
                                           , Element.htmlAttribute
                                                (Html.Attributes.style "transition" "border 0.15s")
                                           , Background.color <| Theme.setAlpha 0.0 theme.color.onSurface
                                           ]
                                        ++ borderColor
                                    )
                                    Element.none
                           ]
                        ++ borderColor

                TextField.Filled ->
                    Theme.shapeToAttributes 56 56 theme.shape.textField.filled
                        ++ [ Border.widthEach
                                { bottom =
                                    if field.state == TextField.Focused then
                                        2

                                    else
                                        1
                                , top = 0
                                , left = 0
                                , right = 0
                                }
                           , Border.color <| Theme.setAlpha 0.4 theme.color.onSurface
                           , Element.focused
                                [ Border.glow theme.color.onSurface 0
                                , Border.color <| Theme.getColor field.color theme
                                ]
                           , case field.state of
                                TextField.Idle ->
                                    Element.mouseOver
                                        [ Border.color <| Theme.setAlpha 0.8 theme.color.onSurface
                                        ]

                                TextField.Focused ->
                                    Border.color <| Theme.getColor field.color theme

                                TextField.Disabled ->
                                    Element.mouseOver
                                        []
                           ]
                        ++ borderColor

        padding =
            case field.type_ of
                TextField.Filled ->
                    [ Element.paddingEach
                        { top =
                            if field.hideLabel then
                                0

                            else
                                20
                        , bottom =
                            if field.state == TextField.Focused then
                                0

                            else
                                1
                        , left = 12
                        , right = 12
                        }
                    ]

                TextField.Outlined ->
                    [ Element.paddingXY 13 0
                    ]

        background =
            case field.type_ of
                TextField.Outlined ->
                    [ --Background.color theme.color.surface
                      Background.color <| Theme.setAlpha 0.0 theme.color.onSurface
                    ]

                TextField.Filled ->
                    [ Background.color <| Theme.setAlpha 0.05 theme.color.onSurface
                    ]
                        ++ (case field.state of
                                TextField.Focused ->
                                    [ Background.color <| Theme.setAlpha 0.15 theme.color.onSurface ]

                                TextField.Idle ->
                                    [ Element.mouseOver
                                        [ Background.color <| Theme.setAlpha 0.1 theme.color.onSurface
                                        ]
                                    , Element.focused
                                        [ Border.glow theme.color.onSurface 0
                                        , Background.color <| Theme.setAlpha 0.15 theme.color.onSurface
                                        ]
                                    ]

                                TextField.Disabled ->
                                    []
                           )

        belowElementAttributes =
            Theme.fontToAttributes theme.typescale.caption
                ++ [ Element.height <| Element.px 16
                   , Element.paddingXY 12 0
                   ]
    in
    Element.column attrs <|
        [ Input.text
            (Theme.fontToAttributes theme.typescale.subtitle1
                ++ borders
                ++ [ Element.height <| Element.px 56
                   , Element.inFront label
                   , Element.htmlAttribute
                        (Html.Attributes.style
                            "transition"
                            "border 0.15s, background 0.15s, padding 0.15s"
                        )
                   , Element.htmlAttribute (Html.Attributes.style "flex" "1")
                   , Font.color
                        (if field.state == TextField.Disabled then
                            Theme.setAlpha 0.7 theme.color.onSurface

                         else
                            theme.color.onSurface
                        )
                   , Internal.disabled <| field.state == TextField.Disabled
                   ]
                ++ padding
                ++ attrs
                ++ background
            )
            { onChange = field.onChange
            , label = Input.labelHidden field.label
            , placeholder = Nothing
            , text = field.text
            }
        ]
            ++ (case ( field.errorText, field.helperText ) of
                    ( Just error, _ ) ->
                        [ Element.el
                            (Font.color theme.color.error :: belowElementAttributes)
                            (Element.el [ Element.alignBottom ] <| Element.text error)
                        ]

                    ( Nothing, Just helperText ) ->
                        [ Element.el
                            (Font.color (Theme.setAlpha 0.6 theme.color.onSurface) :: belowElementAttributes)
                            (Element.el [ Element.alignBottom ] <| Element.text helperText)
                        ]

                    _ ->
                        []
               )


type alias Store s = { s | textfield : Indexed TextField.Model }


getSet :
    { get : Index -> Store s -> TextField.Model
    , set :
        Index
        -> TextField.Model
        -> Store s
        -> Store s
    }
getSet =
    { get = \index store -> Dict.get index store.textfield |> Maybe.withDefault TextField.defaultModel
    , set = \index model store -> { store | textfield = Dict.insert index model store.textfield }
    }


update : TextField.Msg -> Index -> Store s -> Store s
update msg index store =
    let
        model = getSet.get index store
        updatedModel = update_ msg model
    in
    getSet.set index updatedModel store


update_ : TextField.Msg -> TextField.Model -> TextField.Model
update_ msg model =
    case msg of
        TextField.ComponentFocused ->
            { model | focused = True }

        TextField.ComponentFocusedLost ->
            { model | focused = False }