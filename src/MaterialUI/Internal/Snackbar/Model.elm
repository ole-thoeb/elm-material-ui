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
    , AddBehaviour(..)
    )


import MaterialUI.Theme as Theme exposing (Theme)


type Status a msg
    = Nil
    | Active (Content a msg) State


type State
    = Showing
    | FadingIn Float
    | FadingOut Float


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
    | Dismiss Int
    | Clicked
    | AnimationFrame Float


type Position
    = Leading
    | Centered


type Duration
    = Short
    | Long


type AddBehaviour
    = KeepCurrent
    | DismissCurrent


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