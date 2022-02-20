module Validation.Int exposing (min, max)

{-|


## Predicates

@docs min, max

-}

import Validation exposing (Validation)


{-| -}
min : Int -> String -> Validation Int Int
min min_ =
    Validation.filter (\n -> n >= min_)


{-| -}
max : Int -> String -> Validation Int Int
max max_ =
    Validation.filter (\n -> n <= max_)
