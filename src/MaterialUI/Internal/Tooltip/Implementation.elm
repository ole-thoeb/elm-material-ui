module MaterialUI.Internal.Tooltip.Implementation exposing
    ( subscriptions
    , update
    , view
    )

import Browser.Events
import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Html.Events as HtmlEvent
import Json.Decode as Decode
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Tooltip.Model as Tooltip exposing (Tooltip)
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme exposing (Theme)


animInDuration : Float
animInDuration =
    100


showDelay : Float
showDelay =
    500


animOutDuration : Float
animOutDuration =
    100


view :
    MaterialUI.Model a msg
    -> List (Element.Attribute msg) -- for layout attributes (same as content)
    -> Tooltip
    -> Element msg
    -> Element msg
view mui layoutAtt tooltip content =
    let
        index =
            tooltip.index

        lift =
            mui.lift << Message.TooltipMsg index

        model =
            Maybe.withDefault Tooltip.defaultModel (Dict.get index mui.tooltip)

        progress =
            case model.state of
                Tooltip.Active Tooltip.Showing ->
                    1

                Tooltip.Active (Tooltip.AnimatingIn p) ->
                    p

                Tooltip.Active (Tooltip.AnimatingOut p) ->
                    p

                Tooltip.Active (Tooltip.Delaying _) ->
                    0

                Tooltip.Nil ->
                    0

        tooltipView =
            Text.view
                ([ Element.padding 8
                 , Font.color mui.theme.color.onTooltip
                 , Background.color mui.theme.color.tooltip
                 ]
                    ++ Theme.shapeToAttributes 100 100 mui.theme.shape.tooltip
                    ++ (if progress == 0 then
                            [ Component.elementCss "visibility" "hidden" ]

                        else
                            [ Component.elementCss "transform" <| "scale(" ++ String.fromFloat progress ++ ")"
                            , Component.elementCss "visibility" "visible"
                            ]
                       )
                )
                tooltip.text
                Theme.Caption
                mui.theme

        positionCss =
            [ Element.alpha progress
            , if progress == 0 then
                Component.elementCss "visibility" "hidden"

              else
                Component.elementCss "visibility" "visible"
            ]

        position =
            case tooltip.position of
                Tooltip.Left ->
                    Element.onLeft
                        << Element.el
                            (positionCss
                                ++ [ Element.paddingEach { padding | right = 8 }
                                   , Element.centerY
                                   ]
                            )

                Tooltip.Right ->
                    Element.onRight
                        << Element.el
                            (positionCss
                                ++ [ Element.paddingEach { padding | left = 8 }
                                   , Element.centerY
                                   ]
                            )

                Tooltip.Top ->
                    Element.above
                        << Element.el
                            (positionCss
                                ++ [ Element.paddingEach { padding | bottom = 8 }
                                   , Element.centerX
                                   ]
                            )

                Tooltip.Bottom ->
                    Element.below
                        << Element.el
                            (positionCss
                                ++ [ Element.paddingEach { padding | top = 8 }
                                   , Element.centerX
                                   ]
                            )
    in
    Element.el (layoutAtt ++ [ position tooltipView ]) <|
        Element.el
            (layoutAtt
                ++ [ Events.onMouseEnter (lift Tooltip.MouseEnter)
                   , Events.onMouseLeave (lift Tooltip.MouseLeave)
                   ]
            )
            content


padding =
    { top = 0, bottom = 0, left = 0, right = 0 }


dontPropagate : (Tooltip.Msg -> msg) -> String -> Element.Attribute msg
dontPropagate lift eventName =
    Element.htmlAttribute <|
        HtmlEvent.stopPropagationOn eventName (Decode.succeed ( lift Tooltip.NoOp, True ))


type alias Store s msg =
    { s
        | tooltip : Indexed Tooltip.Model
        , lift : Message.Msg -> msg
    }


getSet : Component.GetSetLift (Store s msg) Tooltip.Model
getSet =
    Component.getSet .tooltip (\model store -> { store | tooltip = model }) Tooltip.defaultModel


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

        Tooltip.OnAnimationFrame delta ->
            case ( model.hovered, model.state ) of
                ( True, Tooltip.Active Tooltip.Showing ) ->
                    ( model, Cmd.none )

                ( True, Tooltip.Active (Tooltip.AnimatingOut progress) ) ->
                    ( { model | state = Tooltip.Active (Tooltip.AnimatingIn progress) }
                    , Cmd.none
                    )

                ( True, Tooltip.Active (Tooltip.AnimatingIn progress) ) ->
                    let
                        newProgress =
                            progress + delta / animInDuration
                    in
                    if newProgress >= 1 then
                        ( { model | state = Tooltip.Active Tooltip.Showing }, Cmd.none )

                    else
                        ( { model | state = Tooltip.Active (Tooltip.AnimatingIn <| newProgress) }, Cmd.none )

                ( True, Tooltip.Active (Tooltip.Delaying progress) ) ->
                    let
                        newProgress =
                            progress + delta / showDelay
                    in
                    if newProgress >= 1 then
                        ( { model | state = Tooltip.Active (Tooltip.AnimatingIn 0) }, Cmd.none )

                    else
                        ( { model | state = Tooltip.Active (Tooltip.Delaying <| newProgress) }, Cmd.none )

                ( True, Tooltip.Nil ) ->
                    ( { model | state = Tooltip.Active (Tooltip.Delaying 0) }, Cmd.none )

                ( False, Tooltip.Active Tooltip.Showing ) ->
                    ( { model | state = Tooltip.Active (Tooltip.AnimatingOut 1) }, Cmd.none )

                ( False, Tooltip.Active (Tooltip.AnimatingOut progress) ) ->
                    let
                        newProgress =
                            progress - delta / animOutDuration
                    in
                    if newProgress <= 0 then
                        ( { model | state = Tooltip.Nil }, Cmd.none )

                    else
                        ( { model | state = Tooltip.Active (Tooltip.AnimatingOut <| newProgress) }, Cmd.none )

                ( False, Tooltip.Active (Tooltip.AnimatingIn progress) ) ->
                    ( { model | state = Tooltip.Active (Tooltip.AnimatingOut progress) }
                    , Cmd.none
                    )

                ( False, Tooltip.Active (Tooltip.Delaying _) ) ->
                    ( { model | state = Tooltip.Nil }, Cmd.none )

                ( False, Tooltip.Nil ) ->
                    ( model, Cmd.none )


subscriptions : MaterialUI.Model a msg -> Sub msg
subscriptions mui =
    Component.subscriptions .tooltip Message.TooltipMsg mui subscriptions_


subscriptions_ : Tooltip.Model -> Sub Tooltip.Msg
subscriptions_ _ =
    let
        browserAction =
            Decode.succeed Tooltip.BrowserAction
    in
    Sub.batch
        [ Browser.Events.onMouseDown browserAction
        , Browser.Events.onKeyDown browserAction
        , Browser.Events.onAnimationFrameDelta Tooltip.OnAnimationFrame
        ]
