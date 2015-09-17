module FlickrViewer where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

import Photo exposing (..)

-- MODEL

type alias Model =
  { searchTerm : String
  , results : List Photo
  , selectedImage : Photo
  , hasPhoto : Bool
  }

-- INIT

init : String -> (Model, Effects Action)
init term =
  ( Model term [] emptyPhoto False, Effects.none)


-- ACTION

type Action =
  SearchTerm String
  | RunSearch
  | ReturnResults (Maybe (List Photo))
  | LoadFull Photo

-- UPDATE

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RunSearch ->
      (model, getPhotos model.searchTerm)
    SearchTerm term ->
      (Model term model.results emptyPhoto False, Effects.none)
    ReturnResults maybeUrls ->
      (Model model.searchTerm (Maybe.withDefault model.results maybeUrls) emptyPhoto False, Effects.none)
    LoadFull photo ->
      (Model model.searchTerm model.results photo True, Effects.none)


-- VIEW

view : Address Action -> Model -> Html
view address model =
  div
    [ class "mui-container"]
    [ h1
        []
        [ text "Elm Flicker Viewer" ]
    , div
        [ class "mui-panel"]
        [ div
            [  ]
            [ Html.form
              [ onSubmit address RunSearch
              , action "javascript:none"
              ,class"mui-form-inline mui-form-group"
              ]
              [ input
                  [ id "search"
                  , on "input" targetValue (\s -> message address (SearchTerm s))
                  , class "mui-form-control"
                  , placeholder "Search"
                  ]
                  []
              , button
                  [ id "runSearch"
                  , class "mui-btn mui-btn-primary"
                  , type' "submit"
                  ]
                  [ text "Search" ]
              ]
            ]
        , div
            []
            [ div
                [ class "mui-row" ]
                [ div
                    [ class "mui-col-md-8" ]
                    [ img
                        [ src (fullSizeUrl model.selectedImage)
                        , classList [ ("show", model.hasPhoto) ]
                        , id "fullSize"
                        ]
                        []
                    ]
                , div
                    [ id "thumbs"
                    , class "mui-col-md-4"
                    ]
                    (List.map (thumbnailLink address) model.results)
                ]
            ]
          ]
      ]

thumbnailLink : Address Action -> Photo -> Html
thumbnailLink address photo =
  a [ onClick address (LoadFull photo) ]
    [ img [src (thumbnailUrl photo)] [] ]

--

getPhotos : String -> Effects Action
getPhotos searchTerm =
  Http.get decodeResponse (flickrUrl searchTerm)
      |> Task.toMaybe
      |> Task.map ReturnResults
      |> Effects.task

decodeResponse : Json.Decoder (List Photo)
decodeResponse =
  Json.at ["photos", "photo"] (Json.list photoDecoder)


photoDecoder : Json.Decoder Photo
photoDecoder =
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
        , ("nojsoncallback", "1")
        ]

emptyPhoto : Photo
emptyPhoto = Photo "" 0 "" "" "" "" ""
