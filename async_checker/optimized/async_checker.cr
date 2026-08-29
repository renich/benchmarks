require "wait_group"

struct TaskResult
  getter latency : Int32
  getter status : Int32

  def initialize(@latency : Int32, @status : Int32)
  end
end

@[AlwaysInline]
def run_task(id : Int32) : TaskResult
  seed = ((id.to_u64 * 1664525_u64 + 1013904223_u64) & 0xFFFFFFFF_u64).to_u32
  latency = (10 + (seed % 990)).to_i32
  status = if (seed % 7) != 0
             200
           else
             (seed % 3) == 0 ? 429 : 500
           end
  TaskResult.new(latency, status)
end

def main
  tasks = 10000
  channel = Channel(TaskResult).new(1000)
  workers = 16
  wg = WaitGroup.new(workers)

  chunk_size = tasks // workers
  workers.times do |w|
    start_idx = w * chunk_size
    end_idx = (w == workers - 1) ? tasks : start_idx + chunk_size
    spawn do
      (start_idx...end_idx).each do |i|
        channel.send(run_task(i))
      end
      wg.done
    end
  end

  spawn do
    wg.wait
    channel.close
  end

  ok_count = 0
  rl_count = 0
  err_count = 0
  total_lat = 0_i64
  histogram = StaticArray(Int32, 1000).new(0)

  while res = channel.receive?
    histogram[res.latency] += 1
    total_lat += res.latency
    case res.status
    when 200 then ok_count += 1
    when 429 then rl_count += 1
    when 500 then err_count += 1
    end
  end

  # Fast O(K) percentile lookup from histogram
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
      if count < target_p50 && count + c >= target_p50
        p50 = lat
      end
      if count < target_p95 && count + c >= target_p95
        p95 = lat
      end
      if count < target_p99 && count + c >= target_p99
        p99 = lat
      end
      count += c
    end
  end

  puts "Async complete: tasks=#{tasks}, ok=#{ok_count}, rate_limited=#{rl_count}, errors=#{err_count}, latency_sum=#{total_lat}, p50=#{p50}, p95=#{p95}, p99=#{p99}"
end

main
