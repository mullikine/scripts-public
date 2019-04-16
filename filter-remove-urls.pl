#!/usr/bin/env perl

use URI::Find;

# my $string = do { local $/; <DATA> };
my $string = do { local $/; <STDIN> };

my $finder = URI::Find->new( sub { '' } );
$finder->find(\$string );

print $string;