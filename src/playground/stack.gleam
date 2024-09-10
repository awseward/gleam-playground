import gleam/queue.{type Queue}
import gleam/result

/// A basic stack…
///
/// Uses the standard library's
/// [Queue](https://hexdocs.pm/gleam_stdlib/gleam/queue.html) as its backing
/// store.
///
pub opaque type Stack(element) {
  Stack(queue: Queue(element))
}

pub fn new() -> Stack(a) {
  Stack(queue.new())
}

pub fn from_list(list: List(a)) -> Stack(a) {
  list
  |> queue.from_list
  |> queue.reverse
  |> Stack
}

pub fn to_list(stack: Stack(a)) -> List(a) {
  stack.queue
  |> queue.reverse
  |> queue.to_list
}

pub fn is_empty(stack: Stack(a)) -> Bool {
  queue.is_empty(stack.queue)
}

// -- From here on is where the API diverges from that of Queue

pub fn size(stack: Stack(a)) -> Int {
  queue.length(stack.queue)
}

pub fn push(onto stack: Stack(a), this item: a) -> Stack(a) {
  item
  |> queue.push_back(onto: stack.queue)
  |> Stack
}

pub fn pop(from stack: Stack(a)) -> Result(#(a, Stack(a)), Nil) {
  use #(item, queue) <- result.try(queue.pop_back(stack.queue))

  Ok(#(item, Stack(queue:)))
}

pub fn top(from stack: Stack(a)) -> Result(a, Nil) {
  use #(item, _queue) <- result.try(queue.pop_back(stack.queue))

  Ok(item)
}
