module Main exposing (..)

import Html exposing (Html, text, div)
import Debug exposing (log)
import Navigation exposing (Location)
import Http
import Request.General exposing (..)
import Json.Decode exposing (decodeString)
import Json.Encode exposing (encode)

-- Views

import Views.Layout exposing (layout)
import Views.Home exposing (home)
import Views.Settings exposing (settings)
import Views.Login exposing (login)
import Views.Register exposing (register)
import Views.Profile exposing (profile)
import Views.Editor exposing (editor)
import Views.Article exposing (article)
import Data.Article exposing (Articles, Article)
import Data.User exposing (User, LoginUserRequest)
import Data.Profile exposing (Profile, ProfileArticleView(..))
import Data.Comment exposing (..)
import Data.Msg exposing (Msg(..))
import Ports exposing (..)
-- ROUTING

import Routes exposing (..)

type alias Model =
    { route : Route
    , mainPageData : Maybe Articles
    , articleData : Maybe Article
    , commentsData : List Comment
    , tags : List String
    , user : Maybe User
    , profile : Maybe Profile
    , profileArticles : List Article
    , profileFavArticles : List Article
    , profileView : ProfileArticleView
    , selectedTag : Maybe String
    , selectedPage : Int
    , loginName : String
    , loginPassword : String
    , feed : Bool
    }


model : Model
model =
    { route = Home
    , mainPageData = Nothing
    , articleData = Nothing
    , commentsData = []
    , tags = []
    , user = Nothing
    , profile = Nothing
    , profileArticles = []
    , profileFavArticles = []
    , profileView = MyArticles
    , selectedTag = Nothing
    , selectedPage = 0
    , loginName = ""
    , loginPassword = ""
    , feed = False
    }


subscriptions : Model -> Sub Msg
subscriptions model = loadSession LoadSession

parseUrlChange : Model -> Route -> ( Model, Cmd Msg )
parseUrlChange model newRoute =
    case newRoute of
        Home ->
            ( { model | route = newRoute, selectedPage = 0 , selectedTag = Nothing}
            , Cmd.batch
                [ Http.send HomeReq getArticles
                , Http.send TagsReq getTags
                , doLoadSession ()
                ]
            )

        Routes.Article s ->
            ( { model | route = newRoute }
            , Cmd.batch
                [ Http.send ArticleReq (getArticle s)
                , Http.send ArticleCommentsReq (getComments s)
                ]
            )

        Profile s ->
            ( { model | route = newRoute, profileView = MyArticles }
            , Cmd.batch
                [ Http.send ProfileReq (getProfile s)
                , Http.send ProfileArticlesReq (getUsersArticles s)
                ]
            )

        _ ->
            ( { model | route = newRoute }, Http.send HomeReq getArticles )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- CLIENT INTERACTIONS
        FilterTag s ->
            -- getFilteredArticlesByTag
            if model.selectedTag == Just s then
                ( { model | selectedTag = Just s, selectedPage = 0 }, Http.send HomeReq (getFilteredArticlesByTag s model.selectedPage) )
            else
                ( { model | selectedTag = Just s, selectedPage = 0 }, Http.send HomeReq (getFilteredArticlesByTag s 0) )
        FilterPage p ->
            case model.selectedTag of
            Just s ->
                ( { model | selectedPage = p }, Http.send HomeReq (getFilteredArticlesByTag s p) )
            Nothing ->
                case model.user of
                Just user ->
                    ( { model | selectedPage = p }, Http.send HomeReq (getFilteredArticlesByPage (Just user.token) model.feed p) )
                Nothing ->
                    ( { model | selectedPage = p }, Http.send HomeReq (getFilteredArticlesByPage Nothing model.feed p) )
        YourFeedClick ->
            case model.user of
                Just user ->
                    ( { model | selectedPage = 0, feed = True }, Http.send HomeReq (getFilteredArticlesByPage (Just user.token) True 0) )
                Nothing ->
                    ( { model | selectedPage = 0, feed = True }, Http.send HomeReq (getFilteredArticlesByPage Nothing False 0) )
        HomeFeedClick ->
            ( { model | selectedPage = 0, feed = False }, Http.send HomeReq (getFilteredArticlesByPage Nothing False 0) )
        ProfileFavArticles u ->
            ( { model | profileView = FavoritedArticles }, Http.send ProfileArticlesReq (getUsersFavoriteArticles u) )
        LoginName name ->
            ( {model | loginName = (log "new login name" name)}, Cmd.none )
        LoginPassword password ->
            ( {model | loginPassword = (log "new login password" password)}, Cmd.none )
        LoginPress ->
            ( model, Http.send LoginReq (postLogin {user = {email = model.loginName, password = model.loginPassword}}) )
        LogoutPress ->
            ( {model | user = Nothing} , Cmd.batch [ Navigation.newUrl "#", saveSession "" ] )

        DoLoadSession ->
            ( model , Cmd.none)
        LoadSession ms ->
            case ms of
                Just s ->
                    case (decodeString decodeUser s) of
                        (Ok data) ->
                            log "Loaded session" ({ model | user = Just data} , Cmd.none)
                        (Err a) ->
                            log a ( model , Cmd.none)
                Nothing ->
                    log "Found nothing" ( model , Cmd.none)
        -- DATA REQUEST
        UrlChange loc ->
            parseUrlChange model (parseLocation loc)

        HomeReq (Ok data) ->
            -- Is there a potential bug here? I route calls to this but sometimes I might need to set data to selectedPage 0?
            ( { model | mainPageData = Just (log "HomeReq Result" data) }, Cmd.none )

        HomeReq _ ->
            log "failed"
                (log (toString msg))
                ( model, Cmd.none )

        ArticleReq (Ok data) ->
            ( { model | articleData = Just (log "ArticleReq" data.article) }, Cmd.none )

        ArticleReq _ ->
            log "failed"
                (log (toString msg))
                ( model, Cmd.none )

        ArticleCommentsReq (Ok data) ->
            log "ArticleCommentsReq" ( { model | commentsData = data.comments }, Cmd.none )

        ArticleCommentsReq _ ->
            log "failed"
                (log (toString msg))
                ( model, Cmd.none )

        TagsReq (Ok data) ->
            ( { model | tags = data.tags }, Cmd.none )

        TagsReq _ ->
            ( model, Cmd.none )

        ProfileReq (Ok data) ->
            log "ProfileReq" ( { model | profile = Just data.profile }, Cmd.none )

        ProfileReq _ ->
            ( model, Cmd.none )

        ProfileArticlesReq (Ok data) ->
            log "ProfileArticlesReq" ( { model | profileArticles = data.articles }, Cmd.none )

        ProfileArticlesReq _ ->
            ( model, Cmd.none )
        LoginReq (Ok data) ->
            log "Login" ({model | user = Just data.user},  Cmd.batch [Navigation.newUrl "#", saveSession (encode 0 (encodeUser data.user))])
        LoginReq v ->
            log (toString v) ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.route of
        Home ->
            case model.mainPageData of
                Just articles ->
                    layout model.user model.route (home model.user articles model.selectedPage model.feed model.selectedTag model.tags)

                Nothing ->
                    -- TODO display an error?
                    layout model.user model.route (home model.user { articles = [], articlesCount = 0 } model.selectedPage model.feed model.selectedTag [])

        Settings ->
            case model.user of
                Just user ->
                    layout model.user model.route (settings user)
                Nothing ->
                    layout model.user model.route (div [] [ text "NotFound" ])

        Login ->
            layout model.user model.route login

        Register ->
            layout model.user model.route register

        Profile _ ->
            case model.profile of
                Just pro ->
                    layout model.user model.route (profile pro model.profileView model.profileArticles)

                Nothing ->
                    -- TODO Should be something else
                    layout model.user model.route (div [] [ text "NotFound" ])

        Editor ->
            layout model.user model.route editor

        Routes.Article _ ->
            case model.articleData of
                Just a ->
                    layout model.user model.route (article model.user a model.commentsData)

                Nothing ->
                    -- TODO display an error?
                    layout model.user model.route (home model.user { articles = [], articlesCount = 0 } model.selectedPage model.feed model.selectedTag [])

        NotFoundRoute ->
            layout model.user model.route (div [] [ text "NotFound" ])


init : Location -> ( Model, Cmd Msg )
init location =
    let
        newRoute =
            parseLocation location
    in
        parseUrlChange model newRoute
        -- TODO Load in user states if it is there


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
