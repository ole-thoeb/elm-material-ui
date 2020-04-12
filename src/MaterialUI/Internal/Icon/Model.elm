module MaterialUI.Internal.Icon.Model exposing
    ( Model
    , Msg(..)
    , defaultModel
    , Icon(..)
    , IconButton
    )


import MaterialUI.ColorStateList exposing (ColorStateList)
import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Internal.State as State
import MaterialUI.Theme as Theme


type alias Model =
    { state : State.Model
    }


defaultModel : Model
defaultModel =
    { state = State.defaultModel
    }


type Msg
    = State State.Msg
    | NoOp


type Icon msg
    = Icon (Internal.Icon msg)


type alias IconButton a msg =
    { index : Index
    , icon : Icon msg
    , onClick : msg
    , color : ColorStateList a
    , background : ColorStateList a
    , tooltip : String
    , size : Int
    }