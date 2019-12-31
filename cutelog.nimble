version = "1.1.2"
author = "disruptek"
description = "cute logging"
license = "MIT"
requires "nim >= 0.19.6"

proc execCmd(cmd: string) =
  echo "execCmd:" & cmd
  exec cmd

proc execTest(test: string) =
  execCmd "nim c   -r " & test
  execCmd "nim c   -d:release -r " & test
  execCmd "nim c   -d:danger  -r " & test
  execCmd "nim cpp -d:danger  -r " & test
  when NimMajor >= 1 and NimMinor >= 1:
    execCmd "nim c   --gc:arc -r " & test
    execCmd "nim cpp --gc:arc -r " & test

task test, "run tests for travis":
  execTest("tests/tcutelog.nim")
