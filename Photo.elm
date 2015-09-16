module Photo where

type alias Photo =
  { id : String
  , farm : Int
  , owner : String
  , secret : String
  , server : String
  , title : String
  , username : String
  }

thumbnailUrl : Photo -> String
thumbnailUrl = baseUrl >> (flip (++)) "_s.jpg"

fullSizeUrl : Photo -> String
fullSizeUrl = baseUrl >> (flip (++)) "_z.jpg"

baseUrl : Photo -> String
baseUrl photo =
  "http://farm" ++ (toString photo.farm) ++ ".staticflickr.com/" ++ photo.server ++ "/" ++ photo.id ++ "_" ++ photo.secret

