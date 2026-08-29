proc c_write(fd: cint, buf: pointer, count: csize_t): csize_t {.importc: "write", header: "<unistd.h>".}

const
  BufSize = 65536
  Prefix = "Hello, this is iteration number: "
  PrefixLen = Prefix.len

var
  buffer: array[BufSize, char]
  pos = 0

for n in 0 ..< 1_000_000:
  if pos + PrefixLen + 16 > BufSize:
    discard c_write(1, addr buffer[0], pos.csize_t)
    pos = 0

  copyMem(addr buffer[pos], cstring(Prefix), PrefixLen)
  pos += PrefixLen

  var
    numBuf: array[10, char]
    temp = n
    idx = 10

  if temp == 0:
    dec(idx)
    numBuf[idx] = '0'
  else:
    while temp > 0:
      dec(idx)
      numBuf[idx] = chr(ord('0') + (temp mod 10))
      temp = temp div 10

  let numLen = 10 - idx
  copyMem(addr buffer[pos], addr numBuf[idx], numLen)
  pos += numLen
  buffer[pos] = '\n'
  inc(pos)

if pos > 0:
  discard c_write(1, addr buffer[0], pos.csize_t)
