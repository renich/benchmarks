sub find-files(IO::Path $dir) {
    my @files;
    return @files unless $dir.d;
    for $dir.dir -> $entry {
        if $entry.d {
            @files.append(find-files($entry));
        } elsif $entry.extension eq "txt" {
            @files.push($entry);
        }
    }
    return @files;
}

my $data-dir = "tree_walk/_data".IO;
unless $data-dir.d {
    if "../../_data".IO.d { $data-dir = "../../_data".IO; }
    elsif "../_data".IO.d { $data-dir = "../_data".IO; }
    elsif "_data".IO.d { $data-dir = "_data".IO; }
}

my @files = find-files($data-dir);
my $total-matches = 0;
my $needle = "category=";

for @files -> $f {
    my $content = $f.slurp;
    my $pos = 0;
    while ($pos = $content.index($needle, $pos)).defined {
        $total-matches++;
        $pos += 9;
    }
}

say "Tree walk complete: files={@files.elems}, matches=$total-matches";
