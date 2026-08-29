<?php

$tasks = 10000;
$ok_count = 0;
$rl_count = 0;
$err_count = 0;
$total_lat = 0;
$latencies = [];

for ($i = 0; $i < $tasks; $i++) {
    $seed = (int)fmod($i * 1664525 + 1013904223, 4294967296);
    $lat = 10 + ($seed % 990);
    $latencies[] = $lat;
    $total_lat += $lat;
    if (($seed % 7) != 0) {
        $ok_count++;
    } elseif (($seed % 3) == 0) {
        $rl_count++;
    } else {
        $err_count++;
    }
}

sort($latencies);
$p50 = $latencies[(int)($tasks * 0.50)];
$p95 = $latencies[(int)($tasks * 0.95)];
$p99 = $latencies[(int)($tasks * 0.99)];

printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
       $tasks, $ok_count, $rl_count, $err_count, $total_lat, $p50, $p95, $p99);
