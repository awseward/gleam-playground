import gleam/list
import gleam/result

/// A pretty basic stack, it almost feels trivial enough to just do most of
/// this with basic list destructuring to not even need a module like this at
/// all… Almost.
///
pub opaque type Stack(element) {
  Stack(list: List(element))
}

pub fn new() -> Stack(a) {
  Stack(list: [])
}

pub fn from_list(list: List(a)) -> Stack(a) {
  Stack(list:)
}

pub fn to_list(stack: Stack(a)) -> List(a) {
  stack.list
}

pub fn is_empty(stack: Stack(a)) -> Bool {
  stack
  |> to_list
  |> list.is_empty
}

pub fn size(stack: Stack(a)) -> Int {
  stack
  |> to_list
  |> list.length
}

pub fn push(onto stack: Stack(a), this item: a) -> Stack(a) {
  stack
  |> to_list
  |> fn(l) { Stack([item, ..l]) }
}

pub fn pop(from stack: Stack(a)) -> Result(#(a, Stack(a)), Nil) {
  case to_list(stack) {
    [popped, ..list] -> Ok(#(popped, Stack(list:)))
    [] -> Error(Nil)
  }
}

pub fn top(from stack: Stack(a)) -> Result(a, Nil) {
  stack
  |> to_list
  |> list.first
}
