module Validation.Password exposing
    ( Password
    , fromString
    , toString
    )

import Validation exposing (Validation)
import Validation.String


type Password
    = Password String


isSpecial : Char -> Bool
isSpecial ch =
    String.any ((==) ch) "!@#$%^£€&*(),.?\":{}|<>"


fromString : Validation String Password
fromString raw =
    raw
        |> Validation.String.any Char.isUpper "The password should have at least one uppercase character"
        |> Validation.String.any Char.isLower "The password should have at least one lowercase character"
        |> Validation.String.any isSpecial "The password should have at least one special character"
        |> Validation.String.any Char.isDigit "The password should have at least one numberic character"
        |> Validation.String.minLength 8 "The password should have at least 8 characters"
        |> Result.map Password


toString : Password -> String
toString (Password str) =
    str
