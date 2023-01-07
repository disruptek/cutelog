version = "3.0.1"
author = "disruptek"
description = "cute logging"
license = "MIT"

task demo, "produce a demo":
  exec """demo docs/demo.svg "nim c --define:release --out=\$1 tests/test.nim""""
