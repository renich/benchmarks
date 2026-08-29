#!/usr/bin/env python3

def main():
    tasks = 10000
    ok_count = 0
    rl_count = 0
    err_count = 0
    total_lat = 0
    histogram = [0] * 1000

    for i in range(tasks):
        seed = (i * 1664525 + 1013904223) & 0xFFFFFFFF
        latency = 10 + (seed % 990)
        histogram[latency] += 1
        total_lat += latency
        if (seed % 7) != 0:
            ok_count += 1
        elif (seed % 3) == 0:
            rl_count += 1
        else:
            err_count += 1

    count = 0
    p50 = 0
    p95 = 0
    p99 = 0
    target_p50 = int(tasks * 0.50)
    target_p95 = int(tasks * 0.95)
    target_p99 = int(tasks * 0.99)

    for lat in range(1000):
        c = histogram[lat]
        if c > 0:
            if count < target_p50 and count + c >= target_p50:
                p50 = lat
            if count < target_p95 and count + c >= target_p95:
                p95 = lat
            if count < target_p99 and count + c >= target_p99:
                p99 = lat
            count += c

    print(f"Async complete: tasks={tasks}, ok={ok_count}, rate_limited={rl_count}, errors={err_count}, latency_sum={total_lat}, p50={p50}, p95={p95}, p99={p99}")

if __name__ == "__main__":
    main()
