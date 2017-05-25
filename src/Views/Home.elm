module Views.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, Options, defaultOptions)
import Json.Decode as Json

import Views.Article exposing (articlePreview)

import Utils exposing (..)
import Data.Article exposing (..)
import Data.Msg exposing (Msg(FilterTag))
import Data.User exposing (User)

paginationItem : Int -> Html Msg
paginationItem page =
    li [class "page-item"] -- TODO : Add class "active" to the current page
       [a [class "page-link"]
          [text (toString page)]]

pagination : Int -> Html Msg
pagination l =
    (nav [] 
        [ul [class "pagination"]
            ((List.range 1 l)
            |> (List.map paginationItem))])

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
                , (List.concat 
                    [ (List.map articlePreview articles.articles)
                    , [pagination (articles.articlesCount // 20)]]) -- TODO : Can paginations be changed?
                |> div []
                ]
            , div [ class "col-md-3" ]
                [ div [ class "sidebar" ]
                    [ p []
                        [ text "Popular Tags" ]
                    , div [ class "tag-list" ]
                        (List.map 
                            (\tag -> 
                                a [ class "tag-pill tag-default", href "", onNoBubbleClick (FilterTag tag)]
                                  [ text tag ]) tags)
                    ]
                ]
            ]
        ]
    ]