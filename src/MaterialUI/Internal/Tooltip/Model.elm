module MaterialUI.Internal.Tooltip.Model exposing
    ( Model
    , Msg(..)
    , Position(..)
    , State(..)
    , Tooltip
    , Transition(..)
    , defaultModel
    )

import MaterialUI.Internal.Component exposing (Index)


type alias Model =
    { hovered : Bool
    , state : State
    }


defaultModel : Model
defaultModel =
    { hovered = False
    , state = Nil
    }


type State
    = Active Transition
    | Nil


type Transition
    = AnimatingIn Float
    | AnimatingOut Float
    | Delaying Float
    | Showing


type Msg
    = MouseEnter
    | MouseLeave
    | BrowserAction
    | OnAnimationFrame Float
    | NoOp


type Position
    = Left
    | Right
    | Top
    | Bottom


type alias Tooltip =
    { index : Index
    , text : String
    , position : Position
    }
