module MaterialUI.Snackbar exposing
    ( Snackbar
    , view
    , enqueue
    , set
    , enqueueFirst
    , short
    , long
    , leading
    , centered
    , keepCurrent, dismissCurrent)

import Element exposing (Element)
import MaterialUI.Internal.Component exposing (Index)
import MaterialUI.Internal.Snackbar.Implementation as Snackbar
import MaterialUI.Internal.Snackbar.Model as Snackbar
import MaterialUI.MaterilaUI as MaterialUI


type alias Snackbar a msg = Snackbar.Content a msg


view : MaterialUI.Model a msg
    -> Index
    -> Element msg
view =
    Snackbar.view


add : MaterialUI.Model a msg
    -> Index
    -> Snackbar a msg
    -> (Snackbar a msg -> List (Snackbar a msg) -> List (Snackbar a msg))
    -> Snackbar.AddBehaviour
    -> ( MaterialUI.Model a msg, Cmd msg )
add =
    Snackbar.add


enqueue : Snackbar a msg -> Index -> MaterialUI.Model a msg -> ( MaterialUI.Model a msg, Cmd msg )
enqueue snackbar index mui =
    add mui index snackbar (\c list -> list ++ [ c ]) keepCurrent


set : Snackbar a msg -> Index -> MaterialUI.Model a msg -> ( MaterialUI.Model a msg, Cmd msg )
set snackbar index mui =
    add mui index snackbar (\c _ -> [ c ]) dismissCurrent


enqueueFirst : Snackbar a msg -> Index -> MaterialUI.Model a msg -> ( MaterialUI.Model a msg, Cmd msg )
enqueueFirst snackbar index mui =
    add mui index snackbar (::) keepCurrent

keepCurrent : Snackbar.AddBehaviour
keepCurrent =
    Snackbar.KeepCurrent


dismissCurrent : Snackbar.AddBehaviour
dismissCurrent =
    Snackbar.DismissCurrent


short : Snackbar.Duration
short =
    Snackbar.Short


long : Snackbar.Duration
long =
    Snackbar.Long


leading : Snackbar.Position
leading =
    Snackbar.Leading


centered : Snackbar.Position
centered =
    Snackbar.Centered