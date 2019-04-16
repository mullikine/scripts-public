#!/usr/bin/perl

# search the postions for the CpGs in human genome

sub match_positions {
    my ($regex, $string) = @_;
    return if not $string =~ /($regex)/;
    return (pos($string), pos($string) + length $1);
}
sub all_match_positions {
    my ($regex, $string) = @_;
    my @ret;
    while ($string =~ /($regex)/g) {
        push @ret, [(pos($string)-length $1),pos($string)-1];
    }
    return @ret
}

my $regex='CG';
my $string="ACGACGCGCGCG";
my $cgap=3;    
my @pos=all_match_positions($regex,$string);

my @hgcg;

foreach my $pos(@pos){
    push @hgcg,@$pos[1];
}

foreach my $i(0..($#hgcg-$cgap+1)){
    my $len=$hgcg[$i+$cgap-1]-$hgcg[$i]+2;
    print "$len\n"; 
}

# results:
# 7
# 6
# 6
