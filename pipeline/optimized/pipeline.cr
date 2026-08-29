require "wait_group"

struct Task
  getter id : Int32
  def initialize(@id : Int32)
  end
end

struct Result
  getter id : Int32
  getter checksum : UInt64
  def initialize(@id : Int32, @checksum : UInt64)
  end
end

FNV_OFFSET = 0xcbf29ce484222325_u64
FNV_PRIME  = 0x100000001b3_u64

@[AlwaysInline]
def fnv1a_slice(slice : Bytes) : UInt64
  h = FNV_OFFSET
  slice.each do |b|
    h = (h ^ b) &* FNV_PRIME
  end
  h
end

def main
  tasks = Channel(Task).new(1000)
  results = Channel(Result).new(1000)
  workers = 8
  wg = WaitGroup.new(workers)

  workers.times do
    spawn do
      prefix = "task:item:".to_slice
      buf = Bytes.new(32)
      prefix.copy_to(buf)

      while task = tasks.receive?
        # Fast in-place int to ASCII digits
        temp = task.id
        idx = 32
        if temp == 0
          idx -= 1
          buf[idx] = 48_u8 # '0'
        else
          while temp > 0
            idx -= 1
            buf[idx] = (48 + (temp % 10)).to_u8
            temp //= 10
          end
        end
        num_len = 32 - idx
        full_len = prefix.size + num_len
        buf[idx, num_len].copy_to(buf.to_unsafe + prefix.size, num_len)

        chk = fnv1a_slice(buf[0, full_len])
        results.send(Result.new(task.id, chk))
      end
      wg.done
    end
  end

  spawn do
    wg.wait
    results.close
  end

  spawn do
    100_000.times do |i|
      tasks.send(Task.new(i))
    end
    tasks.close
  end

  total_checksum = 0_u64
  count = 0
  while res = results.receive?
    total_checksum = total_checksum &+ res.checksum
    count += 1
  end

  puts "Pipeline complete: processed=#{count}, checksum=#{total_checksum}"
end

main
