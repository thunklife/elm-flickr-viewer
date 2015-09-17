import StartApp
import Task
import Html
import Effects exposing (Never)

import FlickrViewer exposing (..)

app = StartApp.start
      { init = init ""
      , update = update
      , view = view
      , inputs = []
      }


main : Signal Html.Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


