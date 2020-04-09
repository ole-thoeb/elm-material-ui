module MaterialUI.Managed.Manager exposing (Msg, Indexed, Index, Manager, create)


import Dict exposing (Dict)
import MaterialUI.Theme exposing (Theme)
import MaterialUI.Managed.Internal.Textfield.Model as Textfield

type alias Index = String


type alias Indexed a = Dict String a


type alias Manager t model msg =
    { theme : Theme t
    , lift : Msg -> msg
    , textfield : Indexed Textfield.Model
    }


type Msg
    = NoOp


create : (Msg -> msg) -> Theme t -> Manager t model msg
create lift theme =
    { theme = theme
    , lift = lift
    , textfield = Dict.empty
    }
