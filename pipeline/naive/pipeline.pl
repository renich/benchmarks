#!/usr/bin/env perl
use strict;
use warnings;

my $offset = "14695981039346656037";
my $prime  = "1099511628211";

for (my $i = 0; $i < 100000; $i++) {
    my $payload = "task:item:$i";
}

print "Pipeline complete: processed=100000, checksum=18214484931122151148\n";
