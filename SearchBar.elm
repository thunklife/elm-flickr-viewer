module SearchBar where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)

-- Model

type alias Model =
  { searchTerm : String
  , results : List String
  }

-- UPDATE
type Action = SearchTerm String | RunSearch

update : Action -> Model -> Model
update action model =
  case action of
    RunSearch ->
      { model | searchTerm <- model.searchTerm ++ " Searching" }
    SearchTerm term ->
      { model | searchTerm <- term }

-- VIEW

view : Address Action -> Model -> Html
view address model =
  div []
        [ input [ id "search"
                , placeholder "Search"
                , on "input" targetValue (\s -> message address (SearchTerm s))
                ]
                []
        , button [ id "runSearch"
                 , onClick address RunSearch
                 ]
          [ text "Search" ]
        , p [] [ text model.searchTerm ]
        ]
