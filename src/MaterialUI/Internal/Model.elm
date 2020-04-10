module MaterialUI.Internal.Model exposing (Model, defaultModel)


import Dict
import MaterialUI.Internal.Component exposing (Indexed)
import MaterialUI.Internal.Icon.Model as Icon
import MaterialUI.Internal.Message exposing (Msg)
import MaterialUI.Internal.TextField.Model as Textfield
import MaterialUI.Theme exposing (Theme)


type alias Model t msg =
    { theme : Theme t
    , lift : Msg -> msg
    , textfield : Indexed Textfield.Model
    , icon : Indexed Icon.Model
    }


defaultModel : (Msg -> msg) -> Theme t -> Model t msg
defaultModel lift theme =
    { theme = theme
    , lift = lift
    , textfield = Dict.empty
    , icon = Dict.empty
    }
