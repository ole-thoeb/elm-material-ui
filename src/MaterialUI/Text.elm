module MaterialUI.Text exposing (view)

import Element exposing (..)
import MaterialUI.Theme as Theme

view : List (Element.Attribute msg) -> String -> Theme.Fontscale -> Theme.Theme a ->  Element msg
view attr displayStr fontscale theme =
    let
        font = Theme.getFont fontscale theme
    in
    el (attr ++ Theme.fontToAttributes font)
        (text <| Theme.applyCase font.fontcase displayStr)