module Validation exposing
    ( Validation
    , run
    , filter, fromPartialFunction
    , succeed, fail, map, contramap, map2, andMap, andThen
    , andMapWith
    )

{-|

@docs Validation
@docs run


## Create

@docs filter, fromPartialFunction


## Black magic

Functor, Applicative, Contravariant, Monad interfaces

@docs succeed, fail, map, contramap, map2, andMap, andThen
@docs andMapWith

-}


{-| An abstraction representing a validation from a type to another.
Should fail when the previous step fails

    Date.fromString : String -> Result String Date

    validateDate : Validation String Date
    validateDate =
        Result.andThen Date.fromIsoString

You can compose `Validation`s via regular function composition (or pipe operator)

    validateStringNonEmpty : Validation String String
    validateStringNonEmpty =
        Validation.String.notEmpty "This field is required"

    validateYearIsAtLeast1900 : Validation Date Date

    yearFieldValidation : Validation String Date
    yearFieldValidation =
        validateStringNonEmpty >> validateDate >> validateYearIsAtLeast1900

-}
type alias Validation from to =
    Result String from -> Result String to


{-| Runs a validation and returns a `Result`

    Validation.run yearFieldValidation ""
        |> Expect.equal (Err "This field is required")

    Validation.run yearFieldValidation "invalid year..."
        |> Expect.equal (Err "Enter a valid year")

    Validation.run yearFieldValidation "1800-09-26"
        |> Expect.equal (Err "Year must be at least 1900")

    Validation.run yearFieldValidation "2018-09-26"
        |> Expect.equal (Ok ...)

-}
run : Validation from to -> from -> Result String to
run =
    (>>) Ok


{-| Lifts a predicate to a validation

    stringHas4Chars : String -> Validation String String
    stringHas4Chars =
        Validation.fromPredicate (\str -> String.length str == 4)

    "ab"
    |> Validation.run (stringHas4Chars "string should have 4 chars")
    |> Expect.equal (Err "string should have 4 chars")

    "abcd"
    |> Validation.run (stringHas4Chars "...")
    |> Expect.equal (Ok "abcd")

-}
filter : (a -> Bool) -> String -> Validation a a
filter pred reason =
    Result.andThen <|
        \x ->
            if pred x then
                Ok x

            else
                Err reason


{-| Lifts a partial function to a validation

    -- The actual definition of `Validation.String.toInt`
    validateInt : String -> Validation String Int
    validateInt =
        Validation.fromPartialFunction String.toInt

-}
fromPartialFunction : (from -> Maybe to) -> String -> Validation from to
fromPartialFunction toMaybe reason =
    Result.andThen <|
        \src ->
            case toMaybe src of
                Nothing ->
                    Err reason

                Just x ->
                    Ok x



{- Obscure math -}


{-| -}
succeed : to -> Validation from to
succeed x _ =
    Ok x


{-| -}
fail : String -> Validation from to
fail errorMessage _ =
    Err errorMessage


{-| -}
map : (a -> b) -> Validation from a -> Validation from b
map f validation =
    validation >> Result.map f


{-| -}
contramap : (a -> b) -> Validation b to -> Validation a to
contramap f validation =
    Result.map f >> validation


{-| -}
map2 : (a -> b -> c) -> Validation from a -> Validation from b -> Validation from c
map2 f v1 v2 from =
    Result.map2 f (v1 from) (v2 from)


{-| -}
andMap : Validation from a -> Validation from (a -> b) -> Validation from b
andMap v1 v2 =
    map2 (<|) v2 v1


{-| -}
andThen : (a -> Validation from b) -> Validation from a -> Validation from b
andThen f validation from =
    Result.andThen (\a -> f a from) (validation from)


{-| -}
andMapWith : (a -> value) -> Validation value b -> Validation a (b -> c) -> Validation a c
andMapWith getter validation =
    andMap (contramap getter validation)
