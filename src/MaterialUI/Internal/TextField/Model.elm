module MaterialUI.Internal.TextField.Model exposing
    ( Model
    , Msg(..)
    , defaultModel
    , Type(..)
    , State(..)
    , TextField
    , TextFieldManged
    )


import MaterialUI.Internal.Component as Component
import MaterialUI.Theme as Theme


type alias Model =
    { focused : Bool
    }


defaultModel : Model
defaultModel =
    { focused = False
    }


type Msg
    = ComponentFocused
    | ComponentFocusedLost


type Type
    = Filled
    | Outlined


type State
    = Idle
    | Focused
    | Disabled


type alias TextField a msg =
    { label : String
    , hideLabel : Bool
    , type_ : Type
    , color : Theme.Color a
    , text : String
    , onChange : String -> msg
    , state : State
    , errorText : Maybe String
    , helperText : Maybe String
    }


type alias TextFieldManged a msg =
    { index : Component.Index
    , label : String
    , hideLabel : Bool
    , type_ : Type
    , color : Theme.Color a
    , text : String
    , onChange : String -> msg
    , errorText : Maybe String
    , helperText : Maybe String
    }