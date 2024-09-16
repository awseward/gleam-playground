import birl/duration.{type Duration}
import gleam/bool.{guard, or}
import gleam/io
import gleam/iterator
import gleam/list
import gleam/order
import gleam/result
import stdin.{stdin}

pub fn main() {
  stdin() |> iterator.each(io.println(_))
}

import gleam/int
import gleam/string

pub fn single_leading_zero(n: Int) -> String {
  n
  |> int.to_string
  |> string.pad_left(2, "0")
}

pub fn format_elapsed(d: Duration) -> Result(String, Nil) {
  let parts = duration.decompose(d)
  let gte_24h = case duration.compare(d, duration.hours(24)) {
    order.Gt | order.Eq -> True
    _ -> False
  }
  let has_usec =
    parts
    |> list.any(fn(tup) {
      case tup.1 {
        duration.MicroSecond -> True
        _ -> False
      }
    })
  use <- guard(when: or(gte_24h, has_usec), return: Error(Nil))

  let find_map_or = fn(xs: List(a), default: b, f: fn(a) -> Result(b, c)) -> b {
    xs
    |> list.find_map(f)
    |> result.replace_error(default)
    |> result.unwrap_both
  }

  let hours =
    parts
    |> find_map_or(0, fn(tup) {
      case tup.1 {
        duration.Hour -> Ok(tup.0)
        _ -> Error(Nil)
      }
    })
  let minutes =
    parts
    |> find_map_or(0, fn(tup) {
      case tup.1 {
        duration.Minute -> Ok(tup.0)
        _ -> Error(Nil)
      }
    })
  let seconds =
    parts
    |> find_map_or(0, fn(tup) {
      case tup.1 {
        duration.Second -> Ok(tup.0)
        _ -> Error(Nil)
      }
    })
  let milli_seconds =
    parts
    |> find_map_or(0, fn(tup) {
      case tup.1 {
        duration.MilliSecond -> Ok(tup.0)
        _ -> Error(Nil)
      }
    })

  string.join(
    [
      string.pad_left(int.to_string(hours), 2, "0"),
      string.pad_left(int.to_string(minutes), 2, "0"),
      string.join(
        [
          string.pad_left(int.to_string(seconds), 2, "0"),
          string.pad_left(int.to_string(milli_seconds), 3, "0"),
        ],
        ".",
      ),
    ],
    ":",
  )
  |> Ok
}
