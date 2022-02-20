module Validation.Number exposing (min, max)

{-| Validations over the `number` type


## Predicates

@docs min, max

-}

import Validation exposing (Validation)


{-| -}
min : number -> String -> Validation number number
min min_ =
    Validation.filter (\n -> n >= min_)


{-| -}
max : number -> String -> Validation number number
max max_ =
    Validation.filter (\n -> n <= max_)
