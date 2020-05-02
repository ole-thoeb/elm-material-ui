module MaterialUI.ColorStateList exposing
    ( ColorStateList
    , State(..)
    , StateColor(..)
    , all
    , color
    , defaultBackgroundOnBackground
    , get
    , toElementColor
    , transparent
    )

import Element
import MaterialUI.Theme as Theme exposing (Theme)


type alias ColorStateList a =
    { idle : StateColor a
    , hovered : StateColor a
    , focused : StateColor a
    , mouseDown : StateColor a
    , disabled : StateColor a
    }


type StateColor a
    = Color Float (Theme.Color a)


type State
    = Idle
    | Hovered
    | Focused
    | MouseDown
    | Disabled


toElementColor : Theme a -> StateColor a -> Element.Color
toElementColor theme (Color alpha c) =
    Theme.getColor c theme
        |> Theme.setAlpha alpha


get : State -> ColorStateList a -> StateColor a
get state colorStateList =
    case state of
        Idle ->
            colorStateList.idle

        Hovered ->
            colorStateList.hovered

        Focused ->
            colorStateList.focused

        MouseDown ->
            colorStateList.mouseDown

        Disabled ->
            colorStateList.disabled


color : ColorStateList a -> Theme a -> State -> Element.Color
color colorStateList theme state =
    get state colorStateList
        |> toElementColor theme



-- DEFAULTS


transparent : StateColor a
transparent =
    Color 0 Theme.Primary


all : StateColor a -> ColorStateList a
all singleColor =
    { idle = singleColor
    , hovered = singleColor
    , focused = singleColor
    , mouseDown = singleColor
    , disabled = singleColor
    }


defaultBackgroundOnBackground : ColorStateList a
defaultBackgroundOnBackground =
    { idle = transparent
    , hovered = Color 0.1 Theme.OnBackground
    , focused = Color 0.15 Theme.OnBackground
    , mouseDown = Color 0.2 Theme.OnBackground
    , disabled = transparent
    }