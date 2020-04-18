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
import Element.Events as Event
import Html.Events as HtmlEvent
import Json.Decode as Decode
import MaterialUI.ColorStateList as ColorStateList
import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Icon.Model as Icon exposing (Icon, IconButton)
import MaterialUI.Internal.State as State
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

        color = ColorStateList.color iBut.color mui.theme
        background = ColorStateList.color iBut.background mui.theme
        iconColor = color (State.colorListState model)
            |> Element.toRgb
            |> Color.fromRgba

        icon = case iBut.icon of
            Icon.Icon i -> i
        padding = 8
        attr = attrs ++
            State.install (lift << Icon.State) ++
            [ Element.width <| Element.px (iBut.size + 2 * padding)
            , Element.height <| Element.px (iBut.size + 2 * padding)
            , Element.padding padding
            , Border.rounded 50
            , Event.onClick iBut.onClick
            , Element.mouseDown
                [ Background.color <| background ColorStateList.MouseDown
                ]
            , Element.focused
                [ Background.color <| background ColorStateList.Focused
                ]
            , Element.mouseOver
                [ Background.color <| background ColorStateList.Hovered
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


type alias Store s msg =
    { s
    | icon : Indexed Icon.Model
    , lift : Message.Msg -> msg
    }


getSet : Component.GetSetLift (Store s msg) Icon.Model
getSet =
    Component.getSet .icon (\model store -> { store | icon = model} ) Icon.defaultModel


update : Icon.Msg -> Index -> Store s msg -> ( Store s msg, Cmd msg )
update msg index store =
    Component.update getSet (store.lift << Message.IconMsg index) update_ msg index store


update_ : Icon.Msg -> Icon.Model -> ( Icon.Model, Cmd Icon.Msg )
update_ msg model =
    case msg of
        Icon.State subMsg ->
            ( State.update subMsg model, Cmd.none )

        Icon.NoOp ->
            ( model, Cmd.none )
