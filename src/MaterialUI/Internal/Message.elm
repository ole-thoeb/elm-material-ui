module MaterialUI.Internal.Message exposing (Msg(..))

import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Internal.Icon.Model as Icon
import MaterialUI.Internal.TextField.Model as TextField


type Msg
    = TextFieldMsg Index TextField.Msg
    | IconMsg Index Icon.Msg