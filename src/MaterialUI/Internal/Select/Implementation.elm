module MaterialUI.Internal.Select.Implementation exposing (outlined, subscriptions, update)

import Browser.Events
import Dict
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Json.Decode as Decode
import MaterialUI.ColorStateList as ColorStateList exposing (ColorStateList)
import MaterialUI.Icon as Icon
import MaterialUI.Icons.Navigation as Navigation
import MaterialUI.Internal.Component as Component exposing (Index, Indexed)
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Internal.Select.Model as Select
import MaterialUI.Internal.State as State
import MaterialUI.Text as Text
import MaterialUI.Theme as Theme exposing (Theme)


outlined : MaterialUI.Model a msg -> List (Element.Attribute msg) -> Select.Menu a item msg -> Element msg
outlined mui attrs menu =
    let
        index =
            menu.index

        model =
            Dict.get index mui.menu
                |> Maybe.withDefault Select.defaultModel

        lift =
            mui.lift << Message.SelectMsg index

        theme =
            mui.theme

        isActive =
            (State.getState model |> State.isActive) || model.status == Select.Open || model.status == Select.Opening

        borderColor =
            if isActive then
                ColorStateList.color menu.color theme ColorStateList.Focused

            else
                State.getColor model menu.color theme

        borderWidth =
            if isActive then
                2

            else
                1

        borders =
            Theme.shapeToAttributes 56 56 theme.shape.textField.outlined
                ++ [ Border.width borderWidth
                   , Border.color borderColor
                   , Component.elementCss "transition" "border-width 0.15s"
                   ]

        labelAtTop =
            case menu.selectedItem of
                Just _ ->
                    True

                Nothing ->
                    isActive

        labelPosition =
            Element.alignBottom
                :: (if labelAtTop then
                        [ Element.moveRight 10
                        , Background.color theme.color.surface
                        , Element.moveUp 48
                        ]

                    else
                        [ Element.moveRight 10
                        , Element.moveUp 20
                        ]
                   )

        labelFont =
            if labelAtTop then
                Theme.fontToAttributes theme.typescale.caption

            else
                Theme.fontToAttributes theme.typescale.subtitle1

        labelFontColor =
            if isActive then
                ColorStateList.color menu.color theme ColorStateList.Focused

            else
                theme.color.onSurface |> Theme.setAlpha 0.6

        label =
            Element.el
                (labelPosition
                    ++ labelFont
                    ++ [ Component.elementCss "transition" "all 0.15s"
                       , Element.width Element.shrink
                       , Element.paddingXY 4 0
                       , Font.color labelFontColor
                       ]
                )
                (Element.text menu.label)

        menuList =
            case model.status of
                Select.Closed ->
                    Element.none

                _ ->
                    -- Open && Opening
                    Element.el
                        [ Element.paddingEach { top = 2, bottom = 0, left = 0, right = 0 }
                        , Element.width Element.fill
                        ]
                    <|
                        Element.column
                            (elevateBackground Theme.Surface mui.theme
                                ++ [ Element.width Element.fill
                                   , Element.paddingXY 0 6
                                   , Border.rounded 6
                                   ]
                            )
                            (List.indexedMap (menuItemView mui menu model) menu.items)

        selectionText =
            menu.selectedItem
                |> Maybe.map (\item -> (menu.toItem item).text)
                |> Maybe.withDefault ""

        statusIcon =
            case model.status of
                Select.Closed ->
                    Navigation.arrow_drop_down

                Select.Open ->
                    Navigation.arrow_drop_up

                Select.Opening ->
                    Navigation.arrow_drop_up
    in
    Element.row
        (attrs
            ++ State.install (lift << Select.State)
            ++ borders
            ++ [ Element.inFront label
               , Element.below menuList
               , Element.height <| Element.px 56
               , Element.paddingXY 12 0
               , Events.onClick <| lift Select.Clicked
               , Element.pointer
               ]
        )
        [ Text.view
            [ Element.centerY
            , Element.width Element.fill
            ]
            selectionText
            Theme.Subtitle1
            mui.theme
        , Icon.view mui.theme (Theme.Custom labelFontColor) 24 statusIcon
        ]


elevateBackground : Theme.Color a -> Theme a -> List (Element.Attribute msg)
elevateBackground colorKey theme =
    let
        color =
            Theme.getColor colorKey theme
    in
    if theme |> Theme.isDark then
        let
            { red, green, blue, alpha } =
                Element.toRgb color

            onColor =
                Theme.getOnColor colorKey theme |> Element.toRgb

            factor =
                0.08
        in
        [ Background.color <|
            Element.fromRgb
                { red = red + onColor.red * factor
                , green = green + onColor.green * factor
                , blue = blue + onColor.blue * factor
                , alpha = alpha
                }
        ]

    else
        [ Background.color color
        , Border.shadow
            { offset = ( 1, 1 )
            , size = 1
            , blur = 2
            , color = Theme.setAlpha 0.16 theme.color.onSurface
            }
        ]


menuItemBackgroundCST : ColorStateList a
menuItemBackgroundCST =
    { idle = ColorStateList.Color 1 Theme.Surface
    , focused = ColorStateList.Color 0.2 Theme.OnSurface
    , mouseDown = ColorStateList.Color 0.3 Theme.OnSurface
    , disabled = ColorStateList.Color 1 Theme.Surface
    , hovered = ColorStateList.Color 0.1 Theme.OnSurface
    }


menuItemView :
    MaterialUI.Model a msg
    -> Select.Menu a item msg
    -> Select.Model
    -> Int
    -> Select.Item item
    -> Element msg
menuItemView mui menu store pos menuItem =
    case menuItem of
        Select.Item item ->
            let
                index =
                    String.fromInt pos

                { text } =
                    menu.toItem item

                menuModel =
                    Dict.get index store.menuItems
                        |> Maybe.withDefault Select.defaultMenuItemModel
            in
            Text.view
                (State.install (mui.lift << Message.SelectMsg menu.index << Select.ItemState index)
                    ++ [ Element.width Element.fill
                       , Element.paddingXY 12 8
                       , Background.color <| State.getColor menuModel menuItemBackgroundCST mui.theme
                       , Events.onClick <| menu.onClick item
                       , Element.pointer
                       ]
                )
                text
                Theme.Body1
                mui.theme


type alias Store s msg =
    { s
        | menu : Indexed Select.Model
        , lift : Message.Msg -> msg
    }


getSet : Component.GetSet (Store s msg) Select.Model
getSet =
    Component.getSet .menu (\model store -> { store | menu = model }) Select.defaultModel


update : Select.Msg -> Index -> Store s msg -> ( Store s msg, Cmd msg )
update msg index store =
    Component.update getSet (store.lift << Message.SelectMsg index) update_ msg index store


update_ : Select.Msg -> Select.Model -> ( Select.Model, Cmd Select.Msg )
update_ msg model =
    case msg of
        Select.State stateMsg ->
            ( State.update stateMsg model, Cmd.none )

        Select.Clicked ->
            case model.status of
                Select.Open ->
                    ( { model | status = Select.Closed, menuItems = Dict.empty }, Cmd.none )

                Select.Opening ->
                    ( model, Cmd.none )

                Select.Closed ->
                    ( { model | status = Select.Opening }, Component.delayedCmd 10 Select.FullyOpened )

        Select.ForceClose ->
            if model.status /= Select.Opening then
                ( { model | status = Select.Closed, menuItems = Dict.empty }, Cmd.none )

            else
                ( model, Cmd.none )

        Select.FullyOpened ->
            ( { model | status = Select.Open }, Cmd.none )

        Select.ItemState index stateMsg ->
            let
                itemModel =
                    Dict.get index model.menuItems
                        |> Maybe.withDefault Select.defaultMenuItemModel

                updatedModel =
                    State.update stateMsg itemModel
            in
            ( { model | menuItems = Dict.insert index updatedModel model.menuItems }, Cmd.none )


subscriptions : MaterialUI.Model a msg -> Sub msg
subscriptions mui =
    Component.subscriptions .menu Message.SelectMsg mui subscriptions_


subscriptions_ : Select.Model -> Sub Select.Msg
subscriptions_ model =
    case model.status of
        Select.Closed ->
            Sub.none

        Select.Open ->
            Sub.batch
                [ Browser.Events.onClick <| Decode.succeed Select.ForceClose
                , Browser.Events.onKeyDown <| Decode.succeed Select.ForceClose
                ]

        Select.Opening ->
            Sub.none
