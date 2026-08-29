<?php

$tasks = 10000;
$ok_count = 0;
$rl_count = 0;
$err_count = 0;
$total_lat = 0;
$histogram = array_fill(0, 1000, 0);

for ($i = 0; $i < $tasks; $i++) {
    $seed = (int)fmod($i * 1664525 + 1013904223, 4294967296);
    $lat = 10 + ($seed % 990);
    $histogram[$lat]++;
    $total_lat += $lat;
    if (($seed % 7) != 0) {
        $ok_count++;
    } elseif (($seed % 3) == 0) {
        $rl_count++;
    } else {
        $err_count++;
    }
}

$count = 0;
$p50 = 0; $p95 = 0; $p99 = 0;
$target_p50 = (int)($tasks * 0.50);
$target_p95 = (int)($tasks * 0.95);
$target_p99 = (int)($tasks * 0.99);

for ($lat = 0; $lat < 1000; $lat++) {
    $c = $histogram[$lat];
    if ($c > 0) {
        if ($count < $target_p50 && $count + $c >= $target_p50) $p50 = $lat;
        if ($count < $target_p95 && $count + $c >= $target_p95) $p95 = $lat;
        if ($count < $target_p99 && $count + $c >= $target_p99) $p99 = $lat;
        $count += $c;
    }
}

printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
       $tasks, $ok_count, $rl_count, $err_count, $total_lat, $p50, $p95, $p99);
