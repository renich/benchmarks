#!/usr/bin/env perl
use strict;
use warnings;

my $prefix = "Hello, this is iteration number: ";
my $chunk = "";

for (my $n = 0; $n < 1000000; $n++) {
	$chunk .= $prefix . $n . "\n";
	if ($n % 10000 == 9999) {
		print $chunk;
		$chunk = "";
	}
}

if (length($chunk) > 0) {
	print $chunk;
}
