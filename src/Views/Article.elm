module Views.Article exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Data.Article exposing (Article)
import Data.Profile exposing (Profile)
import Data.Comment exposing (Comment)

import Data.Msg exposing (Msg)

import Date.Format exposing (format)
import Date exposing (fromString)

import Markdown as Markdown

articlePreview : Article -> Html Msg
articlePreview article =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ href ("#/profile/" ++ article.author.username) ]
                [ img [ src article.author.image ]
                    []
                ]
            , div [ class "info" ]
                [ a [ class "author", href ("#/profile/" ++ article.author.username) ]
                    [ text article.author.username ]
                , span [ class "date" ]
                    [ text 
                        (case (fromString article.updatedAt) of
                            Err _ -> "..." -- What to really do here? 
                            Ok d -> 
                                format "%B %e, %Y" d) ]
                ]
            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                [ i [ class "ion-heart" ]
                    []
                , text (" " ++ (toString article.favoritesCount))
                ]
            ]
        , a [ class "preview-link", href ("#/article/" ++ article.slug) ]
            [ h1 []
                [ text article.title ]
            , p []
                [ text 
                    (case article.description of
                        Just s -> s
                        Nothing -> "") ]
            , span []
                [ text "Read more..." ]
            ]
        ]


articleAuthorInfo : Profile -> Html Msg
articleAuthorInfo author =
  div [ class "article-meta" ]
      [ a [ href "profile.html" ]
          [ img [ src author.image ]
              []
          ]
      , div [ class "info" ]
          [ a [ class "author", href "" ]
              [ text author.username ]
          , span [ class "date" ]
              [ text "January 20th" ]
          ]
      , button [ class "btn btn-sm btn-outline-secondary" ]
          [ i [ class "ion-plus-round" ]
              []
          , text (" Follow " ++ author.username ++ " ")
          , span [ class "counter" ]
              [ text "(10)" ]
          ]
      , text "         "
      , button [ class "btn btn-sm btn-outline-primary" ]
          [ i [ class "ion-heart" ]
              []
          , text "           Favorite Post "
          , span [ class "counter" ]
              [ text "(29)" ]
          ]
      ]

articleComment : Comment -> Html Msg
articleComment comment =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ]
                [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a [ class "comment-author", href "" ]
                [ img [ class "comment-author-img", src comment.author.image ]
                    []
                , text "            "
                ]
            , text "             "
            , a [ class "comment-author", href "" ]
                [ text comment.author.username ]
            , span [ class "date-posted" ]
                [ text (case (fromString comment.updatedAt) of
                            Err _ -> "..." -- What to really do here? 
                            Ok d -> 
                                format "%B %e, %Y" d) ]
            -- TODO : Display the correct information if this is the users comment or someone elses
            {-, span [ class "mod-options" ]
                   [ i [ class "ion-edit" ] []
                   , i [ class "ion-trash-a" ] []
                   ]-}
            ]
            
        ]

article : Article -> List Comment -> Html Msg
article art comments =
  div [ class "article-page" ]
    [ div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 []
                [ text art.title ]
            , articleAuthorInfo art.author
            ]
        ]
    , div [ class "container page" ]
        -- TODO : There are certain classes on the example
        [ Markdown.toHtml [class "row article-content"] art.body
        , hr []
            []
        , div [ class "article-actions" ]
            [ articleAuthorInfo art.author
            ]
        , div [ class "row" ]
            [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                [ Html.form [ class "card comment-form" ]
                    [ div [ class "card-block" ]
                        [ textarea [ class "form-control", placeholder "Write a comment...", attribute "rows" "3" ]
                            []
                        ]
                    , div [ class "card-footer" ]
                        [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ]
                            []
                        , button [ class "btn btn-sm btn-primary" ]
                            [ text "Post Comment            " ]
                        ]
                    ]
                , div []
                    (List.map articleComment comments)
                ]
            ]
        ]
    ]