module MaterialUI.Managed.Internal.Textfield.Model exposing (Model, Msg, defaultModel)


type alias Model =
    { focused : Bool
    }


defaultModel : Model
defaultModel =
    { focused = False
    }

type Msg
    = Focused

