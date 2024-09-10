import gleam/function
import gleeunit/should
import playground/stack.{type Stack}

pub fn stack_push_test() {
  stack.new()
  |> stack.push(1)
  |> stack.push(2)
  |> function.tap(to_list_should_equal(_, [2, 1]))
  |> stack.push(3)
  |> function.tap(to_list_should_equal(_, [3, 2, 1]))
}

pub fn from_list_to_list_round_trip_test() {
  [3, 2, 1]
  |> stack.from_list
  |> to_list_should_equal([3, 2, 1])
}

pub fn top_test() {
  stack.new()
  |> stack.push(1)
  |> stack.push(2)
  |> stack.push(3)
  |> stack.top
  |> should.equal(Ok(3))
}

pub fn pop_nonempty_test() {
  let #(popped, stack_) =
    stack.new()
    |> stack.push(1)
    |> stack.push(2)
    |> stack.push(3)
    |> stack.pop
    |> should.be_ok

  popped |> should.equal(3)

  stack_ |> to_list_should_equal([2, 1])
}

pub fn pop_empty_test() {
  stack.new()
  |> stack.pop
  |> should.be_error
}

fn to_list_should_equal(stack_: Stack(a), list_: List(a)) {
  stack_
  |> stack.to_list
  |> should.equal(list_)
}
