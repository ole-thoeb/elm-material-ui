module MaterialUI.Themes.Default exposing
    ( light
    , dark
    , typescale
    )


import Element.Font
import MaterialUI.Theme exposing (..)
import Element
import Color


light : Theme a
light =
    { color =
        { primary = Element.rgb255 98 0 238 -- #6200EE
        , primaryVariant = Element.rgb255 54 0 179
        , secondary = Element.rgb255 3 218 198 -- #03DAC6
        , secondaryVariant = Element.rgb255 1 135 134 -- #018786
        , background = toElementColor Color.white
        , surface = toElementColor Color.white
        , tooltip = Element.rgb255 97 97 97 -- #FF616161
        , error = Element.rgb255 176 0 32 -- #B00020
        , onPrimary = toElementColor Color.white
        , onPrimaryVariant = toElementColor Color.white
        , onSecondary = toElementColor Color.black
        , onSecondaryVariant = toElementColor Color.white
        , onBackground = toElementColor Color.black
        , onSurface = toElementColor Color.black
        , onTooltip = toElementColor Color.white
        , onError = toElementColor Color.white
        , alternative = []
        }
    , shape =
        { button = shapeRoundedDp 4
        , card = shapeRoundedDp 4
        , textField =
            { filled = shapeRoundedDpEach 4 4 0 0
            , outlined = shapeRoundedDp 4
            }
        , tooltip = shapeRoundedDp 4
        }
    , typescale = typescale
    , variant = LightVariant (\_ -> dark)
    }


dark : Theme a
dark =
    let
        color =
            light.color
    in
    { light
        | color =
            { color
                | primary = Element.rgb255 187 134 252 -- #BB86FC
                , secondaryVariant = Element.rgb255 3 218 198 -- #03DAC6
                , background = Element.rgb255 18 18 18 -- #121212
                , surface = Element.rgb255 18 18 18 -- #121212
                , tooltip = Element.rgb255 227 227 227 -- #FFE3E3E3
                , error = Element.rgb255 207 102 121 -- #cf6679
                , onPrimary = toElementColor Color.black
                , onSecondaryVariant = toElementColor Color.black
                , onBackground = toElementColor Color.white
                , onSurface = toElementColor Color.white
                , onTooltip = toElementColor Color.black
                , onError = toElementColor Color.black
                , alternative = []
            }
        , variant = DarkVariant (\_ -> light)
    }



typescale : Typescale
typescale =
    { h1 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Light
        , size = 96
        , fontcase = Sentence
        , letterSpacing = -1.5
        }
    , h2 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Light
        , size = 60
        , fontcase = Sentence
        , letterSpacing = -0.5
        }
    , h3 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 48
        , fontcase = Sentence
        , letterSpacing = 0
        }
    , h4 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 34
        , fontcase = Sentence
        , letterSpacing = 0.25
        }
    , h5 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 24
        , fontcase = Sentence
        , letterSpacing = 0
        }
    , h6 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Medium
        , size = 20
        , fontcase = Sentence
        , letterSpacing = 0.15
        }
    , subtitle1 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 16
        , fontcase = Sentence
        , letterSpacing = 0.15
        }
    , subtitle2 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Medium
        , size = 14
        , fontcase = Sentence
        , letterSpacing = 0.1
        }
    , body1 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 16
        , fontcase = Sentence
        , letterSpacing = 0.5
        }
    , body2 =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 14
        , fontcase = Sentence
        , letterSpacing = 0.25
        }
    , button =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Medium
        , size = 14
        , fontcase = AllCaps
        , letterSpacing = 1.25
        }
    , caption =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 12
        , fontcase = Sentence
        , letterSpacing = 0.4
        }
    , overline =
        { typeface = [ Element.Font.typeface "Roboto" ]
        , weight = Regular
        , size = 10
        , fontcase = AllCaps
        , letterSpacing = 1.5
        }
    }
