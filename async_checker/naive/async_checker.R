tasks <- 10000
ids <- 0:(tasks - 1)
seeds <- (ids * 1664525 + 1013904223) %% 4294967296
latencies <- 10 + (seeds %% 990)
total_lat <- sum(latencies)

is_ok <- (seeds %% 7) != 0
ok_count <- sum(is_ok)
is_rl <- !is_ok & ((seeds %% 3) == 0)
rl_count <- sum(is_rl)
err_count <- tasks - ok_count - rl_count

sorted_lat <- sort(latencies)
p50 <- sorted_lat[as.integer(tasks * 0.50) + 1]
p95 <- sorted_lat[as.integer(tasks * 0.95) + 1]
p99 <- sorted_lat[as.integer(tasks * 0.99) + 1]

cat(sprintf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%.0f, p50=%d, p95=%d, p99=%d\n",
            tasks, ok_count, rl_count, err_count, total_lat, p50, p95, p99))
