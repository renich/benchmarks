#!/usr/bin/env raku

my $prefix = "Hello, this is iteration number: ";
my $out = $*OUT;
my $buf = "";

for 0..^1000000 -> $n {
    $buf ~= "$prefix$n\n";
    if $n % 10000 == 9999 {
        $out.print($buf);
        $buf = "";
    }
}
if $buf {
    $out.print($buf);
}
