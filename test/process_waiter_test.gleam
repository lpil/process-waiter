import gleeunit
import gleam/erlang/process
import process_waiter

pub fn main() {
  gleeunit.main()
}

pub fn wait_forever_test() {
  let pid1 = process.start(fn() { process.sleep(500) }, True)
  let pid2 = process.start(fn() { process.sleep(500) }, True)

  process_waiter.new()
  |> process_waiter.add_pid(pid1)
  |> process_waiter.add_pid(pid2)
  |> process_waiter.wait_forever

  let assert False = process.is_alive(pid1)
  let assert False = process.is_alive(pid1)
}
