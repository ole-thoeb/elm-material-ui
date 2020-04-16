module MaterialUI.Internal.Snackbar.Model exposing
    ( Model
    , Msg(..)
    , defaultModel
    , Position(..)
    , Content
    , Action
    , Duration(..)
    , Status(..)
    , State(..)
    )


import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Theme as Theme


type Status a msg
    = Nil
    | Active (Content a msg) State


type State
    = Showing
    | FadingIn
    | FadingOut

type alias Model a msg =
    { queue : List (Content a msg)
    , status : Status a msg
    , snackbarId : Int
    }


defaultModel : Model a msg
defaultModel =
    { queue = []
    , status = Nil
    , snackbarId = -1
    }


type Msg
    = NoOp
    | Hide Int
    | Show Int
    | Dismiss Int
    | Clicked


type Position
    = Leading
    | Centered


type Duration
    = Short
    | Long


type alias Action a msg =
    { text : String
    , action : msg
    , color : Theme.Color a
    }


type alias Content a msg =
    { text : String
    , position : Position
    , duration : Duration
    , action : Maybe (Action a msg)
    }