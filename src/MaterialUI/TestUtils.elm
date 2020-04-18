module MaterialUI.TestUtils exposing
    ( ThemeList
    , booleanStory
    , colorStory
    , labelStory
    , onPressStory
    , render
    , themeStory
    , wrapView
    )

import Bibliopola exposing (IntoBook, Story, addStory)
import Bibliopola.Story as Story
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import MaterialUI.Theme as Theme exposing (Theme)
import MaterialUI.Themes.Default as DefaultTheme


type alias ThemeList a =
    List ( String, Theme a )


onPressStory : String -> Story (Maybe String)
onPressStory name =
    Story "onPress" []
        |> Story.addOption "Something" (Just <| name ++ " pressed")
        |> Story.addOption "Nothing" Nothing


booleanStory : String -> Bool -> Story Bool
booleanStory name defaultValue =
    Story name <|
        if defaultValue then
            [ ( "True", True )
            , ( "False", False )
            ]

        else
            [ ( "False", False )
            , ( "True", True )
            ]


colorStory : Story (Theme.Color a)
colorStory =
    Story "Color" []
        |> Story.addOption "OnError" Theme.OnError
        |> Story.addOption "OnSurface" Theme.OnSurface
        |> Story.addOption "OnBackground" Theme.OnBackground
        |> Story.addOption "OnSecondaryVariant" Theme.OnSecondaryVariant
        |> Story.addOption "OnSecondary" Theme.OnSecondary
        |> Story.addOption "OnPrimaryVariant" Theme.OnPrimaryVariant
        |> Story.addOption "OnPrimary" Theme.OnPrimary
        |> Story.addOption "Error" Theme.Error
        |> Story.addOption "Surface" Theme.Surface
        |> Story.addOption "Background" Theme.Background
        |> Story.addOption "SecondaryVariant" Theme.SecondaryVariant
        |> Story.addOption "Secondary" Theme.Secondary
        |> Story.addOption "PrimaryVariant" Theme.PrimaryVariant
        |> Story.addOption "Primary" Theme.Primary


themeStory : ThemeList a -> Story (Theme a)
themeStory themes =
    List.foldr
        (\( name, theme ) ->
            Story.addOption name theme
        )
        (Story "Theme" [])
        themes
        |> Story.addOption "Default" DefaultTheme.light


labelStory : Story String
labelStory =
    Story "Label"
        [ ( "Label", "Label" )
        , ( "Longer_label", "Longer label" )
        ]


wrapView theme view =
    Element.el
        ([ Element.width Element.fill
         , Element.height Element.fill
         , Background.color theme.color.background
         , Font.color theme.color.onBackground
         ]
            ++ Theme.fontToAttributes theme.typescale.body1
        )
        (Element.el
            [ Element.centerX
            , Element.centerY
            ]
            view
        )


render : Theme b -> (Theme b -> Element msg) -> Element msg
render theme view =
    view theme
        |> wrapView theme
