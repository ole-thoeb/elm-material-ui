module MaterialUI.Internal.Snackbar.Implementation exposing
    ( view
    , update
    , enqueue)


import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Snackbar.Model as Snackbar exposing (Content)
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme


fadeInDuration : Float
fadeInDuration =
    300


fadeOutDuration : Float
fadeOutDuration =
    300



view : MaterialUI.Model a msg
    -> Index
    -> Element msg
view mui index =
    let
        lift = mui.lift << Message.TooltipMsg index
        model = Maybe.withDefault Snackbar.defaultModel (Dict.get index mui.snackbar)
    in
    case model.status of
        Snackbar.Active snackbar state  ->
            let
                alignAttr = case snackbar.position of
                    Snackbar.Leading ->
                        [ Component.elementCss "left" "0"
                        ]

                    Snackbar.Centered ->
                        [ Component.elementCss "left" "50%"
                        , Component.elementCss "transform" "translateX(-50%)"
                        ]

                opacity = case state of
                    Snackbar.Showing ->
                        [ Component.elementCss "opacity" "1"
                        , Component.elementCss "transition" <| "opacity " ++ String.fromFloat fadeOutDuration ++ "ms"
                        ]

                    Snackbar.FadingIn ->
                        [ Component.elementCss "opacity" "1"
                        , Component.elementCss "transition" <| "opacity " ++ String.fromFloat fadeInDuration ++ "ms"
                        ]

                    Snackbar.FadingOut ->
                        [ Component.elementCss "opacity" "0"
                        , Component.elementCss "transition" <| "opacity " ++ String.fromFloat fadeOutDuration ++ "ms"
                        ]


            in
            Element.el
                ( alignAttr ++
                  opacity ++
                [ Element.padding 16
                , Element.width (Element.fill |> Element.maximum 500)
                , Component.elementCss "position" "fixed"
                , Component.elementCss "bottom" "0"
                ]
                )
                    <| Element.row
                        [ Element.width Element.fill
                        , Element.padding 16
                        , Background.color mui.theme.color.onSurface
                        , Font.color mui.theme.color.surface
                        , Border.rounded 8
                        ]
                        [ Text.view
                            []
                            snackbar.text Theme.Body1 mui.theme
                        ]

        Snackbar.Nil ->
            Element.none


type alias Store s a msg = { s | snackbar : Indexed (Snackbar.Model a msg), lift : Message.Msg -> msg }


getSet : Component.GetSetLift (Store s a msg) (Snackbar.Model a msg)
getSet =
    Component.getSet .snackbar (\model store -> { store | snackbar = model} ) Snackbar.defaultModel


update : Snackbar.Msg -> Index -> Store s a msg -> ( Store s a msg, Cmd msg )
update msg index store =
    let
        lift = store.lift << Message.SnackbarMsg index
        model = getSet.get index store
        ( updatedModel, effects ) = update_ lift msg model
    in
    ( getSet.set index updatedModel store, effects )


update_ : (Snackbar.Msg -> msg) -> Snackbar.Msg -> Snackbar.Model a msg -> ( Snackbar.Model a msg, Cmd msg )
update_ lift msg model =
    case msg of
        Snackbar.NoOp ->
            ( model, Cmd.none )

        Snackbar.Hide id ->
            if (id == model.snackbarId) then
                { model | status = Snackbar.Nil }
                    |> tryDequeue
                    |> Tuple.mapSecond (Cmd.map lift)
            else
                ( model, Cmd.none )

        Snackbar.Show id ->
            if id == model.snackbarId then case model.status of
                Snackbar.Nil ->
                    ( model, Cmd.none )

                Snackbar.Active content _ ->
                    ( { model | status = Snackbar.Active content Snackbar.Showing }, Cmd.none )
            else
                ( model, Cmd.none )


        Snackbar.Dismiss id ->
            if id == model.snackbarId then case model.status of
                Snackbar.Nil ->
                    ( model, Cmd.none )

                Snackbar.Active content _ ->
                    ( { model | status = Snackbar.Active content Snackbar.FadingOut }, Component.delayedCmd fadeOutDuration (lift <| Snackbar.Hide id) )
            else
                ( model, Cmd.none )

        Snackbar.Clicked ->
            case model.status of
                Snackbar.Nil ->
                    ( model, Cmd.none )
                
                Snackbar.Active content _ ->
                    let
                        ( updatedModel, effects ) = update_ lift (Snackbar.Dismiss model.snackbarId) model
                        userAction = case content.action of
                            Nothing -> []
                            Just action -> [ Component.cmd action.action ]
                    in
                    ( updatedModel, Cmd.batch ([ effects ] ++ userAction) )


enqueue : Content a msg -> Index -> MaterialUI.Model a msg -> ( MaterialUI.Model a msg, Cmd msg )
enqueue snackbar index mui =
    let
        model = Dict.get index mui.snackbar
            |> Maybe.withDefault Snackbar.defaultModel

        ( updatedModel, effects ) = enqueue_ snackbar model
            |> tryDequeue
            |> Tuple.mapSecond (Cmd.map (mui.lift << Message.SnackbarMsg index))
    in
    ( { mui | snackbar = Dict.insert index updatedModel mui.snackbar }, effects )


enqueue_ : Content a msg -> Snackbar.Model a msg -> Snackbar.Model a msg
enqueue_ snackbar model =
    { model | queue = model.queue ++ [snackbar] }


tryDequeue : Snackbar.Model a msg -> ( Snackbar.Model a msg, Cmd Snackbar.Msg )
tryDequeue model =
    case Debug.log "dequeueState" model.status of
        Snackbar.Nil ->
            case model.queue of
                head :: rest ->
                    let
                        duration = case head.duration of
                            Snackbar.Short -> 4 * 1000
                            Snackbar.Long -> 10 * 1000
                        id = model.snackbarId + 1
                        a = Debug.log "dequeue" head
                    in
                    ({model
                    | queue = rest
                    , status = Snackbar.Active head Snackbar.FadingIn
                    , snackbarId = id
                    }
                    , Cmd.batch
                        [ Component.delayedCmd duration <| Snackbar.Dismiss id
                        , Component.delayedCmd fadeInDuration <| Snackbar.Show id
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        _ ->
                ( model, Cmd.none )









--subscriptions : MaterialUI.Model a msg -> Sub msg
--subscriptions mui =
--    let
--        lift = \index -> mui.lift << Message.TooltipMsg index
--    in
--    Dict.foldr (\index model acc ->  Sub.map (lift index) (subscriptions_ model) :: acc) [] mui.tooltip
--        |> Sub.batch
--
--
--subscriptions_ : Tooltip.Model -> Sub Tooltip.Msg
--subscriptions_ _ =
--    let
--        browserAction = Decode.succeed Tooltip.BrowserAction
--    in
--    Sub.batch
--        [ Browser.Events.onMouseDown browserAction
--        , Browser.Events.onKeyDown browserAction
--        ]