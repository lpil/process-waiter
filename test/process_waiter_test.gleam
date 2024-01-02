import gleeunit
import gleam/erlang/process
import process_waiter

pub fn main() {
  gleeunit.main()
}

pub fn wait_forever_test() {
  let pid1 = process.start(fn() { process.sleep(500) }, True)
  let pid2 = process.start(fn() { process.sleep(500) }, True)

  process_waiter.await_forever([pid1, pid2])

  let assert False = process.is_alive(pid1)
  let assert False = process.is_alive(pid1)
}
