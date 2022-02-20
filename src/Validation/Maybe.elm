module Validation.Maybe exposing (fromJust, lift)

{-| -}

import Validation exposing (Validation)


fromJust : String -> Validation (Maybe from) from
fromJust =
    Validation.fromPartialFunction identity


{-| -}
lift : Validation from to -> Validation (Maybe from) (Maybe to)
lift validation =
    Result.andThen <|
        \m ->
            case m of
                Nothing ->
                    Ok Nothing

                Just x ->
                    Result.map Just (Validation.run validation x)
