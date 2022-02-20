module Validation.Maybe exposing (fromJust)

{-| -}

import Validation exposing (Validation)


fromJust : String -> Validation (Maybe from) from
fromJust =
    Validation.fromPartialFunction identity
