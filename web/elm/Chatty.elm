module Chatty exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Json.Decode as JD


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , newMessage : String
    , messages : List String
    }


initModel : Model
initModel =
    { newMessage = "Hey"
    , phxSocket = Phoenix.Socket.init chattyUrl
    , messages = []
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, initCmd )


initCmd : Cmd Msg
initCmd =
    let
        channel =
            Phoenix.Channel.init "rooms:lobby"
                |> Phoenix.Channel.withPayload userParams

        ( _, phxCmd ) =
            Phoenix.Socket.join channel (Phoenix.Socket.init chattyUrl)
    in
        Cmd.map PhoenixMsg phxCmd


chattyUrl : String
chattyUrl =
    "ws://localhost:4000/socket/websocket"


userParams : JE.Value
userParams =
    JE.object [ ( "user_id", JE.string "123" ) ]


type Msg
    = SendMessage
    | RecieveMessage JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


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

        SendMessage ->
            let
                payload =
                    (JE.object [ ( "user", JE.string "user" ), ( "body", JE.string model.newMessage ) ])

                push_ =
                    Phoenix.Push.init "new:msg" "rooms:lobby"
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                ( { model
                    | phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        RecieveMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    ( { model | messages = (chatMessage.user ++ ": " ++ chatMessage.body) :: model.messages }
                    , Cmd.none
                    )

                Err error ->
                    let
                        _ =
                            Debug.log "err" error
                    in
                        ( model, Cmd.none )


type alias ChatMessage =
    { user : String
    , body : String
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map2 ChatMessage
        (JD.field "user" JD.string)
        (JD.field "body" JD.string)


view : Model -> Html Msg
view model =
    div []
        [ text <| toString model
        , button [ onClick SendMessage ] [ text "Say hey." ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
