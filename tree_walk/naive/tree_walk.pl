#!/usr/bin/env perl
use strict;
use warnings;
use File::Find;

my @files;
my $data_dir = -d "tree_walk/_data" ? "tree_walk/_data" : (-d "../../_data" ? "../../_data" : (-d "../_data" ? "../_data" : "_data"));

find(sub {
    push @files, $File::Find::name if -f $_ && /\.txt$/;
}, $data_dir);

my $total_matches = 0;
for my $f (@files) {
    open my $fh, '<', $f or next;
    while (my $line = <$fh>) {
        $total_matches++ while $line =~ /category=[A-Z_]+/g;
    }
    close $fh;
}

printf("Tree walk complete: files=%d, matches=%d\n", scalar(@files), $total_matches);
