import decipher
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/io
import gleam/iterator
import gleam/list
import stdin.{stdin}

pub fn main() {
  stdin() |> iterator.each(io.println(_))
}

pub fn decode_weight_unit(d: Dynamic) -> Result(String, List(DecodeError)) {
  d
  |> decipher.enum(
    splat_synonyms_many([
      #("lb", ["lb", "lbs", "pound", "pounds"]),
      #("kg", ["kg", "kgs", "kilo", "kilos", "kilogram", "kilograms"]),
    ]),
  )
}

fn splat_synonyms_one(
  from synonyms: List(String),
  to normalized: String,
) -> List(#(String, String)) {
  synonyms |> list.map(fn(syn: String) { #(syn, normalized) })
}

fn splat_synonyms_many(
  entries: List(#(String, List(String))),
) -> List(#(String, String)) {
  entries
  |> list.flat_map(fn(tup) {
    let #(normalized, synonyms) = tup

    splat_synonyms_one(to: normalized, from: synonyms)
  })
}
