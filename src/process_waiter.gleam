import gleam/erlang/process.{type Pid, type ProcessMonitor, type Selector}
import gleam/dict.{type Dict}
import gleam/list

/// Wait for a list of processes to exit.
///
pub fn await_forever(pids: List(Pid)) -> Nil {
  let monitors =
    pids
    |> list.map(fn(pid) { #(pid, process.monitor_process(pid)) })
    |> dict.from_list
  let selector = selector_for_monitors(monitors)
  await_forever_loop(monitors, selector)
}

fn await_forever_loop(
  pids: Dict(Pid, ProcessMonitor),
  selector: Selector(Pid),
) -> Nil {
  let pid = process.select_forever(selector)
  let pids = dict.delete(pids, pid)
  case dict.size(pids) {
    0 -> Nil
    _ -> await_forever_loop(pids, selector)
  }
}

fn selector_for_monitors(monitors: Dict(Pid, ProcessMonitor)) -> Selector(Pid) {
  dict.values(monitors)
  |> list.fold(process.new_selector(), fn(selector, monitor) {
    process.selecting_process_down(selector, monitor, fn(msg) { msg.pid })
  })
}
