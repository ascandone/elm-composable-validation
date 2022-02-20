module ValidationTest exposing (..)

import Expect
import Fuzz
import Test exposing (Test)
import Validation
import Validation.Int
import Validation.String


type alias Model =
    { x : String
    , y : String
    }


type alias Parsed =
    { x : Int
    , y : Int
    }


suite : Test
suite =
    Test.concat
        [ let
            validation =
                Validation.String.notEmpty "Required field"
                    >> Validation.String.trim
                    >> Validation.String.toInt "Expected an int"
                    >> Validation.Int.min 0 "Expected a positive int"
                    >> Validation.Int.max 100 "Expected a number <= 100"
          in
          Test.describe "Composition"
            [ Test.fuzz (Fuzz.intRange 0 100) "succeed" <|
                \n ->
                    n
                        |> String.fromInt
                        |> Validation.run validation
                        |> Expect.equal (Ok n)
            , Test.test "Empty str" <|
                \() ->
                    ""
                        |> Validation.run validation
                        |> Expect.equal (Err "Required field")
            , Test.test "Invalid int" <|
                \() ->
                    "nan"
                        |> Validation.run validation
                        |> Expect.equal (Err "Expected an int")
            , Test.test "Trimmed" <|
                \() ->
                    "  0 "
                        |> Validation.run validation
                        |> Expect.equal (Ok 0)
            , Test.test "Negative" <|
                \() ->
                    "  -1 "
                        |> Validation.run validation
                        |> Expect.equal (Err "Expected a positive int")
            , Test.test "Too big" <|
                \() ->
                    "  101 "
                        |> Validation.run validation
                        |> Expect.equal (Err "Expected a number <= 100")
            ]
        , let
            validation =
                Validation.succeed Parsed
                    |> Validation.field .x (Validation.String.toInt "x")
                    |> Validation.field .y (Validation.String.toInt "y")
          in
          Test.describe "Validation.field"
            [ Test.fuzz2 Fuzz.int Fuzz.int "Both succeed" <|
                \x y ->
                    { x = String.fromInt x
                    , y = String.fromInt y
                    }
                        |> Validation.run validation
                        |> Expect.equal (Ok { x = x, y = y })
            , Test.test "Both fail" <|
                \() ->
                    { x = "__"
                    , y = "__"
                    }
                        |> Validation.run validation
                        |> Expect.equal (Err "x")
            , Test.test "One fail" <|
                \() ->
                    { x = "42"
                    , y = "__"
                    }
                        |> Validation.run validation
                        |> Expect.equal (Err "y")
            ]
        , Test.describe "Validation.String.toInt"
            [ Test.fuzz Fuzz.int "Should parse number" <|
                \n ->
                    n
                        |> String.fromInt
                        |> Validation.run (Validation.String.toInt "msg")
                        |> Expect.equal (Ok n)
            , Test.fuzz2 Fuzz.string Fuzz.string "Should fail on other values" <|
                \str errorMessage ->
                    (str ++ "nan")
                        |> Validation.run (Validation.String.toInt errorMessage)
                        |> Expect.equal (Err errorMessage)
            ]
        ]
