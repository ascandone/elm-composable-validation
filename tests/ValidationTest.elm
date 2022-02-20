module ValidationTest exposing (..)

import Expect
import Fuzz
import Test exposing (Test)
import Validation
import Validation.Maybe
import Validation.Number
import Validation.String


type alias Model =
    { x : String
    , y : String
    }


type alias Parsed =
    { x : Int
    , y : Int
    }


validationTests : Test
validationTests =
    Test.concat
        [ let
            validation =
                Validation.String.notEmpty "Required field"
                    >> Validation.String.trim
                    >> Validation.String.toInt "Expected an int"
                    >> Validation.Number.min 0 "Expected a positive int"
                    >> Validation.Number.max 100 "Expected a number <= 100"
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
                    |> Validation.andMapWith .x (Validation.String.toInt "x")
                    |> Validation.andMapWith .y (Validation.String.toInt "y")
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
        ]


stringValidationTests : Test
stringValidationTests =
    Test.describe "Validation.Test.*"
        [ Test.describe "optional"
            [ Test.test "validates just" <|
                \() ->
                    Just " abc "
                        |> Validation.run (Validation.Maybe.lift Validation.String.trim)
                        |> Expect.equal (Ok (Just "abc"))
            , Test.test "validates Nothiing" <|
                \() ->
                    Nothing
                        |> Validation.run (Validation.Maybe.lift (Validation.fail "fail"))
                        |> Expect.equal (Ok Nothing)
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


maybeValidationsTest : Test
maybeValidationsTest =
    Test.describe "Validation.Maybe.*"
        [ Test.describe "lift"
            [ Test.test "validates just" <|
                \() ->
                    Just " abc "
                        |> Validation.run (Validation.Maybe.lift Validation.String.trim)
                        |> Expect.equal (Ok (Just "abc"))
            , Test.test "validates Nothiing" <|
                \() ->
                    Nothing
                        |> Validation.run (Validation.Maybe.lift (Validation.fail "fail"))
                        |> Expect.equal (Ok Nothing)
            ]
        ]
