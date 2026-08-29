import std/[strformat]

const
  FnvOffset: uint64 = 0xcbf29ce484222325'u64
  FnvPrime: uint64  = 0x100000001b3'u64

proc fnv1a_fast(s: string): uint64 {.inline.} =
  result = FnvOffset
  for c in s:
    result = (result xor uint64(ord(c))) * FnvPrime

var total: uint64 = 0
let prefix = "task:item:"
for i in 0 ..< 100000:
  let payload = prefix & $i
  total = total + fnv1a_fast(payload)

echo &"Pipeline complete: processed=100000, checksum={total}"
