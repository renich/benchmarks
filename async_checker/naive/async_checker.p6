my $tasks = 10000;
my $ok-count = 0;
my $rl-count = 0;
my $err-count = 0;
my $total-lat = 0;
my @latencies;

for 0..^$tasks -> $i {
    my $seed = ($i * 1664525 + 1013904223) % 4294967296;
    my $lat = 10 + ($seed % 990);
    @latencies.push($lat);
    $total-lat += $lat;
    if ($seed % 7) != 0 {
        $ok-count++;
    } elsif ($seed % 3) == 0 {
        $rl-count++;
    } else {
        $err-count++;
    }
}

@latencies = @latencies.sort;
my $p50 = @latencies[floor($tasks * 0.50)];
my $p95 = @latencies[floor($tasks * 0.95)];
my $p99 = @latencies[floor($tasks * 0.99)];

say "Async complete: tasks=$tasks, ok=$ok-count, rate_limited=$rl-count, errors=$err-count, latency_sum=$total-lat, p50=$p50, p95=$p95, p99=$p99";
