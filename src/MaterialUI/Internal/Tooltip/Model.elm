module MaterialUI.Internal.Tooltip.Model exposing
    ( Model
    , Msg(..)
    , defaultModel
    , Tooltip
    , Position(..)
    )


import MaterialUI.Internal.Component exposing (Index)


type alias Model =
    { hovered : Bool
    }


defaultModel : Model
defaultModel =
    { hovered = False
    }


type Msg
    = MouseEnter
    | MouseLeave
    | BrowserAction
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