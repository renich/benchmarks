#!/usr/bin/env perl
use strict;
use warnings;

my $tasks = 10000;
my $ok_count = 0;
my $rl_count = 0;
my $err_count = 0;
my $total_lat = 0;
my @histogram = (0) x 1000;

for (my $i = 0; $i < $tasks; $i++) {
    my $seed = ($i * 1664525 + 1013904223) % 4294967296;
    my $lat = 10 + ($seed % 990);
    $histogram[$lat]++;
    $total_lat += $lat;
    if (($seed % 7) != 0) {
        $ok_count++;
    } elsif (($seed % 3) == 0) {
        $rl_count++;
    } else {
        $err_count++;
    }
}

my $count = 0;
my ($p50, $p95, $p99) = (0, 0, 0);
my $target_p50 = int($tasks * 0.50);
my $target_p95 = int($tasks * 0.95);
my $target_p99 = int($tasks * 0.99);

for my $lat (0..999) {
    my $c = $histogram[$lat];
    if ($c > 0) {
        $p50 = $lat if $count < $target_p50 && $count + $c >= $target_p50;
        $p95 = $lat if $count < $target_p95 && $count + $c >= $target_p95;
        $p99 = $lat if $count < $target_p99 && $count + $c >= $target_p99;
        $count += $c;
    }
}

printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
       $tasks, $ok_count, $rl_count, $err_count, $total_lat, $p50, $p95, $p99);
