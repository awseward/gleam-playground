import decipher
import gleam/dynamic.{type DecodeError, type Dynamic, DecodeError}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should

import playground

pub fn main() {
  gleeunit.main()
}

pub fn decode_weight_unit_test() {
  [
    "lb", "lbs", "pound", "pounds", "kg", "kgs", "kilo", "kilos", "kilogram",
    "kilograms",
  ]
  |> list.map(fn(input: String) {
    input
    |> dynamic.from
    |> playground.decode_weight_unit
  })
  |> result.all
  |> should.be_ok
  |> should.equal(["lb", "lb", "lb", "lb", "kg", "kg", "kg", "kg", "kg", "kg"])
}

pub fn tokenize_test() {
  "100.25lb 3x20; 80lbs 10x8 38.5kilogram 2x10, 1x8 1x6"
  |> tokenize
  |> should.equal([
    WeightT("100.25lb", 100.25, "lb"),
    SetsT("3x20", 3, 20),
    WeightT("80lbs", 80.0, "lb"),
    SetsT("10x8", 10, 8),
    WeightT("38.5kilogram", 38.5, "kg"),
    SetsT("2x10", 2, 10),
    SetsT("1x8", 1, 8),
    SetsT("1x6", 1, 6),
  ])
}

type Token {
  WeightT(raw: String, value: Float, unit: String)
  SetsT(raw: String, sets: Int, reps: Int)
  UnknownT(raw: String)
}

fn decode_token(d: Dynamic) -> Result(Token, List(DecodeError)) {
  d
  |> dynamic.any([decode_weight, decode_sets, decode_unknown])
}

fn decode_weight(d: Dynamic) -> Result(Token, List(DecodeError)) {
  let assert Ok(re) =
    regex.from_string(
      "((\\d+(\\.\\d+)?)(lbs|lb|pounds|pound|kgs|kg|kilograms|kilogram|kilos|kilo))",
    )
  // Could use `use` here, but I'd rather know immediately if this is being
  // called on something that's not a string… Actually now that I think about
  // it, I don't see a reason why `dynamic.string` would ever fail? My
  // reasoning here is that presumably anything could be decoded as a string.
  let assert Ok(word) = dynamic.string(d)

  case regex.scan(word, with: re) {
    [] -> Error([DecodeError("FIXME", "FIXME", ["FIXME"])])
    [match] -> {
      let assert [_, Some(value_str), _, Some(unit_str)] = match.submatches
      let assert Ok(value) =
        value_str
        |> dynamic.from
        |> decipher.number_string
      let assert Ok(unit) =
        unit_str
        |> dynamic.from
        |> playground.decode_weight_unit

      Ok(WeightT(raw: match.content, value:, unit:))
    }
    _ -> panic
    // This could probably also just be a different `Error`
  }
}

fn decode_sets(d: Dynamic) -> Result(Token, List(DecodeError)) {
  let assert Ok(re) = regex.from_string("(\\d+)x(\\d+)")
  // Could use `use` here, but I'd rather know immediately if this is being
  // called on something that's not a string… Actually now that I think about
  // it, I don't see a reason why `dynamic.string` would ever fail? My
  // reasoning here is that presumably anything could be decoded as a string.
  let assert Ok(word) = dynamic.string(d)

  case regex.scan(word, with: re) {
    [] -> Error([DecodeError("FIXME", "FIXME", ["FIXME"])])
    [match] -> {
      let assert [Some(sets_str), Some(reps_str)] = match.submatches
      let assert Ok(sets) = int.parse(sets_str)
      let assert Ok(reps) = int.parse(reps_str)

      Ok(SetsT(raw: match.content, sets:, reps:))
    }
    _ -> panic
    // This could probably also just be a different `Error`
  }
}

fn decode_unknown(d: Dynamic) -> Result(Token, List(DecodeError)) {
  d
  |> dynamic.string
  |> result.map(UnknownT(raw: _))
}

fn tokenize(input: String) -> List(Token) {
  input
  |> string.split(" ")
  |> list.map(fn(word) { word |> dynamic.from |> decode_token })
  |> result.values
}
