function runTask(id) {
  const seed = Number((BigInt(id) * 1664525n + 1013904223n) & 0xFFFFFFFFn);
  const latency = 10 + (seed % 990);
  let status = 200;
  if ((seed % 7) === 0) {
    status = (seed % 3) === 0 ? 429 : 500;
  }
  return { latency, status };
}

async function main() {
  const tasks = 10000;
  const promises = [];

  for (let i = 0; i < tasks; i++) {
    promises.push(Promise.resolve().then(() => runTask(i)));
  }

  const results = await Promise.all(promises);

  let okCount = 0, rlCount = 0, errCount = 0;
  let totalLat = 0;
  const latencies = new Array(tasks);

  for (let i = 0; i < tasks; i++) {
    const res = results[i];
    latencies[i] = res.latency;
    totalLat += res.latency;
    if (res.status === 200) okCount++;
    else if (res.status === 429) rlCount++;
    else if (res.status === 500) errCount++;
  }

  latencies.sort((a, b) => a - b);
  const p50 = latencies[Math.floor(tasks * 0.50)];
  const p95 = latencies[Math.floor(tasks * 0.95)];
  const p99 = latencies[Math.floor(tasks * 0.99)];

  console.log(`Async complete: tasks=${tasks}, ok=${okCount}, rate_limited=${rlCount}, errors=${errCount}, latency_sum=${totalLat}, p50=${p50}, p95=${p95}, p99=${p99}`);
}

main();
