#!/bin/bash
export TTY

# Everything to do with data conversion

# cat <<EOF | sed 's/a/b/' # pipe heredoc into sed
# foo bar baz
# EOF

# Put all of this into 'c'
# $HOME/scripts/c

perl -e 'print join("", map { sprintf("\\x%02x", ord($_)) } split(//, join("", <STDIN>)))'
perl -e 'print join("", map { "\\x" . $_ } unpack("H*", join("", <STDIN>)) =~ /.{2}/gs)'


opt="$1"
shift
case "$opt" in
    bin2hex)
    ;;

    template) {
    }
    ;;
    *)
esac


while (<>) {
    chop;
    for (my $i = 0; $i < length($_); $i += 4) {
	my $nibble = '0b'.substr($_, $i, 4);
	printf('%x', oct($nibble));
    }
    print "\n";
}


# hex -> binary

/usr/bin/perl



while (<>) {
    chop;
    for (my $i = 0; $i < length($_); $i += 1) {
	printf('%04b', hex(substr($_, $i, 1)))
    }
    print "\n";
}
