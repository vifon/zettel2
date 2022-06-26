#!/usr/bin/env perl

=head1 graph.pl

Generate the input for Graphviz C<dot(1)> to generate the graph of notes
in the current directory and the links between them.

=head2 USAGE

  cd ~/.deft
  .../graph.pl | dot -Tx11

or

  .../graph.pl | dot -Tpdf -o graph.pdf

=cut

use warnings;
use strict;
use 5.010;
use autodie;

use Getopt::Long;
my $tags = 1;
GetOptions(
    'tags!' => \$tags,
) or die "Bad command line arguments\n";

my %titles;
sub title (_) {
    my $filename = shift;

    if (exists($titles{$filename})) {
        $_ = $titles{$filename};
        return $_;
    }

    my $title;
    open(my $f, '<', $filename);
    while (<$f>) {
        $title = $1 and last if /^#\+TITLE:\s*(.*)/
    }
    close $f;
    $titles{$filename} = $title // $filename =~ s/\.org$//r;
    $_ = $titles{$filename};
    return $_;
}

sub all_tags {
    my @files = @_;
    my %tags;
    for ("@files" =~ /_([^_.]+)/g) {
        $tags{$_}++;
    }
    return keys %tags;
}

my @files = sort <*.org>;
my @tags = all_tags @files;


say '#!/usr/bin/env -S dot -Tx11';
say 'digraph org {';
say '  packmode = "node"';
# say '  rankdir = LR';
print "\n";

if ($tags) {
    for my $tag (@tags) {
        my @tagged_files = grep /_$tag[_.]/, @files;
        say qq(  "#$tag" [shape=box]);
        print qq(  "#$tag" -> {);
        print join " ", map {title; qq("$_")} @tagged_files;
        say '}';
        print "\n";
    }
}

for my $file (@files) {
    my $file_title = title $file;
    my $file_id = $file =~ s/^( \d{8} T? \d{6} ) -- .*/$1/xr;

    my @links = `grep -l -F ":$file_id" *.org`;
    print "\n";
    print '  {';
    print join " ", map {chomp; title; qq("$_")} @links;
    say qq(} -> "$file_title");
    say qq(  "$file_title" [URL="$file"]);
}
say '}';
