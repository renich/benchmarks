#!/usr/bin/env python3
import threading
import queue

def run_task(task_id: int):
    seed = (task_id * 1664525 + 1013904223) & 0xFFFFFFFF
    latency = 10 + (seed % 990)
    if (seed % 7) != 0:
        status = 200
    else:
        status = 429 if (seed % 3) == 0 else 500
    return latency, status

def main():
    tasks = 10000
    workers = 16
    res_q = queue.Queue(maxsize=1000)
    chunk_size = tasks // workers
    threads = []

    def worker(start, end):
        for i in range(start, end):
            res_q.put(run_task(i))

    for w in range(workers):
        start = w * chunk_size
        end = tasks if w == workers - 1 else start + chunk_size
        t = threading.Thread(target=worker, args=(start, end))
        t.start()
        threads.append(t)

    ok_count = 0
    rl_count = 0
    err_count = 0
    total_lat = 0
    latencies = []

    for _ in range(tasks):
        lat, status = res_q.get()
        latencies.append(lat)
        total_lat += lat
        if status == 200:
            ok_count += 1
        elif status == 429:
            rl_count += 1
        elif status == 500:
            err_count += 1
        res_q.task_done()

    for t in threads:
        t.join()

    latencies.sort()
    p50 = latencies[int(tasks * 0.50)]
    p95 = latencies[int(tasks * 0.95)]
    p99 = latencies[int(tasks * 0.99)]

    print(f"Async complete: tasks={tasks}, ok={ok_count}, rate_limited={rl_count}, errors={err_count}, latency_sum={total_lat}, p50={p50}, p95={p95}, p99={p99}")

if __name__ == "__main__":
    main()
