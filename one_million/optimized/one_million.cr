#!/usr/bin/env crystal

# Ultra-optimized 1M lines output using 64KB chunked buffer & in-place digit conversion
BUF_SIZE = 64 * 1024
buffer = uninitialized UInt8[BUF_SIZE]
pos = 0
prefix = "Hello, this is iteration number: "
prefix_ptr = prefix.to_unsafe
prefix_len = prefix.bytesize

1_000_000.times do |n|
  if pos + prefix_len + 12 > BUF_SIZE
    LibC.write(1, buffer.to_unsafe.as(Void*), pos)
    pos = 0
  end

  prefix_ptr.copy_to(buffer.to_unsafe + pos, prefix_len)
  pos += prefix_len

  temp = n
  idx = 10
  num_buf = uninitialized UInt8[10]
  if temp == 0
    idx -= 1
    num_buf[idx] = 48_u8
  else
    while temp > 0
      idx -= 1
      num_buf[idx] = (48 + (temp % 10)).to_u8
      temp //= 10
    end
  end
  num_len = 10 - idx
  (num_buf.to_unsafe + idx).copy_to(buffer.to_unsafe + pos, num_len)
  pos += num_len
  buffer[pos] = 10_u8
  pos += 1
end

if pos > 0
  LibC.write(1, buffer.to_unsafe.as(Void*), pos)
end
