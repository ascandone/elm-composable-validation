module Validation exposing
    ( Validation
    , run
    , filter, fromPartialFunction
    , field, optional
    , succeed, fail, map, map2, andMap, andThen
    )

{-|

@docs Validation
@docs run


## Create

@docs filter, fromPartialFunction


## Transform

@docs field, optional


## Black magic

Functor, Applicative, Monad interface

@docs succeed, fail, map, map2, andMap, andThen

-}


{-| -}
type alias Validation from to =
    Result String from -> Result String to


{-| -}
run : Validation from to -> from -> Result String to
run val =
    val << Ok


{-| -}
filter : (a -> Bool) -> String -> Validation a a
filter pred reason =
    Result.andThen <|
        \x ->
            if pred x then
                Ok x

            else
                Err reason


{-| -}
fromPartialFunction : (from -> Maybe to) -> String -> Validation from to
fromPartialFunction toMaybe reason =
    Result.andThen <|
        \src ->
            case toMaybe src of
                Nothing ->
                    Err reason

                Just x ->
                    Ok x


{-| -}
field : (a -> value) -> Validation value b -> Validation a (b -> c) -> Validation a c
field getter validation =
    andMap (Result.map getter >> validation)


{-| -}
optional : Validation from to -> Validation (Maybe from) (Maybe to)
optional validation =
    Result.andThen <|
        \m ->
            case m of
                Nothing ->
                    Ok Nothing

                Just x ->
                    Result.map Just (run validation x)



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
