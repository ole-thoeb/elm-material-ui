module Examples.Form exposing (main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as EInput
import Form exposing (Form)
import Form.Validate as Validate exposing (Validation)
import Html exposing (Html)
import MaterialUI.Button as Button
import MaterialUI.ElmFormInput as Input
import MaterialUI.Radio as Radio
import MaterialUI.TextField as TextField
import MaterialUI.Theme as Theme exposing (Theme)
import MaterialUI.Themes.Dark as Dark



-- your expected form output


type alias Foo =
    { bar : String
    , baz : String
    }



-- Add form to your model and msgs


type alias Model =
    { form : Form () Foo
    , theme : Theme ()
    }


type Msg
    = NoOp
    | FormMsg Form.Msg



-- Setup form validation


init : Model
init =
    { form = Form.initial [] validate
    , theme = Dark.theme
    }


validate : Validation () Foo
validate =
    Validate.succeed Foo
        |> Validate.andMap (Validate.field "bar" Validate.email)
        |> Validate.andMap (Validate.field "baz" Validate.string)



-- Forward form msgs to Form.update


update : Msg -> Model -> Model
update msg ({ form } as model) =
    case msg of
        NoOp ->
            model

        FormMsg formMsg ->
            { model | form = Form.update validate formMsg form }



-- Render form with Input helpers


formView : Form () Foo -> Theme a -> Element Form.Msg
formView form theme =
    let
        bar =
            Form.getFieldAsString "bar" form

        baz =
            Form.getFieldAsString "baz" form
    in
    Element.column []
        [ Input.textInput Debug.toString
            bar
            []
            { label = "Bar"
            , hideLabel = False
            , type_ = TextField.Outlined
            , color = Theme.Primary
            , helperText = Just "Type a value for 'bar'"
            , disabled = False
            }
            theme
        , Element.el [] <|
            Input.radioInput
                Debug.toString
                baz
                [ Element.padding 10
                , Element.spacing 20
                ]
                { label = "Lunch"
                , hideLabel = False
                , color = Theme.Primary
                , options =
                    [ Radio.option "A" "Taco!"
                    , Radio.option "B" "Gyro"
                    ]
                }
                theme
        , Button.contained
            { text = "Submit"
            , color = Theme.Primary
            , icon = Nothing
            , onPress = Just Form.Submit
            , disabled = Form.getOutput form == Nothing
            }
            theme
        ]


layout : Model -> Theme a -> Element Msg
layout model theme =
    Element.el
        [ Element.centerX
        , Element.centerY
        ]
        (Element.map FormMsg (formView model.form model.theme))


view : Model -> Html Msg
view model =
    Element.layout
        [ Background.color model.theme.color.background
        , Font.color model.theme.color.onBackground
        ]
    <|
        layout model model.theme


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }
