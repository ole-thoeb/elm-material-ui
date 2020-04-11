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
import Html.Events as HtmlEvent
import Json.Decode as Decode
import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Icon.Model as Icon exposing (Icon, IconButton)
import MaterialUI.Theme as Theme exposing (Theme)
import MaterialUI.Internal.Tooltip.Implementation as Tooltip
import MaterialUI.Internal.Tooltip.Model as Tooltip
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
            ]
    in
    Tooltip.view mui []
        { index = iBut.index ++ "tooltip"
        , text = iBut.tooltip
        , position = Tooltip.Bottom
        }
        <|  Element.el attr <| Element.html <| Svg.svg []
            [ icon iconColor iBut.size ]


dontPropagate : (Icon.Msg -> msg) -> String -> Element.Attribute msg
dontPropagate lift eventName =
    Element.htmlAttribute <|
        HtmlEvent.stopPropagationOn eventName (Decode.succeed ( lift Icon.NoOp, True ))


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