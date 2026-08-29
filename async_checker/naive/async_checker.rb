#!/usr/bin/env ruby

def run_task(id)
  seed = (id * 1664525 + 1013904223) & 0xFFFFFFFF
  latency = 10 + (seed % 990)
  status = if (seed % 7) != 0
             200
           else
             (seed % 3) == 0 ? 429 : 500
           end
  [latency, status]
end

tasks = 10000
workers = 16
res_q = SizedQueue.new(1000)
chunk_size = tasks / workers

threads = Array.new(workers) do |w|
  start_idx = w * chunk_size
  end_idx = (w == workers - 1) ? tasks : start_idx + chunk_size
  Thread.new do
    (start_idx...end_idx).each do |i|
      res_q.push(run_task(i))
    end
  end
end

ok_count = 0
rl_count = 0
err_count = 0
total_lat = 0
latencies = Array.new(tasks)

tasks.times do |i|
  lat, status = res_q.pop
  latencies[i] = lat
  total_lat += lat
  case status
  when 200 then ok_count += 1
  when 429 then rl_count += 1
  when 500 then err_count += 1
  end
end

threads.each(&:join)

latencies.sort!
p50 = latencies[(tasks * 0.50).to_i]
p95 = latencies[(tasks * 0.95).to_i]
p99 = latencies[(tasks * 0.99).to_i]

puts "Async complete: tasks=#{tasks}, ok=#{ok_count}, rate_limited=#{rl_count}, errors=#{err_count}, latency_sum=#{total_lat}, p50=#{p50}, p95=#{p95}, p99=#{p99}"
