import gleam/erlang/process.{
  type Pid, type ProcessMonitor, type Selector, type Subject,
}
import gleam/dict.{type Dict}
import gleam/list

// TODO: document
pub opaque type ProcessWaiter {
  ProcessWaiter(pids: List(Pid), monitors: Dict(Pid, ProcessMonitor))
}

// TODO: document
pub fn new() -> ProcessWaiter {
  ProcessWaiter([], dict.new())
}

// TODO: document
pub fn add_pid(waiter: ProcessWaiter, pid: Pid) -> ProcessWaiter {
  ProcessWaiter(..waiter, pids: [pid, ..waiter.pids])
}

// TODO: document
pub fn add_subject(waiter: ProcessWaiter, subject: Subject(a)) -> ProcessWaiter {
  add_pid(waiter, process.subject_owner(subject))
}

// TODO: document
pub fn wait_forever(waiter: ProcessWaiter) -> Result(Nil, ProcessWaiter) {
  let waiter = convert_pids_to_monitors(waiter)
  let selector = selector_for_monitors(waiter.monitors)
  wait_forever_loop(waiter, selector)
}

fn wait_forever_loop(
  waiter: ProcessWaiter,
  selector: Selector(Pid),
) -> Result(Nil, ProcessWaiter) {
  let pid = process.select_forever(selector)
  let waiter = remove_monitor(waiter, pid)
  case dict.size(waiter.monitors) {
    0 -> Ok(Nil)
    _ -> wait_forever_loop(waiter, selector)
  }
}

fn remove_monitor(waiter: ProcessWaiter, pid: Pid) -> ProcessWaiter {
  let monitors = dict.delete(waiter.monitors, pid)
  ProcessWaiter(..waiter, monitors: monitors)
}

fn selector_for_monitors(monitors: Dict(Pid, ProcessMonitor)) -> Selector(Pid) {
  dict.values(monitors)
  |> list.fold(process.new_selector(), fn(selector, monitor) {
    process.selecting_process_down(selector, monitor, fn(msg) { msg.pid })
  })
}

fn convert_pids_to_monitors(waiter: ProcessWaiter) -> ProcessWaiter {
  let monitors =
    waiter.pids
    |> list.map(fn(pid) { #(pid, process.monitor_process(pid)) })
    |> dict.from_list
  ProcessWaiter(monitors: monitors, pids: [])
}
