#!/usr/bin/env perl

$| = 1; # make the current file handle (stdout) hot. This has the same effect as disabling buffering
# I CANT use unbuffer
while(<>) {
    ($revwords = $_) =~ s/(\S+)/reverse $1/ge;
    print reverse $revwords;
}
