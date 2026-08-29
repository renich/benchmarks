Async Task Latency & Percentile Checker Benchmark
==================================================

Description
-----------
This suite evaluates asynchronous non-blocking scheduling, pseudo-random simulated request dispatching, and dynamic latency percentile (P50, P95, P99) aggregation over 10,000 requests.

Architecture
------------
1. **Dispatcher**: Dispatches 10,000 asynchronous tasks across concurrent workers/fibers/threads.
2. **Simulation**: Each task calculates pseudo-random latency (10µs..999µs) and assigns simulated status codes (``200 OK``, ``429 Rate Limited``, ``500 Error``).
3. **Aggregator & Quantile Engine**: Tallies status counts, accumulates latency totals, and extracts exact P50/P95/P99 latency percentiles.

Structure
---------
* ``naive/``: Standard idiomatic async/await or thread queues with full $O(N \log N)$ sorting.
* ``optimized/``: High-throughput batch workers with $O(K)$ fixed array histogram binning.
