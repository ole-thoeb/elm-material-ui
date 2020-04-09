module MaterialUI.TextFieldM exposing (TextField, text, managed, ManagedTextField)

import Element exposing (Attribute, Element)
import MaterialUI.Internal.TextField.Implementation as ManagedImpl
import MaterialUI.Internal.TextField.Model as TextFieldModel
import MaterialUI.MaterilaUI as MaterialUI
import MaterialUI.Theme exposing (Theme)


type alias TextField a msg = TextFieldModel.TextField a msg


type alias ManagedTextField a msg = TextFieldModel.TextFieldManged a msg


text : List (Attribute msg) -> TextField a msg -> Theme a -> Element msg
text =
    ManagedImpl.text


managed : MaterialUI.Model a msg -> List (Attribute msg) -> ManagedTextField a msg -> Element msg
managed =
    ManagedImpl.view
