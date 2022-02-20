module Validation.String exposing
    ( any, notEmpty, minLength, maxLength
    , toInt, toFloat, trim
    , optional
    )

{-| Validations over the `String` type


## Predicates

@docs any, notEmpty, minLength, maxLength


## Transformations

@docs toInt, toFloat, trim


## Higher order validations

@docs optional

-}

import Validation exposing (Validation)
import Validation.Maybe



-- Predicates


{-| Only succeeds when the given predicate matches at least one char
-}
any : (Char -> Bool) -> String -> Validation String String
any =
    String.any >> Validation.filter


{-| Only succeeds when the string is not empty
-}
notEmpty : String -> Validation String String
notEmpty =
    Validation.filter (not << String.isEmpty)


{-| Only succeeds when the string has at least n chars
-}
minLength : Int -> String -> Validation String String
minLength l =
    Validation.filter (\s -> String.length s >= l)


{-| Only succeeds when the string has at most n chars
-}
maxLength : Int -> String -> Validation String String
maxLength l =
    Validation.filter (\s -> String.length s <= l)



-- Transformations


{-| Parses an int
-}
toInt : String -> Validation String Int
toInt =
    Validation.fromPartialFunction String.toInt


{-| Parses a float
-}
toFloat : String -> Validation String Float
toFloat =
    Validation.fromPartialFunction String.toFloat


{-| Trims the given string. Always succeeds.
-}
trim : Validation String String
trim =
    Result.map String.trim



-- HOV


{-| Succeeds with `Nothing` when the given string is empty, else wraps it with Just
-}
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
