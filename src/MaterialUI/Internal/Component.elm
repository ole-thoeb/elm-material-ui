module MaterialUI.Internal.Component exposing (Index, Indexed)


import Dict exposing (Dict)


type alias Index = String


type alias Indexed a = Dict String a
