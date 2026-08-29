function runTask(id) {
  const seed = (Math.imul(id, 1664525) + 1013904223) >>> 0;
  const latency = 10 + (seed % 990);
  let status = 200;
  if ((seed % 7) === 0) {
    status = (seed % 3) === 0 ? 429 : 500;
  }
  return { latency, status };
}

function main() {
  const tasks = 10000;
  let okCount = 0, rlCount = 0, errCount = 0;
  let totalLat = 0;
  const histogram = new Int32Array(1000);

  for (let i = 0; i < tasks; i++) {
    const res = runTask(i);
    histogram[res.latency]++;
    totalLat += res.latency;
    if (res.status === 200) okCount++;
    else if (res.status === 429) rlCount++;
    else if (res.status === 500) errCount++;
  }

  let count = 0;
  let p50 = 0, p95 = 0, p99 = 0;
  const targetP50 = Math.floor(tasks * 0.50);
  const targetP95 = Math.floor(tasks * 0.95);
  const targetP99 = Math.floor(tasks * 0.99);

  for (let lat = 0; lat < 1000; lat++) {
    const c = histogram[lat];
    if (c > 0) {
      if (count < targetP50 && count + c >= targetP50) p50 = lat;
      if (count < targetP95 && count + c >= targetP95) p95 = lat;
      if (count < targetP99 && count + c >= targetP99) p99 = lat;
      count += c;
    }
  }

  console.log(`Async complete: tasks=${tasks}, ok=${okCount}, rate_limited=${rlCount}, errors=${errCount}, latency_sum=${totalLat}, p50=${p50}, p95=${p95}, p99=${p99}`);
}

main();
