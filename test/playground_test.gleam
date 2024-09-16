import gleam/function
import gleam/io
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should

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
