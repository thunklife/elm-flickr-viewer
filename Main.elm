import SearchBar exposing (update, view)
import StartApp.Simple exposing (start)

main = start {
         model = {searchTerm = "", results = []}
         , update = update
         , view = view
       }
