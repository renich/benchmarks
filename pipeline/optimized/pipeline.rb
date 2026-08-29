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
    prefix = "task:item:".freeze
    while (batch = task_q.pop)
      break if batch == :done
      batch_total = 0
      batch.each do |item|
        payload = "#{prefix}#{item}"
        batch_total = (batch_total + fnv1a(payload)) & MASK64
      end
      res_q.push([batch.size, batch_total])
    end
  end
end

prod_t = Thread.new do
  chunk_size = 500
  (0...100_000).each_slice(chunk_size) do |slice|
    task_q.push(slice)
  end
  workers.times { task_q.push(:done) }
end

total = 0
count = 0
while count < 100_000
  c, chk = res_q.pop
  count += c
  total = (total + chk) & MASK64
end

prod_t.join
threads.each(&:join)

puts "Pipeline complete: processed=#{count}, checksum=#{total}"
