module MaterialUI.Theme exposing
    ( Color(..)
    , ColorTheme
    , Shape(..)
    , ShapeSchema
    , Size(..)
    , Theme
    , addLightness
    , applyCase
    , fontToAttributes
    , getColor
    , getOnColor
    , onColor
    , setAlpha
    , shapeToAttributes
    , toElementColor
    , transparent
    , getFont
    , Fontscale(..)
    , shapeRoundedDpEach
    , shapeRoundedDp
    , FontCase(..)
    , FontWeight(..)
    , Font
    , Typescale
    , Variant(..)
    , inverted
    , isDark
    , isLight
    )

import Color
import Element exposing (Attribute, Element)
import Element.Border
import Element.Font


transparent : Element.Color
transparent =
    Element.rgba255 0 0 0 0


toElementColor : Color.Color -> Element.Color
toElementColor color =
    Color.toRgba color
        |> Element.fromRgb


setAlpha : Float -> Element.Color -> Element.Color
setAlpha value color =
    let
        rgb =
            Element.toRgb color
    in
    Element.fromRgb
        { rgb | alpha = value }


addLightness : Float -> Element.Color -> Element.Color
addLightness value color =
    let
        hsl =
            Element.toRgb color |> Color.fromRgba |> Color.toHsla
    in
    Color.fromHsla
        { hsl | lightness = min 1.0 (hsl.lightness + value) }
        |> Color.toRgba
        |> Element.fromRgb


type alias Theme a =
    { color : ColorTheme a
    , shape : ShapeSchema
    , typescale : Typescale
    , variant : Variant a
    }


type Variant a
    = LightVariant (() -> Theme a)
    | DarkVariant (() -> Theme a)


inverted : Theme a -> Theme a
inverted theme =
    case theme.variant of
        LightVariant inverted_ -> inverted_ ()
        DarkVariant inverted_ -> inverted_ ()


isDark : Theme a -> Bool
isDark theme =
    case theme.variant of
        DarkVariant _ -> True
        LightVariant _ -> False


isLight : Theme a -> Bool
isLight theme =
    case theme.variant of
        DarkVariant _ -> False
        LightVariant _ -> True


type Color a
    = Primary
    | OnPrimary
    | PrimaryVariant
    | OnPrimaryVariant
    | Secondary
    | OnSecondary
    | SecondaryVariant
    | OnSecondaryVariant
    | Background
    | OnBackground
    | Surface
    | OnSurface
    | Tooltip
    | OnTooltip
    | Error
    | OnError
    | Custom Element.Color
    | Alternative a


type alias ColorTheme a =
    { primary : Element.Color
    , primaryVariant : Element.Color
    , secondary : Element.Color
    , secondaryVariant : Element.Color
    , background : Element.Color
    , surface : Element.Color
    , tooltip : Element.Color
    , error : Element.Color
    , onPrimary : Element.Color
    , onPrimaryVariant : Element.Color
    , onSecondary : Element.Color
    , onSecondaryVariant : Element.Color
    , onBackground : Element.Color
    , onSurface : Element.Color
    , onTooltip : Element.Color
    , onError : Element.Color
    , alternative : List ( a, Element.Color )
    }


onColor : Color a -> Color a
onColor key =
    case key of
        Primary ->
            OnPrimary

        PrimaryVariant ->
            OnPrimaryVariant

        OnPrimary ->
            Primary

        OnPrimaryVariant ->
            PrimaryVariant

        Secondary ->
            OnSecondary

        SecondaryVariant ->
            OnSecondaryVariant

        OnSecondary ->
            Secondary

        OnSecondaryVariant ->
            SecondaryVariant

        Background ->
            OnBackground

        OnBackground ->
            Background

        Surface ->
            OnSurface

        OnSurface ->
            Surface

        Tooltip ->
            OnTooltip

        OnTooltip ->
            Tooltip

        Error ->
            OnError

        OnError ->
            Error

        Custom color ->
            OnSurface

        Alternative a ->
            Alternative a



-- TODO Alternative colors should always provide a "on" color


getColor : Color a -> Theme a -> Element.Color
getColor key { color } =
    case key of
        Primary ->
            color.primary

        PrimaryVariant ->
            color.primaryVariant

        OnPrimary ->
            color.onPrimary

        OnPrimaryVariant ->
            color.onPrimaryVariant

        Secondary ->
            color.secondary

        SecondaryVariant ->
            color.secondaryVariant

        OnSecondary ->
            color.onSecondary

        OnSecondaryVariant ->
            color.onSecondaryVariant

        Background ->
            color.background

        OnBackground ->
            color.onBackground

        Surface ->
            color.surface

        OnSurface ->
            color.onSurface

        Tooltip ->
            color.tooltip

        OnTooltip ->
            color.onTooltip

        Error ->
            color.error

        OnError ->
            color.onError

        Custom c ->
            c

        Alternative a ->
            List.filterMap
                (\( akey, ecolor ) ->
                    if akey == a then
                        Just ecolor

                    else
                        Nothing
                )
                color.alternative
                |> List.head
                |> Maybe.withDefault color.primary


getOnColor : Color a -> Theme a -> Element.Color
getOnColor =
    onColor >> getColor


type Size
    = Dp Int
    | Ratio Float


sizeToPixels : Int -> Int -> Size -> Int
sizeToPixels width height size =
    case size of
        Dp value ->
            value

        Ratio ratio ->
            round <|
                toFloat (min width height)
                    * ratio


type Shape
    = Rounded Size Size Size Size


shapeToAttributes : Int -> Int -> Shape -> List (Attribute msg)
shapeToAttributes width height (Rounded topLeft topRight bottomRight bottomLeft) =
    let
        toPixels =
            sizeToPixels width height

        corners =
            { topLeft = toPixels topLeft
            , topRight = toPixels topRight
            , bottomRight = toPixels bottomRight
            , bottomLeft = toPixels bottomLeft
            }
    in
    [ Element.Border.roundEach corners
    ]


type alias ShapeSchema =
    { button : Shape
    , card : Shape
    , textField :
        { filled : Shape
        , outlined : Shape
        }
    , tooltip : Shape
    }


shapeRoundedDpEach : Int -> Int -> Int -> Int -> Shape
shapeRoundedDpEach topLeft topRight bottomRight bottomLeft =
    Rounded (Dp topLeft) (Dp topRight) (Dp bottomRight) (Dp bottomLeft)


shapeRoundedDp : Int -> Shape
shapeRoundedDp size =
    shapeRoundedDpEach size size size size


type FontCase
    = Sentence
    | AllCaps


type FontWeight
    = Heavy
    | ExtraBold
    | Bold
    | SemiBold
    | Medium
    | Regular
    | Light
    | ExtraLight
    | Hairline


type alias Font =
    { typeface : List Element.Font.Font
    , weight : FontWeight
    , size : Int
    , fontcase : FontCase
    , letterSpacing : Float
    }


fontWeightToAttribute : FontWeight -> Element.Attribute msg
fontWeightToAttribute fw =
    case fw of
        Heavy ->
            Element.Font.heavy

        ExtraBold ->
            Element.Font.extraBold

        Bold ->
            Element.Font.bold

        SemiBold ->
            Element.Font.semiBold

        Medium ->
            Element.Font.medium

        Regular ->
            Element.Font.regular

        Light ->
            Element.Font.light

        ExtraLight ->
            Element.Font.extraLight

        Hairline ->
            Element.Font.hairline


fontToAttributes : Font -> List (Element.Attribute msg)
fontToAttributes font =
    [ Element.Font.family font.typeface
    , fontWeightToAttribute font.weight
    , Element.Font.size font.size
    , Element.Font.letterSpacing font.letterSpacing
    ]


applyCase : FontCase -> String -> String
applyCase fontcase text =
    case fontcase of
        Sentence ->
            String.toUpper (String.left 1 text)
                ++ String.dropLeft 1 text

        AllCaps ->
            String.toUpper text


type Fontscale
    = H1
    | H2
    | H3
    | H4
    | H5
    | H6
    | Subtitle1
    | Subtitle2
    | Body1
    | Body2
    | Button
    | Caption
    | Overline


getFont : Fontscale -> Theme a -> Font
getFont fontScale { typescale } =
    case fontScale of
        H1 ->
            typescale.h1

        H2 ->
            typescale.h2

        H3 ->
            typescale.h3

        H4 ->
            typescale.h4

        H5 ->
            typescale.h5

        H6 ->
            typescale.h6

        Subtitle1 ->
            typescale.subtitle1

        Subtitle2 ->
            typescale.subtitle2

        Body1 ->
            typescale.body1

        Body2 ->
            typescale.body2

        Button ->
            typescale.button

        Caption ->
            typescale.caption

        Overline ->
            typescale.overline


type alias Typescale =
    { h1 : Font
    , h2 : Font
    , h3 : Font
    , h4 : Font
    , h5 : Font
    , h6 : Font
    , subtitle1 : Font
    , subtitle2 : Font
    , body1 : Font
    , body2 : Font
    , button : Font
    , caption : Font
    , overline : Font
    }