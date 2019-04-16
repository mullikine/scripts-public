#!/usr/bin/env perl

# $VAS/projects/scripts/scrape-words-from-string.pl
use strict;
use Getopt::Std;

# declare the perl command line flags/options we want to allow
my %options=();
getopts("r:", \%options);

my $r = '\w+';

if (defined $options{r}) {
    $r = "$options{r}";
}

#print $options{r};
#print $r;
#
#exit 0;

$| = 1; # make the current file handle (stdout) hot. This has the same effect as disabling buffering
# I CANT use unbuffer
while(<>) {
    while ($_ =~ /($r)/g) {
        print "$1\n";
    }
}
