#!/usr/bin/env ruby

FNV_OFFSET = 0xcbf29ce484222325
FNV_PRIME  = 0x100000001b3
MASK64     = 0xFFFFFFFFFFFFFFFF

def fnv1a(str)
  h = FNV_OFFSET
  str.each_byte do |b|
    h = ((h ^ b) * FNV_PRIME) & MASK64
  end
  h
end

task_q = SizedQueue.new(1000)
res_q  = SizedQueue.new(1000)
workers = 8

threads = Array.new(workers) do
  Thread.new do
    while (item = task_q.pop)
      break if item == :done
      payload = "task:item:#{item}"
      chk = fnv1a(payload)
      res_q.push([item, chk])
    end
  end
end

prod_t = Thread.new do
  100_000.times { |i| task_q.push(i) }
  workers.times { task_q.push(:done) }
end

total = 0
100_000.times do
  _, chk = res_q.pop
  total = (total + chk) & MASK64
end

prod_t.join
threads.each(&:join)

puts "Pipeline complete: processed=100000, checksum=#{total}"
