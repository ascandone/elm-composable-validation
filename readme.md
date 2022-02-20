## elm-composable-validation

> A collections of utilities for type-safe validation.

### Example
```elm
ageValidation : Validation String Int
ageValidation raw =
  raw
    |> Validation.String.notEmpty "This field is required"
    |> Validation.String.trim
    |> Validation.String.toInt "Insert a valid number"
    |> Validation.Number.min 18 "You must be over 18 to continue"
    |> Validation.Number.max 160 "Insert a valid age"

"  42 "
  |> Validation.run ageValidation 
  |> Expect.equal (Ok 42)

"200"
  |> Validation.run ageValidation 
  |> Expect.equal (Err "Insert a valid age")
```
