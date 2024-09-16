import birl/duration
import gleam/function
import gleam/io
import gleam/list
import gleam/result
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

pub fn single_leading_zero_test() {
  [6, 0, 13]
  |> list.map(playground.single_leading_zero)
  |> should.equal(["06", "00", "13"])
}

pub fn format_elapsed_ok_test() {
  1
  |> duration.hours
  |> duration.add(duration.minutes(4))
  |> duration.add(duration.seconds(20))
  |> duration.add(duration.milli_seconds(69))
  |> playground.format_elapsed
  |> should.be_ok
  |> should.equal("01:04:20.069")
}

pub fn format_elapsed_invalid_too_large_test() {
  24
  |> duration.hours
  |> playground.format_elapsed
  |> should.be_error
}

pub fn format_elapsed_invalid_too_precise_test() {
  10
  |> duration.micro_seconds
  |> playground.format_elapsed
  |> should.be_error
}
