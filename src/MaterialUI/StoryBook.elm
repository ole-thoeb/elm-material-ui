module MaterialUI.StoryBook exposing (shelf)

import Bibliopola exposing (Program, Shelf, addBook, addShelf)
import MaterialUI.ButtonRowTest
import MaterialUI.ButtonTest
import MaterialUI.CardTest
import MaterialUI.RadioTest
import MaterialUI.TabsTest
import MaterialUI.TextFieldTest
import MaterialUI.Theme exposing (Theme)
import MaterialUI.Themes.Default as DefaultTheme


shelf : List ( String, Theme a ) -> Shelf
shelf themes =
    Bibliopola.emptyShelf "MaterialUI"
        |> addShelf
            (Bibliopola.emptyShelf "Components"
                |> addBook (MaterialUI.TabsTest.book themes)
            )
        |> addShelf
            (Bibliopola.emptyShelf "Inputs"
                |> addShelf (MaterialUI.ButtonTest.shelf themes)
                |> addShelf (MaterialUI.TextFieldTest.shelf themes)
                |> addBook (MaterialUI.RadioTest.book themes)
            )
        |> addShelf
            (Bibliopola.emptyShelf "Containers"
                |> addBook (MaterialUI.CardTest.book themes)
                |> addBook (MaterialUI.ButtonRowTest.book themes)
            )


main : Program
main =
    shelf
        [ ( "Dark", DefaultTheme.dark )
        ]
        |> Bibliopola.fromShelf
