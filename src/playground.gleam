import gleam/io
import gleam/iterator
import stdin.{stdin}

pub fn main() {
  stdin() |> iterator.each(io.println(_))
}
