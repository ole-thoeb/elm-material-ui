module MaterialUI.Internal.Component exposing (Index, Indexed, getSet, update, GetSet, elementCss)


import Dict exposing (Dict)
import Element
import Html.Attributes as Attributes


type alias Index = String


type alias Indexed a = Dict String a


type alias GetSet store model =
    { get : Index -> store -> model
    , set : Index -> model -> store -> store
    }

getSet : (store -> Indexed model)
    -> (Indexed model -> store -> store)
    -> model
    -> GetSet store model
getSet getModel setModel default =
    { get = \index store -> Dict.get index (getModel store) |> Maybe.withDefault default
    , set = \index model store -> setModel (Dict.insert index model (getModel store)) store
    }


update : GetSet store model -> (msg -> model -> model) -> msg -> Index -> store -> store
update get_set update_ msg index  store =
    let
        model = get_set.get index store
        updatedModel = update_ msg model
    in
    get_set.set index updatedModel store


elementCss : String -> String -> Element.Attribute msg
elementCss property value =
    Element.htmlAttribute <| Attributes.style property value