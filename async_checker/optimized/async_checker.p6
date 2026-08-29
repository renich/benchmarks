my $tasks = 10000;
my $ok-count = 0;
my $rl-count = 0;
my $err-count = 0;
my $total-lat = 0;
my @histogram = 0 xx 1000;

for 0..^$tasks -> $i {
    my $seed = ($i * 1664525 + 1013904223) % 4294967296;
    my $lat = 10 + ($seed % 990);
    @histogram[$lat]++;
    $total-lat += $lat;
    if ($seed % 7) != 0 {
        $ok-count++;
    } elsif ($seed % 3) == 0 {
        $rl-count++;
    } else {
        $err-count++;
    }
}

my $count = 0;
my ($p50, $p95, $p99) = (0, 0, 0);
my $target-p50 = floor($tasks * 0.50);
my $target-p95 = floor($tasks * 0.95);
my $target-p99 = floor($tasks * 0.99);

for 0..^1000 -> $lat {
    my $c = @histogram[$lat];
    if $c > 0 {
        $p50 = $lat if $count < $target-p50 && $count + $c >= $target-p50;
        $p95 = $lat if $count < $target-p95 && $count + $c >= $target-p95;
        $p99 = $lat if $count < $target-p99 && $count + $c >= $target-p99;
        $count += $c;
    }
}

say "Async complete: tasks=$tasks, ok=$ok-count, rate_limited=$rl-count, errors=$err-count, latency_sum=$total-lat, p50=$p50, p95=$p95, p99=$p99";
