module MaterialUI.Internal.Icon.Model exposing
    ( Model
    , Msg(..)
    , defaultModel
    , Icon(..)
    , IconButton
    )


import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Theme as Theme


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
    | NoOp


type Icon msg
    = Icon (Internal.Icon msg)


type alias IconButton a msg =
    { index : Index
    , icon : Icon msg
    , color : Theme.Color a
    , tooltip : String
    , size : Int
    }