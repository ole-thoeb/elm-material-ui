module MaterialUI.Tooltip exposing (..)


import Element exposing (Element)
import MaterialUI.Internal.Tooltip.Implementation as Tooltip
import MaterialUI.Internal.Tooltip.Model as Tooltip
import MaterialUI.MaterilaUI as MaterialUI


type alias Tooltip = Tooltip.Tooltip


view : MaterialUI.Model a msg
    -> List (Element.Attribute msg)
    -> Tooltip
    -> Element msg
    -> Element msg
view =
    Tooltip.view


left : Tooltip.Position
left =
    Tooltip.Left


right : Tooltip.Position
right =
    Tooltip.Right


top : Tooltip.Position
top =
    Tooltip.Top


bottom : Tooltip.Position
bottom =
    Tooltip.Bottom