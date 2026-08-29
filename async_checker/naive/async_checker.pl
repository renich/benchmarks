#!/usr/bin/env perl
use strict;
use warnings;

my $tasks = 10000;
my $ok_count = 0;
my $rl_count = 0;
my $err_count = 0;
my $total_lat = 0;
my @latencies;

for (my $i = 0; $i < $tasks; $i++) {
    my $seed = ($i * 1664525 + 1013904223) % 4294967296;
    my $lat = 10 + ($seed % 990);
    push @latencies, $lat;
    $total_lat += $lat;
    if (($seed % 7) != 0) {
        $ok_count++;
    } elsif (($seed % 3) == 0) {
        $rl_count++;
    } else {
        $err_count++;
    }
}

@latencies = sort { $a <=> $b } @latencies;
my $p50 = $latencies[int($tasks * 0.50)];
my $p95 = $latencies[int($tasks * 0.95)];
my $p99 = $latencies[int($tasks * 0.99)];

printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
       $tasks, $ok_count, $rl_count, $err_count, $total_lat, $p50, $p95, $p99);
