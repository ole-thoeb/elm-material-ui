module MaterialUI.Icon exposing (Icon, makeIcon, view, button)

import Element exposing (Element)
import MaterialUI.Icons.Internal as Internal
import MaterialUI.Internal.Icon.Implementation as Icon
import MaterialUI.Internal.Icon.Model as Icon
import MaterialUI.Internal.Model as MaterialUI
import MaterialUI.Theme as Theme exposing (Theme)


type alias Icon msg = Icon.Icon msg


type alias IconButton a msg = Icon.IconButton a msg


makeIcon : Internal.Icon msg -> Icon msg
makeIcon =
    Icon.makeIcon


view : Theme a -> Theme.Color a -> Int -> Icon msg -> Element msg
view =
    Icon.view


button : MaterialUI.Model a msg -> List (Element.Attribute msg) -> IconButton a msg -> Element msg
button =
    Icon.button