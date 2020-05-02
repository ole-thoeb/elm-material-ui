module MaterialUI.Select exposing (Menu, defaultColorPrimary, item, outlined)

import Element exposing (Element)
import MaterialUI.ColorStateList as ColorStateList exposing (ColorStateList)
import MaterialUI.Internal.Select.Implementation as Select
import MaterialUI.Internal.Select.Model as Select
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.Theme as Theme


type alias Menu a item msg =
    Select.Menu a item msg


outlined :
    MaterialUI.Model a msg
    -> List (Element.Attribute msg)
    -> Menu a item msg
    -> Element msg
outlined =
    Select.outlined


item : item -> Select.Item item
item =
    Select.Item


defaultColorPrimary : ColorStateList a
defaultColorPrimary =
    { idle = ColorStateList.Color 0.3 Theme.OnSurface
    , hovered = ColorStateList.Color 0.6 Theme.OnSurface
    , focused = ColorStateList.Color 1 Theme.Primary
    , mouseDown = ColorStateList.Color 1 Theme.Primary
    , disabled = ColorStateList.Color 0.3 Theme.OnSurface
    }
