module MaterialUI.Internal.Icon.Implementation exposing
    ( view
    , update
    , button
    , makeIcon
    )


import Color
import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Events as HtmlEvent
import Json.Decode as Decode
import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Icon.Model as Icon exposing (Icon, IconButton)
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme exposing (Theme)
import Svg


button : MaterialUI.Model a msg -> List (Element.Attribute msg) -> IconButton a msg -> Element msg
button mui attrs iBut =
    let
        index = iBut.index
        lift = mui.lift << Message.IconMsg index
        model = Maybe.withDefault Icon.defaultModel (Dict.get index mui.icon)

        color = Theme.getColor iBut.color mui.theme
        iconColor = color
            |> Element.toRgb
            |> Color.fromRgba
        icon = case iBut.icon of
            Icon.Icon i -> i
        padding = 8
        attr = attrs ++
            [ Element.width <| Element.px (iBut.size + 2 * padding)
            , Element.height <| Element.px (iBut.size + 2 * padding)
            , Element.padding padding
            , Border.rounded 50
            , Element.mouseDown
                [ Background.color (color |> Theme.setAlpha 0.2)
                ]
            , Element.focused
                [ Background.color (color |> Theme.setAlpha 0.15)
                ]
            , Element.mouseOver
                [ Background.color (color |> Theme.setAlpha 0.1)
                ]
            , Element.htmlAttribute <| HtmlEvent.onMouseEnter (lift Icon.MouseEnter)
            , Element.htmlAttribute <| HtmlEvent.onMouseLeave (lift Icon.MouseLeave)
            ] ++ if model.hovered then
                [ Element.below <| Element.el
                    [ Element.paddingEach { top = 8, bottom = 0, left = 0, right = 0 }
                    , Element.htmlAttribute <|
                        HtmlEvent.stopPropagationOn "click" (Decode.succeed ( lift Icon.NoOp, True ))
                    ]
                    <| Text.view
                        [ Element.centerX
                        , Element.padding 8
                        , Font.color mui.theme.color.onSurface
                        , Background.color <| Theme.setAlpha 0.1 mui.theme.color.onSurface
                        ]
                        iBut.tooltip
                        Theme.Caption
                        mui.theme
                ]
            else
                []
    in
    Element.el attr
        (Element.html
            (Svg.svg []
                [ icon iconColor iBut.size ]
            )
        )


makeIcon : Internal.Icon msg -> Icon msg
makeIcon =
    Icon.Icon


view : Theme a -> Theme.Color a -> Int -> Icon msg -> Element msg
view theme colorkey size (Icon.Icon icon) =
    let
        color =
            Theme.getColor colorkey theme
                |> Element.toRgb
                |> Color.fromRgba
    in
    Element.el
        [ Element.width <| Element.px size
        , Element.height <| Element.px size
        ]
        (Element.html
            (Svg.svg []
                [ icon color size ]
            )
        )


type alias Store s = { s | icon : Indexed Icon.Model }


getSet : Component.GetSet (Store s) Icon.Model
getSet =
    Component.getSet .icon (\model store -> { store | icon = model} ) Icon.defaultModel


update : Icon.Msg -> Index -> Store s -> Store s
update =
    Component.update getSet update_


update_ : Icon.Msg -> Icon.Model -> Icon.Model
update_ msg model =
    case msg of
        Icon.MouseEnter ->
            { model | hovered = True }

        Icon.MouseLeave ->
            { model | hovered = False }

        Icon.NoOp ->
            model