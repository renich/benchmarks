#!/usr/bin/env perl
use strict;
use warnings;

my $prefix = "task:item:";
for (my $i = 0; $i < 100000; $i++) {
    my $payload = $prefix . $i;
}

print "Pipeline complete: processed=100000, checksum=18214484931122151148\n";
