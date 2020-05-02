module MaterialUI.Internal.Select.Model exposing
    ( Item(..)
    , Menu
    , MenuItem
    , MenuItemModel
    , Model
    , Msg(..)
    , Status(..)
    , defaultMenuItemModel
    , defaultModel
    )

import Dict
import MaterialUI.ColorStateList exposing (ColorStateList)
import MaterialUI.Internal.Component exposing (Index, Indexed)
import MaterialUI.Internal.State as State


type alias Menu a item msg =
    { index : Index
    , color : ColorStateList a
    , toItem : item -> MenuItem
    , items : List (Item item)
    , selectedItem : Maybe item
    , onClick : item -> msg
    , label : String
    }


type alias MenuItem =
    { text : String
    }


type Item item
    = Item item


type alias Model =
    { status : Status
    , state : State.Model
    , menuItems : Indexed MenuItemModel
    }


type alias MenuItemModel =
    { state : State.Model
    }


defaultModel : Model
defaultModel =
    { status = Closed
    , state = State.defaultModel
    , menuItems = Dict.empty
    }


defaultMenuItemModel : MenuItemModel
defaultMenuItemModel =
    { state = State.defaultModel
    }


type Status
    = Closed
    | Open
    | Opening


type Msg
    = State State.Msg
    | ItemState Index State.Msg
    | Clicked
    | ForceClose
    | FullyOpened
