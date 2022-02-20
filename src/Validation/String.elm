module Validation.String exposing
    ( any, notEmpty, minLength, maxLength
    , toInt, toFloat, trim
    , optional
    )

{-|


## Predicates

@docs any, notEmpty, minLength, maxLength


## Transformations

@docs toInt, toFloat, trim


## Higher order validations

@docs optional

-}

import Validation exposing (Validation)
import Validation.Maybe


{-| -}
toInt : String -> Validation String Int
toInt =
    Validation.fromPartialFunction String.toInt


{-| -}
toFloat : String -> Validation String Float
toFloat =
    Validation.fromPartialFunction String.toFloat


{-| -}
any : (Char -> Bool) -> String -> Validation String String
any =
    String.any >> Validation.filter


{-| -}
notEmpty : String -> Validation String String
notEmpty =
    minLength 1


{-| -}
minLength : Int -> String -> Validation String String
minLength l =
    Validation.filter (\s -> String.length s >= l)


{-| -}
maxLength : Int -> String -> Validation String String
maxLength l =
    Validation.filter (\s -> String.length s <= l)


{-| -}
trim : Validation String String
trim =
    Result.map String.trim


{-| -}
optional : Validation String to -> Validation String (Maybe to)
optional validation =
    Result.map stringToMaybe >> Validation.Maybe.lift validation


{-| -}
stringToMaybe : String -> Maybe String
stringToMaybe str =
    if String.isEmpty str then
        Nothing

    else
        Just str
