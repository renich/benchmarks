type
  TaskResult = object
    latency: int
    status: int

proc runTask(id: int): TaskResult {.inline.} =
  let seed = ((uint64(id) * 1664525'u64 + 1013904223'u64) and 0xFFFFFFFF'u64).uint32
  let latency = int(10 + (seed mod 990))
  var status = 200
  if (seed mod 7) == 0:
    status = if (seed mod 3) == 0: 429 else: 500
  result = TaskResult(latency: latency, status: status)

proc main() =
  let tasks = 10000
  var okCount = 0
  var rlCount = 0
  var errCount = 0
  var totalLat = 0'i64
  var histogram: array[1000, int]

  for i in 0 ..< tasks:
    let res = runTask(i)
    inc(histogram[res.latency])
    totalLat += res.latency
    case res.status
    of 200: inc(okCount)
    of 429: inc(rlCount)
    of 500: inc(errCount)
    else: discard

  var count = 0
  var p50, p95, p99 = 0
  let targetP50 = int(float(tasks) * 0.50)
  let targetP95 = int(float(tasks) * 0.95)
  let targetP99 = int(float(tasks) * 0.99)

  for lat in 0 ..< 1000:
    let c = histogram[lat]
    if c > 0:
      if count < targetP50 and count + c >= targetP50: p50 = lat
      if count < targetP95 and count + c >= targetP95: p95 = lat
      if count < targetP99 and count + c >= targetP99: p99 = lat
      count += c

  echo "Async complete: tasks=", tasks, ", ok=", okCount, ", rate_limited=", rlCount, ", errors=", errCount, ", latency_sum=", totalLat, ", p50=", p50, ", p95=", p95, ", p99=", p99

main()
