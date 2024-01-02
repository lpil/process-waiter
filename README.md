# process_waiter

[![Package Version](https://img.shields.io/hexpm/v/process_waiter)](https://hex.pm/packages/process_waiter)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/process_waiter/)

```sh
gleam add process_waiter
```
```gleam
import gleam/erlang/process
import process_waiter

pub fn main() {
  // Start some processes
  let pid1 = process.spawn(fn() { process.sleep(500) })
  let pid2 = process.spawn(fn() { process.sleep(500) })
  let pid3 = process.spawn(fn() { process.sleep(500) })

  // Wait for them to exit
  process_waiter.wait([pid1, pid2, pid3])

  // The processes have now finished
  process.is_alive(pid1) // -> False
}
```

Documentation can be found at <https://hexdocs.pm/process_waiter>.
