import decipher
import gleam/dynamic.{type DecodeError, type Dynamic, DecodeError}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/queue.{type Queue}
import gleam/regex.{type Match}
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should

import playground

pub fn main() {
  gleeunit.main()
}

// --- Based on the example here: https://tour.gleam.run/advanced-features/use/

pub type UseTourError {
  UsernameError
  PasswordError
  LogInError
}

fn get_username() {
  Ok("alice")
  // Error(UsernameError)
}

fn get_password() {
  Ok("hunter2")
  // Error(PasswordError)
}

fn log_in(_username: String, _password: String) {
  Ok("Welcome")
  // Error(LogInError)
}

fn log_in_() {
  use username <- result.try(get_username())
  use password <- result.try(get_password())
  use greeting <- result.map(log_in(username, password))

  greeting <> ", " <> username
}

pub fn log_in_test() {
  io.debug(log_in_())
}

// ---

pub type Foo {
  A
  B
  C
  Delim
}

fn is_delim(x: Foo) {
  case x {
    Delim -> True
    _ -> False
  }
}

pub fn chunk_test() {
  [A, B, A, A, C, Delim, A, Delim, Delim, B, B, C, Delim, A, C, A, B]
  |> list.chunk(is_delim)
  |> list.filter(fn(xs) { [Delim] != list.unique(xs) })
  |> function.tap(should.equal(_, [
    [A, B, A, A, C],
    [A],
    [B, B, C],
    [A, C, A, B],
  ]))
}

// ---

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
  let tokens =
    "Lat pulldown 100.25lb 3x20; 80lbs 10x8 38.5kilogram 2x10 kind of cheaty, 1x8 1x6 --- not feeling in lats"
    |> tokenize
    |> function.tap(should.equal(_, [
      UnknownT("Lat"),
      UnknownT("pulldown"),
      // ---
      WeightT("100.25lb", 100.25, "lb"),
      SetsT("3x20", 3, 20),
      // ---
      WeightT("80lbs", 80.0, "lb"),
      SetsT("10x8", 10, 8),
      // ---
      WeightT("38.5kilogram", 38.5, "kg"),
      SetsT("2x10", 2, 10),
      UnknownT("kind"),
      UnknownT("of"),
      UnknownT("cheaty,"),
      SetsT("1x8", 1, 8),
      SetsT("1x6", 1, 6),
      // ---
      DelimiterT,
      // ---
      UnknownT("not"),
      UnknownT("feeling"),
      UnknownT("in"),
      UnknownT("lats"),
    ]))
    |> list.fold(queue.new(), fn(acc: Queue(List(Token)), token: Token) -> Queue(
      List(Token),
    ) {
      case queue.pop_back(acc) {
        // I believe this is our "empty queue" starting state.
        Error(_) -> queue.from_list([[token]])

        Ok(#(tokens, acc_)) -> {
          // Will never push [] into the queue, so this is safe.
          let assert Ok(back_token) = list.last(tokens)

          case back_token, token {
            _, WeightT(..) -> [tokens, [token]]

            _, DelimiterT -> [tokens, [token]]
            DelimiterT, _ -> [[token]]

            _, _ -> [list.reverse([token, ..list.reverse(tokens)])]
          }
          |> list.fold(from: acc_, with: queue.push_back)
        }
      }
    })
    // Throwing `queue.to_list` in here because it's WAY easier to assert
    // against; i.e. queue "literals" don't really seem to be so much of a thing
    |> queue.to_list
    |> should.equal([
      // [
      //   UnknownT(
      //     "FIXME: Probably should iterate from here.

      //     Left this invalid Token in here instead of just a comment because
      //     it's nice to have a failing test to come back to pointing you towards
      //     what needs doing.",
      //   ),
      // ],
      [UnknownT("Lat"), UnknownT("pulldown")],
      [WeightT("100.25lb", 100.25, "lb"), SetsT("3x20", 3, 20)],
      [WeightT("80lbs", 80.0, "lb"), SetsT("10x8", 10, 8)],
      [
        WeightT("38.5kilogram", 38.5, "kg"),
        SetsT("2x10", 2, 10),
        UnknownT("kind"),
        UnknownT("of"),
        UnknownT("cheaty,"),
        SetsT("1x8", 1, 8),
        SetsT("1x6", 1, 6),
      ],
      [UnknownT("not"), UnknownT("feeling"), UnknownT("in"), UnknownT("lats")],
    ])
}

pub type Token {
  WeightT(raw: String, value: Float, unit: String)
  SetsT(raw: String, sets: Int, reps: Int)
  // Don't particularly care what the delimiter actually WAS, just that it's there.
  DelimiterT
  UnknownT(raw: String)
}

fn decode_token(d: Dynamic) -> Result(Token, List(DecodeError)) {
  d
  |> dynamic.any([decode_weight, decode_sets, decode_delimiter, decode_unknown])
}

// The `_strict` suffix here denotes the fact that the `with` function MUST
// produce an `a` (i.e. the provided regex implies totality of its captures).
fn decode_single_regex_match_strict(
  d: Dynamic,
  matching pattern: String,
  with f: fn(Match) -> a,
) -> Result(a, List(DecodeError)) {
  let assert Ok(re) = regex.from_string(pattern)
  // Could use `use` here, but I'd rather know immediately if this is being
  // called on something that's not a string…
  //
  // Actually now that I think about it, I don't see a reason why
  // `dynamic.string` would ever fail? My reasoning here is that presumably
  // anything could be decoded as a string… This is worth looking into.
  let assert Ok(str) = dynamic.string(d)

  case regex.scan(str, with: re) {
    [match] -> Ok(f(match))
    [] -> Error([DecodeError("single match", "no match", [pattern])])
    _ -> Error([DecodeError("single match", "plural matches", [pattern])])
  }
}

fn decode_weight(d: Dynamic) -> Result(Token, List(DecodeError)) {
  d
  |> decode_single_regex_match_strict(
    matching: "((\\d+(\\.\\d+)?)(lbs|lb|pounds|pound|kgs|kg|kilograms|kilogram|kilos|kilo))",
    with: fn(match) {
      let assert [_, Some(value_str), _, Some(unit_str)] = match.submatches
      let assert Ok(value) =
        value_str
        |> dynamic.from
        |> decipher.number_string
      let assert Ok(unit) =
        unit_str
        |> dynamic.from
        |> playground.decode_weight_unit

      WeightT(raw: match.content, value:, unit:)
    },
  )
}

fn decode_sets(d: Dynamic) -> Result(Token, List(DecodeError)) {
  d
  |> decode_single_regex_match_strict(
    matching: "(\\d+)x(\\d+)",
    with: fn(match: Match) {
      let assert [Some(sets_str), Some(reps_str)] = match.submatches
      let assert Ok(sets) = int.parse(sets_str)
      let assert Ok(reps) = int.parse(reps_str)

      SetsT(raw: match.content, sets:, reps:)
    },
  )
}

fn decode_delimiter(d: Dynamic) -> Result(Token, List(DecodeError)) {
  let pattern = "#+|[-=]{2,}"
  let assert Ok(re) = regex.from_string(pattern)
  // Could use `use` here, but I'd rather know immediately if this is being
  // called on something that's not a string…
  //
  // Actually now that I think about it, I don't see a reason why
  // `dynamic.string` would ever fail? My reasoning here is that presumably
  // anything could be decoded as a string… This is worth looking into.
  let assert Ok(str) = dynamic.string(d)

  case regex.check(with: re, content: str) {
    True -> Ok(DelimiterT)
    False -> Error([DecodeError("regex match", "no match", [pattern])])
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
