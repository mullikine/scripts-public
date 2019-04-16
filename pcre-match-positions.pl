#!/usr/bin/env perl
use JSON;

sub match_all_positions {
    my ($regex, $string) = @_;
    my @ret;
    while ($string =~ /$regex/g) {
        push @ret, [ $-[0], $+[0] ];
    }
    return @ret
}

my $str = do { local $/; <STDIN> };

my @arr = match_all_positions('a', $str);
my $json_str = encode_json(\@arr);  # This will work now

print "$json_str";
print "\n";

my @pos=match_all_positions($regex,$string);

my @hgcg;

foreach my $pos(@pos){
    push @hgcg,@$pos[1];
}

foreach my $i(0..($#hgcg-$cgap+1)){
    my $len=$hgcg[$i+$cgap-1]-$hgcg[$i]+2;
    print "$len\n"; 
}

