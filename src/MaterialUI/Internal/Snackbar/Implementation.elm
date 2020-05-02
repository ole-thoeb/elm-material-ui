module MaterialUI.Internal.Snackbar.Implementation exposing
    ( view
    , update
    , subscriptions
    , add
    )


import Browser.Events
import Dict
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import MaterialUI.Button as Button
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Snackbar.Model as Snackbar exposing (Content)
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme exposing (Theme)


fadeInDuration : Float
fadeInDuration =
    100


fadeOutDuration : Float
fadeOutDuration =
    300


view : MaterialUI.Model a msg
    -> Index
    -> Element msg
view mui index =
    let
        lift = mui.lift << Message.SnackbarMsg index
        model = Maybe.withDefault Snackbar.defaultModel (Dict.get index mui.snackbar)
        invTheme = Theme.inverted mui.theme
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
                    Snackbar.Showing -> 1
                    Snackbar.FadingIn progress -> progress
                    Snackbar.FadingOut progress -> progress

                text = Text.wrapping
                    [ Element.padding 12
                    , Element.alignLeft
                    , Element.width (Element.fillPortion 1 |> Element.minimum 150)
                    ]
                    snackbar.text Theme.Body1 mui.theme

                button = snackbar.action
                    |>Maybe.map (\action -> actionToButton action mui.theme lift)
                    |> Maybe.withDefault Element.none
            in
            Element.el
                (alignAttr
                    ++ [ Element.padding 16
                    , Element.width (Element.fill |> Element.maximum 500)
                    , Component.elementCss "position" "fixed"
                    , Component.elementCss "bottom" "0"
                    , Element.alpha opacity
                    ]
                )
                <| Element.wrappedRow
                    [ Element.width Element.fill
                    , Element.paddingEach { top = 4, bottom = 4, left = 12, right = 12 }
                    , Element.spacing 4
                    , Background.color invTheme.color.surface
                    , Font.color invTheme.color.onSurface
                    , Border.rounded 8
                    ]
                    [ text
                    , button
                    ]

        Snackbar.Nil ->
            Element.none


actionToButton : Snackbar.Action a msg -> Theme a -> (Snackbar.Msg -> msg) -> Element msg
actionToButton action theme lift =
    Button.text
        [ Element.alignRight
        ]
        { icon = Nothing
        , color = action.color
        , text = action.text
        , onPress = Just <| lift Snackbar.Clicked
        , disabled = False
        }
        (Theme.inverted theme)


type alias Store s a msg =
    { s
    | snackbar : Indexed (Snackbar.Model a msg)
    , lift : Message.Msg -> msg
    }


getSet : Component.GetSet (Store s a msg) (Snackbar.Model a msg)
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
    case ( msg, model.status ) of
        ( Snackbar.Dismiss id, Snackbar.Active content _ )  ->
            if id == model.snackbarId then
                ( { model
                | status = Snackbar.Active content (Snackbar.FadingOut 1)
                }, Cmd.none
                )
            else
                ( model, Cmd.none )

        ( Snackbar.Clicked, Snackbar.Active content Snackbar.Showing)  ->
            let
                ( updatedModel, effects ) = update_ lift (Snackbar.Dismiss model.snackbarId) model
                userAction = content.action
                    |> Maybe.map (\action -> [ Component.cmd action.action ])
                    |> Maybe.withDefault []
            in
            ( updatedModel, Cmd.batch (effects :: userAction) )

        ( Snackbar.AnimationFrame delta, Snackbar.Active content (Snackbar.FadingIn progress) ) ->
            let
                newProgress = progress + (delta / fadeInDuration)
            in
            if newProgress >= 1 then
                ( { model | status = Snackbar.Active content Snackbar.Showing }, Cmd.none )
            else
                ( { model | status = Snackbar.Active content (Snackbar.FadingIn newProgress) }, Cmd.none )

        ( Snackbar.AnimationFrame delta, Snackbar.Active content (Snackbar.FadingOut progress) ) ->
            let
                newProgress = progress - (delta / fadeOutDuration)
            in
            if newProgress <= 0 then
                tryDequeue { model | status = Snackbar.Nil }
                    |> Tuple.mapSecond (Cmd.map lift)
            else
                ( { model | status = Snackbar.Active content (Snackbar.FadingOut newProgress) }, Cmd.none )

        _ ->
            ( model, Cmd.none )


tryDequeue : Snackbar.Model a msg -> ( Snackbar.Model a msg, Cmd Snackbar.Msg )
tryDequeue model =
    case Debug.log "dequeueState" model.status of
        Snackbar.Nil ->
            case model.queue of
                head :: rest ->
                    setSnackbar head { model | queue = rest }

                _ ->
                    ( model, Cmd.none )

        _ ->
                ( model, Cmd.none )


setSnackbar : Content a msg -> Snackbar.Model a msg -> ( Snackbar.Model a msg, Cmd Snackbar.Msg )
setSnackbar snackbar model =
    let
        duration = case snackbar.duration of
            Snackbar.Short -> 4 * 1000
            Snackbar.Long -> 10 * 1000
        id = model.snackbarId + 1
    in
    ({ model | status = Snackbar.Active snackbar (Snackbar.FadingIn 0) , snackbarId = id }
    , Component.delayedCmd duration <| Snackbar.Dismiss id
    )


updateSnackModel : MaterialUI.Model a msg
    -> Index
    -> Content a msg
    -> ( Content a msg -> Snackbar.Model a msg -> ( Snackbar.Model a msg, Cmd Snackbar.Msg ) )
    -> ( MaterialUI.Model a msg, Cmd msg )
updateSnackModel mui index snackbar updateFunc =
    let
        model = Dict.get index mui.snackbar
            |> Maybe.withDefault Snackbar.defaultModel

        ( updatedModel, effects ) = updateFunc snackbar model
            |> Tuple.mapSecond (Cmd.map (mui.lift << Message.SnackbarMsg index))
    in
    ( { mui | snackbar = Dict.insert index updatedModel mui.snackbar }, effects )


add : MaterialUI.Model a msg
    -> Index
    -> Content a msg
    -> (Content a msg -> List (Content a msg) -> List (Content a msg))
    -> Snackbar.AddBehaviour
    -> ( MaterialUI.Model a msg, Cmd msg )
add mui index snackbar queueTransform behavior =
    updateSnackModel mui index snackbar (add_ queueTransform behavior)


add_ : (Content a msg -> List (Content a msg) -> List (Content a msg))
    -> Snackbar.AddBehaviour
    -> Content a msg
    -> Snackbar.Model a msg
    -> ( Snackbar.Model a msg, Cmd Snackbar.Msg )
add_ queueTransform behavior snackbar model =
    let
        updatedModel = { model | queue = queueTransform snackbar model.queue }
    in
    case model.status of
        Snackbar.Nil ->
            updatedModel
                |> tryDequeue

        Snackbar.Active _ _ ->
            case behavior of
                Snackbar.KeepCurrent ->
                    ( updatedModel, Cmd.none )

                Snackbar.DismissCurrent ->
                    ( updatedModel, Component.cmd (Snackbar.Dismiss model.snackbarId) )



subscriptions : MaterialUI.Model a msg -> Sub msg
subscriptions model =
    Component.subscriptions .snackbar Message.SnackbarMsg model subscriptions_


subscriptions_ : Snackbar.Model a msg -> Sub Snackbar.Msg
subscriptions_ model =
    let
        isAnimating = case model.status of
            Snackbar.Active _ (Snackbar.FadingIn _) -> True
            Snackbar.Active _ (Snackbar.FadingOut _)-> True
            _ -> False
    in
    if isAnimating then
        Browser.Events.onAnimationFrameDelta Snackbar.AnimationFrame
    else
        Sub.none