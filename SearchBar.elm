module SearchBar where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

-- Model

type alias Model =
  { searchTerm : String
  , results : List Photo
  }

type alias Photo =
  { id : String
  , farm : Int
  , owner : String
  , secret : String
  , server : String
  , title : String
  , username : String
  }

init : String -> (Model, Effects Action)
init term =
  (Model term []
  , getImages term
  )

-- UPDATE
type Action = ReturnResults (Maybe (List Photo)) | SearchTerm String | RunSearch

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RunSearch ->
      (model, getImages model.searchTerm)
    SearchTerm term ->
      (Model term model.results, Effects.none)
    ReturnResults maybeUrls ->
      (Model model.searchTerm (Maybe.withDefault model.results maybeUrls), Effects.none)

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
        ]

getImages : String -> Effects Action
getImages searchTerm =
  Http.get decodeResponse (flickrUrl searchTerm)
      |> Task.toMaybe
      |> Task.map ReturnResults
      |> Effects.task

decodeResponse : Json.Decoder (List Photo)
decodeResponse =
  Json.at ["photos", "photo"] (Json.list photo)


photo : Json.Decoder Photo
photo =
  Json.object7 Photo
  ("id" := Json.string)
  ("farm" := Json.int)
  ("owner" := Json.string)
  ("secret" := Json.string)
  ("server" := Json.string)
  ("title" := Json.string)
  ("username" := Json.string)

flickrUrl : String -> String
flickrUrl term =
  Http.url "https://api.flickr.com/services/rest/"
        [ ("api_key","934910a2c34c06b6b167e1589069c274")
        , ("method", "flickr.tags.getClusterPhotos")
        , ("tag", term)
        , ("format", "json")
        , ("nojsoncallcall", "1")
        ]
