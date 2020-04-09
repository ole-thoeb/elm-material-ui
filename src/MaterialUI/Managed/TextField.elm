module MaterialUI.Managed.TextField exposing (TextField)


import Dict
import Element exposing (Element)
import MaterialUI.Managed.Manager exposing (Index, Manager)
import MaterialUI.TextField as TextField
import MaterialUI.Managed.Internal.Textfield.Model as TextField
import MaterialUI.Theme as Theme


type alias TextField a msg =
    { index : Index
    , label : String
    , hideLabel : Bool
    , type_ : TextField.Type
    , color : Theme.Color a
    , text : String
    , onChange : String -> msg
    , errorText : Maybe String
    , helperText : Maybe String
    }


view : Manager a msg model -> List (Element.Attribute msg) -> TextField a msg -> Element msg
view mui attr textField =
    let
        model = Maybe.withDefault TextField.defaultModel (Dict.get textField.index mui.textfield)
        state = if (model.focused) then TextField.Focused else TextField.Idle
    in
    TextField.text attr
        { label = textField.label
        , hideLabel = textField.hideLabel
        , type_ = textField.type_
        , color = textField.color
        , text = textField.text
        , onChange = textField.onChange
        , state = state
        , errorText = textField.errorText
        , helperText = textField.helperText
        }
        mui.theme