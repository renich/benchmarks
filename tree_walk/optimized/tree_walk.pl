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
local $/ = undef;
for my $f (@files) {
    open my $fh, '<:raw', $f or next;
    my $content = <$fh>;
    close $fh;
    my $pos = 0;
    while (($pos = index($content, 'category=', $pos)) != -1) {
        $total_matches++;
        $pos += 9;
    }
}

printf("Tree walk complete: files=%d, matches=%d\n", scalar(@files), $total_matches);
