module MaterialUI.Internal.State exposing
    ( Model
    , Msg(..)
    , State(..)
    , colorListState
    , defaultModel
    , getColor
    , getState
    , install
    , isActive
    , toColorStateListState
    , update
    )

import Element
import Element.Events as Event
import MaterialUI.ColorStateList as ColorStateList exposing (ColorStateList)
import MaterialUI.Theme exposing (Theme)


type State
    = Idle
    | Hovered
    | Clicked
    | Focused


type alias Model =
    { hovered : Bool
    , clicked : Bool
    , focused : Bool
    }


type Msg
    = MouseEnter
    | MouseLeave
    | MouseDown
    | MouseUp
    | FocusGain
    | FocusLose


defaultModel : Model
defaultModel =
    { hovered = False
    , clicked = False
    , focused = False
    }


toColorStateListState : State -> ColorStateList.State
toColorStateListState state =
    case state of
        Idle ->
            ColorStateList.Idle

        Hovered ->
            ColorStateList.Hovered

        Clicked ->
            ColorStateList.MouseDown

        Focused ->
            ColorStateList.Focused


getState : { s | state : Model } -> State
getState componentModel =
    let
        model =
            componentModel.state
    in
    if model.clicked && model.hovered then
        Clicked

    else if model.focused then
        Focused

    else if model.hovered then
        Hovered

    else
        Idle


isActive : State -> Bool
isActive state =
    case state of
        Idle ->
            False

        Hovered ->
            False

        Clicked ->
            True

        Focused ->
            True


colorListState : { s | state : Model } -> ColorStateList.State
colorListState =
    getState >> toColorStateListState


getColor : { s | state : Model } -> ColorStateList a -> Theme a -> Element.Color
getColor model colorStateList theme =
    ColorStateList.color colorStateList theme (colorListState model)


update : Msg -> { s | state : Model } -> { s | state : Model }
update msg componentModel =
    let
        state =
            componentModel.state

        newState =
            case msg of
                MouseEnter ->
                    { state | hovered = True }

                MouseLeave ->
                    { state | hovered = False, clicked = False }

                MouseDown ->
                    { state | clicked = True }

                MouseUp ->
                    { state | clicked = False }

                FocusGain ->
                    { state | focused = True }

                FocusLose ->
                    { state | focused = False }
    in
    { componentModel | state = newState }


install : (Msg -> msg) -> List (Element.Attribute msg)
install lift =
    [ Event.onMouseEnter <| lift MouseEnter
    , Event.onMouseLeave <| lift MouseLeave
    , Event.onMouseDown <| lift MouseDown
    , Event.onMouseUp <| lift MouseUp
    , Event.onFocus <| lift FocusGain
    , Event.onLoseFocus <| lift FocusLose
    ]
