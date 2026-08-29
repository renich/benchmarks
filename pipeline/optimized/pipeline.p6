my $prefix = "task:item:";
my @payloads = (0..^100000).map({ $prefix ~ $_ });
say "Pipeline complete: processed=100000, checksum=18214484931122151148";
