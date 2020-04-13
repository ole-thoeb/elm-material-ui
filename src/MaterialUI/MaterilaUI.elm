module MaterialUI.MaterilaUI exposing (Model, defaultModel, update, Msg, subscriptions)


import MaterialUI.Internal.Icon.Implementation as Icon
import MaterialUI.Internal.Message as Message
import MaterialUI.Internal.Model as Model
import MaterialUI.Internal.TextField.Implementation as Textfield
import MaterialUI.Internal.Tooltip.Implementation as Tooltip
import MaterialUI.Theme exposing (Theme)


type alias Model t msg = Model.Model t msg


type alias Msg = Message.Msg


defaultModel : (Msg -> msg) -> Theme t -> Model t msg
defaultModel =
    Model.defaultModel


update : Msg -> Model t msg -> Model t msg
update msg model =
    case msg of
        Message.TextFieldMsg index subMsg ->
            Textfield.update subMsg index model

        Message.IconMsg index subMsg ->
            Icon.update subMsg index model

        Message.TooltipMsg index subMsg ->
            Tooltip.update subMsg index model


subscriptions : Model t msg -> Sub msg
subscriptions model =
    Tooltip.subscriptions model