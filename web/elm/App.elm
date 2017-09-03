module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push


type alias Model =
    { msgs : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type Msg
    = NoOp
    | Echo String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


chattyUrl =
    "ws://localhost:4000/socket/websocket"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    text <| toString model


initModel =
    { msgs = [ "nada" ]
    , phxSocket = Phoenix.Socket.init chattyUrl
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


main =
    program
        { update = update
        , view = view
        , init = ( initModel, Cmd.none )
        , subscriptions = subscriptions
        }
