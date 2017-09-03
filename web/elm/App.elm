module App exposing (..)

import Html exposing (program)
import Chatty


main =
    program
        { update = Chatty.update
        , view = Chatty.view
        , init = Chatty.init
        , subscriptions = Chatty.subscriptions
        }
