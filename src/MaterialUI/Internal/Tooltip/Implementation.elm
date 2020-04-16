module MaterialUI.Internal.Tooltip.Implementation exposing
    ( view
    , update
    , subscriptions)


import Browser.Events
import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Font as Font
import Html.Events as HtmlEvent
import Json.Decode as Decode
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Tooltip.Model as Tooltip exposing (Tooltip)
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme


view : MaterialUI.Model a msg
    -> List (Element.Attribute msg) -- for layout attributes (same as content)
    -> Tooltip
    -> Element msg
    -> Element msg
view mui layoutAtt tooltip content =
    let
        index = tooltip.index
        lift = mui.lift << Message.TooltipMsg index
        model = Maybe.withDefault Tooltip.defaultModel (Dict.get index mui.tooltip)
        tooltipView = Text.view
                ([Element.padding 8
                , Font.color mui.theme.color.onTooltip
                , Background.color mui.theme.color.tooltip
                , Component.elementCss "transition" "transform 0.1s ease-in-out"
                , Component.elementCss "transition" "visibility 0.4s "
                ]
                ++ Theme.shapeToAttributes 100 100 mui.theme.shape.tooltip
                ++ if model.hovered then
                    [ Component.elementCss "transform" "scale(1)"
                    , Component.elementCss "transition-delay" "0.3s"
                    , Component.elementCss "visibility" "visible"
                    ]
                else
                    [ Component.elementCss "transform" "scale(0)"
                    , Component.elementCss "visibility" "hidden"
                    ]
                )
                tooltip.text
                Theme.Caption
                mui.theme
        positionCss =
            if model.hovered then
                [ Component.elementCss "transition" "visibility 0.4s "
                , Component.elementCss "visibility" "visible"
                ]
            else
                [ Component.elementCss "transition" "visibility 0.4s "
                , Component.elementCss "visibility" "hidden"
                ]
        position = case tooltip.position of
            Tooltip.Left ->
                Element.onLeft << Element.el
                    ([ Element.paddingEach { padding | right = 8 }
                    , Element.centerY
                    ] ++ positionCss)

            Tooltip.Right ->
                Element.onRight << Element.el
                    ([Element.paddingEach { padding | left = 8 }
                    , Element.centerY
                    ] ++ positionCss)

            Tooltip.Top ->
                Element.above  << Element.el
                    ([Element.paddingEach { padding | bottom = 8 }
                    , Element.centerX
                    ] ++ positionCss)

            Tooltip.Bottom ->
                Element.below << Element.el
                    ([Element.paddingEach { padding | top = 8 }
                    , Element.centerX
                    ] ++ positionCss)
    in
    Element.el (layoutAtt ++ [ position tooltipView ])
        <| Element.el
             ( [ Element.htmlAttribute <| HtmlEvent.onMouseEnter (lift Tooltip.MouseEnter)
             , Element.htmlAttribute <| HtmlEvent.onMouseLeave (lift Tooltip.MouseLeave)
             ] ++ layoutAtt)
             content



padding = { top = 0, bottom = 0, left = 0, right = 0 }


dontPropagate : (Tooltip.Msg -> msg) -> String -> Element.Attribute msg
dontPropagate lift eventName =
    Element.htmlAttribute <|
        HtmlEvent.stopPropagationOn eventName (Decode.succeed ( lift Tooltip.NoOp, True ))


type alias Store s msg = { s | tooltip : Indexed Tooltip.Model, lift : Message.Msg -> msg }


getSet : Component.GetSetLift (Store s msg) Tooltip.Model
getSet =
    Component.getSet .tooltip (\model store -> { store | tooltip = model} ) Tooltip.defaultModel


update : Tooltip.Msg -> Index -> Store s msg -> ( Store s msg, Cmd msg )
update msg index store =
    Component.update getSet (store.lift << Message.TooltipMsg index) update_ msg index store


update_ : Tooltip.Msg -> Tooltip.Model -> ( Tooltip.Model, Cmd Tooltip.Msg )
update_ msg model =
    case msg of
        Tooltip.MouseEnter ->
            ( { model | hovered = True }, Cmd.none )

        Tooltip.MouseLeave ->
            ( { model | hovered = False }, Cmd.none )

        Tooltip.NoOp ->
            ( model, Cmd.none )

        Tooltip.BrowserAction ->
            ( { model | hovered = False }, Cmd.none )


subscriptions : MaterialUI.Model a msg -> Sub msg
subscriptions mui =
    let
        lift = \index -> mui.lift << Message.TooltipMsg index
    in
    Dict.foldr (\index model acc ->  Sub.map (lift index) (subscriptions_ model) :: acc) [] mui.tooltip
        |> Sub.batch


subscriptions_ : Tooltip.Model -> Sub Tooltip.Msg
subscriptions_ _ =
    let
        browserAction = Decode.succeed Tooltip.BrowserAction
    in
    Sub.batch
        [ Browser.Events.onMouseDown browserAction
        , Browser.Events.onKeyDown browserAction
        ]