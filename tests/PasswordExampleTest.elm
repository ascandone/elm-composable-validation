module PasswordExampleTest exposing (..)

import Expect
import Test exposing (Test)
import Validation
import Validation.Password


suite : Test
suite =
    Test.describe "Password validation example"
        [ Test.test "Valid password" <|
            \() ->
                "Aa$012345678"
                    |> Validation.run Validation.Password.fromString
                    |> Expect.ok
        ]
