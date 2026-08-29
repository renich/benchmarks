#!/usr/bin/env ruby

tasks = 10000
ok_count = 0
rl_count = 0
err_count = 0
total_lat = 0
histogram = Array.new(1000, 0)

tasks.times do |i|
  seed = (i * 1664525 + 1013904223) & 0xFFFFFFFF
  latency = 10 + (seed % 990)
  histogram[latency] += 1
  total_lat += latency
  if (seed % 7) != 0
    ok_count += 1
  elsif (seed % 3) == 0
    rl_count += 1
  else
    err_count += 1
  end
end

count = 0
p50 = 0
p95 = 0
p99 = 0
target_p50 = (tasks * 0.50).to_i
target_p95 = (tasks * 0.95).to_i
target_p99 = (tasks * 0.99).to_i

1000.times do |lat|
  c = histogram[lat]
  if c > 0
    p50 = lat if count < target_p50 && count + c >= target_p50
    p95 = lat if count < target_p95 && count + c >= target_p95
    p99 = lat if count < target_p99 && count + c >= target_p99
    count += c
  end
end

puts "Async complete: tasks=#{tasks}, ok=#{ok_count}, rate_limited=#{rl_count}, errors=#{err_count}, latency_sum=#{total_lat}, p50=#{p50}, p95=#{p95}, p99=#{p99}"
