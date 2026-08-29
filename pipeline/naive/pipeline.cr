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

def fnv1a(str : String) : UInt64
  h = FNV_OFFSET
  str.each_byte do |b|
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
      while task = tasks.receive?
        payload = "task:item:#{task.id}"
        chk = fnv1a(payload)
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
