let prefix = "Hello, this is iteration number: "
var buf = newStringOfCap(65536)

for n in 0 ..< 1_000_000:
  buf.add(prefix)
  buf.add($n)
  buf.add('\n')
  if buf.len >= 64000:
    stdout.write(buf)
    buf.setLen(0)

if buf.len > 0:
  stdout.write(buf)
