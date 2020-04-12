module MaterialUI.Internal.State exposing
    ( State(..)
    , Model
    , Msg(..)
    , update
    , install
    , getState
    , defaultModel
    , toColorStateListState
    , colorListState
    )


import Element
import Element.Events as Event
import MaterialUI.ColorStateList as ColorStateList


type State
    = Idle
    | Hovered
    | Clicked


type alias Model =
    { hovered : Bool
    , clicked : Bool
    }


type Msg
    = MouseEnter
    | MouseLeave
    | MouseDown
    | MouseUp


defaultModel : Model
defaultModel =
    { hovered = False
    , clicked = False
    }


toColorStateListState : State -> ColorStateList.State
toColorStateListState state =
    case state of
        Idle -> ColorStateList.Idle

        Hovered -> ColorStateList.Hovered

        Clicked -> ColorStateList.MouseDown


getState : { s | state : Model } -> State
getState componentModel =
    let
        model = componentModel.state
    in
    if model.clicked && model.hovered then
        Clicked
    else if model.hovered then
        Hovered
    else
        Idle


colorListState : { s | state : Model } -> ColorStateList.State
colorListState =
    getState >> toColorStateListState


update : Msg -> { s | state : Model } -> { s | state : Model }
update msg componentModel =
    let
        state = componentModel.state
        newState = case msg of
            MouseEnter ->
                 { state | hovered = True }

            MouseLeave ->
                 { state | hovered = False }

            MouseDown ->
                 { state | clicked = True }

            MouseUp ->
                 { state | clicked = False }
    in
    { componentModel | state = newState }


install : (Msg -> msg) -> List (Element.Attribute msg)
install lift =
    [ Event.onMouseEnter <| lift MouseEnter
    , Event.onMouseLeave <| lift MouseLeave
    , Event.onMouseDown <| lift MouseDown
    , Event.onMouseUp <| lift MouseUp
    ]