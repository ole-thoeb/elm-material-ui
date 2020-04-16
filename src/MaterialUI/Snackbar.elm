module MaterialUI.Snackbar exposing
    ( Snackbar
    , view
    , enqueue
    , short
    , long
    , leading
    , centered
    )

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


enqueue : Snackbar a msg -> Index -> MaterialUI.Model a msg -> ( MaterialUI.Model a msg, Cmd msg )
enqueue =
    Snackbar.enqueue


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