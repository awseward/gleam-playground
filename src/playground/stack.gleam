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
  list.is_empty(stack.list)
}

pub fn size(stack: Stack(a)) -> Int {
  list.length(stack.list)
}

pub fn push(onto stack: Stack(a), this item: a) -> Stack(a) {
  Stack([item, ..stack.list])
}

pub fn pop(from stack: Stack(a)) -> Result(#(a, Stack(a)), Nil) {
  list.pop(stack.list, fn(_) { True })
  case stack.list {
    [head, ..tail] -> Ok(#(head, Stack(list: tail)))
    [] -> Error(Nil)
  }
}

pub fn top(from stack: Stack(a)) -> Result(a, Nil) {
  list.first(stack.list)
}
