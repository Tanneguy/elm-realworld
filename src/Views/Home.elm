module Views.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Views.Article exposing (articlePreview)

import Data.Article exposing (..)
import Data.Msg exposing (Msg)
import Data.User exposing (User)

home : Maybe User -> Articles -> List String -> Html Msg
home user articles tags = 
  div [ class "home-page" ]
    [ div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ]
                [ text "conduit" ]
            , p []
                [ text "A place to share your knowledge." ]
            ]
        ]
    , div [ class "container page" ]
        [ div [ class "row" ]
            [ div [ class "col-md-9" ]
                [ div [ class "feed-toggle" ]
                    [ ul [ class "nav nav-pills outline-active" ]
                        [ li 
                            [ class "nav-item"
                            , style
                                (case user of
                                    Just m ->
                                        [] 
                                    Nothing ->
                                        [("display","none")])]
                            [ a [ class "nav-link disabled", href "" ]
                                [ text "Your Feed" ]
                            ]
                        , li [ class "nav-item" ]
                            [ a [ class "nav-link active", href "" ]
                                [ text "Global Feed" ]
                            ]
                        ]
                    ]
                , (List.map articlePreview articles.articles) |> div []
                ]
            , div [ class "col-md-3" ]
                [ div [ class "sidebar" ]
                    [ p []
                        [ text "Popular Tags" ]
                    , div [ class "tag-list" ]
                        (List.map 
                            (\tag -> 
                                a [ class "tag-pill tag-default", href "" ]
                                  [ text tag ]) tags)
                    ]
                ]
            ]
        ]
    ]