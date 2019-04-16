#!/usr/bin/perl -w
# slirc.pl: local Slack IRC gateway
# Copyright (C) 2017 Daniel Beer <dlbeer@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# To run, create a configuration file with the following content:
#
#     slack_token=<legacy API token>
#     password=<password of your choice>
#     port=<port>
#
# Then run ./slirc.pl <config-file>. Connect to the chosen port on
# 127.0.0.1 with your chosen password.
#
# Updated 2018-05-15 to add support for listening on Unix domain sockets
# by Colin Watson <cjwatson@chiark.greenend.org.uk>. To use this feature
# with an IRC client supporting Unix domain connections, add the line
# "unix_socket=<path>" to the config file.

use strict;
use warnings;
use utf8;

use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::WebSocket::Client;
use URI::Encode qw(uri_encode);
use Data::Dumper;
use Digest::SHA qw(sha256);
use JSON;

my $VERSION = "20171127";
my $start_time = time();
my %config;

########################################################################
# Global chat state
########################################################################

my $connected;			# Is the RTM connection ready?
my $self_id;			# Slack ID of our own user, or undef if not connected

my %channels;			# Slack ID -> channel hash ref
my %channels_by_name;		# irc_lcase -> channel hash ref
# Properties:
# - Id: Slack ID
# - Members: Slack ID set
# - Name: text (IRC name)
# - Topic: text

my %users;			# Slack ID -> user hash ref
my %users_by_name;		# irc_lcase -> user hash ref
my %users_by_dmid;              # Slack DMID -> user hash ref
# Properties:
# - Id: Slack ID
# - Name: text (IRC name)
# - Channels: Slack ID set
# - Realname: text
# - DMId: DM session ID (may be undefined, or blank if open in progress)
# - TxQueue: messages awaiting transmission if no DM open

########################################################################
# IRC names
########################################################################

# Canonicalize an IRC name
sub irc_lcase {
    my $name = lc(shift);

    $name =~ s/\[/{/g;
    $name =~ s/]/}/g;
    $name =~ s/\|/\\/g;
    $name =~ s/\^/~/g;

    return $name;
}

# Compare two names
sub irc_eq {
    my ($a, $b) = @_;

    return irc_lcase($a) eq irc_lcase($b);
}

# Choose an unused valid name with reference to the hash
sub irc_pick_name {
    my ($name, $hash) = @_;

    $name =~ s/[#,<>!\0\r\n: ]/_/g;

    return $name if length($name) && irc_lcase($name) ne "x" &&
	!defined($hash->{irc_lcase($name)});

    my $i = 1;

    for (;;) {
	my $prop = "$name$i";

	return $prop unless !defined($hash->{irc_lcase($prop)});
	$i++;
    }
}

########################################################################
# IRC server
########################################################################

# Forward decls to RTM subsystem
sub rtm_send;
sub rtm_send_to_user;
sub rtm_apicall;
sub rtm_download;
sub rtm_destroy;

my %irc_clients;

sub irc_send_args {
    my ($c, $source, $short, $long) = @_;

    $source =~ s/[\t\r\n\0 ]//g;
    $source =~ s/^://g;
    my @arg = (":$source");

    for my $a (@$short) {
	$a =~ s/[\t\r\n\0 ]//g;
	$a =~ s/^://g;
	utf8::encode($a);
	$a = "*" unless length($a);
	push @arg, $a;
    }

    if (defined($long)) {
	$long =~ s/[\r\n\0]/ /g;
	utf8::encode($long);
	push @arg, ":$long";
    }

    my $line = join(' ', @arg);
    print "IRC $c->{Handle} SEND: $line\n";
    $c->{Handle}->push_write("$line\r\n");
}

sub irc_send_num {
    my ($c, $num, $short, $long) = @_;
    my $dst = $c->{Nick};

    $dst = "*" unless defined($c->{Nick});
    irc_send_args $c, "localhost",
	[sprintf("%03d", $num), $dst, @$short], $long;
}

sub irc_send_from {
    my ($c, $uid, $short, $long) = @_;
    my $user = $users{$uid};
    my $nick = $uid eq $self_id ? $c->{Nick} : $user->{Name};

    irc_send_args $c, "$nick!$user->{Id}\@localhost", $short, $long;
}

sub irc_disconnect {
    my ($c, $msg) = @_;

    print "IRC $c->{Handle} DISCONNECT: $msg\n";
    delete $irc_clients{$c->{Handle}};
    $c->{Handle}->destroy;
}

sub irc_disconnect_all {
    print "IRC: disconnect all\n";
    foreach my $k (keys %irc_clients) {
	$irc_clients{$k}->{Handle}->destroy;
    }
    %irc_clients = ();
}

sub irc_send_names {
    my ($c, $chan) = @_;
    my $i = 0;
    my @ulist = keys %{$chan->{Members}};

    while ($i < @ulist) {
	my $n = @ulist - $i;
	$n = 8 if $n > 8;
	my $chunk = join(' ', map {
	    $_ eq $self_id ? $c->{Nick} : $users{$_}->{Name}
	} @ulist[$i .. ($i + $n - 1)]);
	irc_send_num $c, 353, ['@', "#$chan->{Name}"], $chunk;
	$i += $n;
    }

    irc_send_num $c, 366, ["#$chan->{Name}"], "End of /NAMES list";
}

sub irc_server_notice {
    my ($c, $msg) = @_;
    my $nick = $c->{Nick};

    $nick = "*" unless defined($nick);
    irc_send_args $c, "localhost", ["NOTICE", $nick], $msg;
}

sub irc_gateway_notice {
    my ($c, $msg) = @_;
    my $nick = $c->{Nick};

    $nick = "*" unless defined($nick);
    irc_send_args $c, "X!X\@localhost", ["NOTICE", $nick], $msg;
}

sub irc_notify_away {
    my $c = shift;
    my $user = $users{$self_id};
    my ($num, $msg);

    if ($user->{Presence} eq 'away') {
	$num = 306;
	$msg = "You have been marked as being away";
    } else {
	$num = 305;
	$msg = "You are no longer marked as being away";
    }

    irc_send_num $c, $num, [], $msg if $c->{Ready};
}

sub irc_broadcast_away {
    for my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	irc_notify_away $c if $c->{Ready};
    }
}

sub irc_check_welcome {
    my $c = shift;

    if (defined $c->{Nick} && defined $c->{User} &&
	(!$config{password} || defined $c->{Password}) &&
	!$c->{Authed}) {
	if (!$config{password} ||
	    sha256($c->{Password}) eq sha256($config{password})) {
	    $c->{Authed} = 1;
	} else {
	    irc_server_notice $c, "Incorrect password";
	    irc_disconnect $c, "Incorrect password";
	    return;
	}
    }

    return unless $c->{Authed} && !$c->{Ready} && $connected;

    my $u = $users_by_name{irc_lcase($c->{Nick})};
    if (defined($u) && ($u->{Id} ne $self_id)) {
	irc_server_notice $c, "Nick already in use";
	irc_disconnect $c, "Nick already in use";
	return;
    }

    irc_send_num $c, 001, [], "slirc.pl version $VERSION";
    irc_send_num $c, 002, [],
      "Copyright (C) 2017 Daniel Beer <dlbeer\@gmail.com>";
    irc_send_num $c, 003, [], `uptime`;
    $c->{Ready} = 1;

    my $user = $users{$self_id};

    for my $k (keys %{$user->{Channels}}) {
	my $chan = $channels{$k};
	irc_send_from $c, $self_id, ["JOIN", "#$chan->{Name}"];
	irc_send_num $c, 332, ["#$chan->{Name}"], $chan->{"Topic"};
	irc_send_names $c, $chan;
    }

    irc_notify_away $c;
}

sub irc_check_welcome_all {
    foreach my $k (keys %irc_clients) {
	irc_check_welcome $irc_clients{$k};
    }
}

sub irc_broadcast_nick {
    my ($id, $newname) = @_;
    return if $id eq $self_id;

    for my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	irc_send_from $c, $id, ["NICK", $newname] if $c->{Ready};
    }
}

sub irc_broadcast_join {
    my ($uid, $chid) = @_;
    my $chan = $channels{$chid};

    for my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	next unless $c->{Ready};

	if ($uid eq $self_id) {
	    irc_send_from $c, $self_id, ["JOIN", "#$chan->{Name}"];
	    irc_send_num $c, 332, ["#$chan->{Name}"], $chan->{Topic};
	    irc_send_names $c, $chan;
	} else {
	    irc_send_from $c, $uid, ["JOIN", "#$chan->{Name}"];
	}
    }
}

sub irc_broadcast_part {
    my ($uid, $chid) = @_;
    my $chan = $channels{$chid};

    for my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	next unless $c->{Ready};
	irc_send_from $c, $uid, ["PART", "#$chan->{Name}"];
    }
}

sub irc_send_who {
    my ($c, $chname, $u) = @_;

    my $user = $users{$u};
    my $nick = $u eq $self_id ? $c->{Nick} : $user->{Name};
    my $here = $user->{Presence} eq 'away' ? 'G' : 'H';

    irc_send_num $c, 352, [$chname, $user->{Id}, "localhost", "localhost",
			   $nick, $here], "0 $user->{Realname}";
}

sub irc_send_whois {
    my ($c, $uid) = @_;
    my $u = $users{$uid};
    my $nick = $uid eq $self_id ? $c->{Nick} : $u->{Name};

    irc_send_num $c, 311,
	[$nick, $u->{Id}, "localhost", "*"], $u->{Realname};
    irc_send_num $c, 312, [$nick, "localhost"], "slirc.pl";
    my $clist = join(' ', map { "#" . $channels{$_}->{Name} }
			  keys %{$u->{Channels}});
    irc_send_num $c, 319, [$nick], $clist;
    irc_send_num $c, 301, [$nick], "away" if $u->{Presence} eq 'away';
}

sub irc_invite_or_kick {
    my ($c, $action, $name, $chname) = @_;

    $chname =~ s/^#//;
    my $chan = $channels_by_name{irc_lcase($chname)};

    unless (defined $chan) {
	irc_send_num $c, 401, ["#$chname"], "No such nick/channel";
	return;
    }

    my $what = $chan->{Type} eq "C" ? "channels" : "groups";

    foreach (split(/,/, $name)) {
	my $user = $users_by_name{irc_lcase($_)};

	if (defined $user) {
	    rtm_apicall "$what.$action", { user => $user->{Id},
					   channel => $chan->{Id} };
	} else {
	    irc_send_num $c, 401, [$user], "No such nick/channel";
	}
    }
}

my %gateway_command = (
    "newgroup" => sub {
	my ($c, $name) = @_;
	unless (defined($name)) {
	    irc_gateway_notice $c, "Syntax: newgroup <name>";
	    return;
	}
	$name =~ s/^#//;
	irc_gateway_notice $c, "Creating group $name";
	rtm_apicall "groups.create", { name => $name };
    },
    "newchan" => sub {
	my ($c, $name) = @_;
	unless (defined($name)) {
	    irc_gateway_notice $c, "Syntax: newchan <name>";
	    return;
	}
	$name =~ s/^#//;
	irc_gateway_notice $c, "Creating channel $name";
	rtm_apicall "channels.create", { name => $name };
    },
    "archive" => sub{
	my ($c, $name) = @_;
	unless (defined($name)) {
	    irc_gateway_notice $c, "Syntax: archive <name>";
	    return;
	}
	$name =~ s/^#//;
	my $g = $channels_by_name{irc_lcase($name)};
	my $what = $g->{Type} eq "C" ? "channels" : "groups";
	if (defined $g) {
	    irc_gateway_notice $c, "Archiving $name";
	    rtm_apicall "$what.archive", { channel => $g->{Id} };
	} else {
	    irc_gateway_notice $c, "No such channel: $name";
	}
    },
    "close" => sub{
	my ($c, $name) = @_;
	unless (defined($name)) {
	    irc_gateway_notice $c, "Syntax: close <name>";
	    return;
	}

	$name =~ s/^#//;
	my $g = $channels_by_name{irc_lcase($name)};
	my $what = $g->{Type} eq "C" ? "channels" : "groups";
	if (defined $g) {
	    irc_gateway_notice $c, "Closing $name";
	    rtm_apicall "$what.close", { channel => $g->{Id} };
	} else {
	    irc_gateway_notice $c, "No such channel: $name";
	}
    },
    "cat" => sub {
	my ($c, $fileid) = @_;
	unless (defined($fileid)) {
	    irc_gateway_notice $c, "Syntax: catfile <fileid> <filename>";
	    return;
	}

	rtm_apicall "files.info", { file => $fileid }, sub {
	    my $data = shift;
	    return unless defined $data;

	    my $body = $data->{content};

	    if (length($body) > 65536) {
		irc_gateway_notice $c, "File too big";
	    } else {
		irc_gateway_notice $c, "---- BEGIN $fileid ----";
		foreach (split(/\n/, $body)) {
		    irc_gateway_notice $c, "$_";
		}
		irc_gateway_notice $c, "---- END $fileid ----";
	    }
	};
    },
    "disconnect" => sub {
	my ($c) = @_;
	irc_gateway_notice $c, "Disconnecting";
	rtm_destroy "User disconnection request";
    },
    "delim" => sub {
	my ($c, $nick) = @_;
	unless (defined($nick)) {
	    irc_gateway_notice $c, "Syntax: delim <name>";
	    return;
	}
	my $user;

	if ($nick eq $c->{Nick}) {
	    $user = $users{$self_id};
	} else {
	    $user = $users_by_name{irc_lcase($nick)};
	    $user = undef if $user->{Id} eq $self_id;
	}

	unless (defined($user)) {
	    irc_gateway_notice $c, "No such nick: $nick";
	    return;
	}

	unless (defined $user->{DMId}) {
	    irc_gateway_notice $c, "DM already closed for $nick";
	    return;
	}

	irc_gateway_notice $c, "Closing DM for $nick";
	rtm_apicall "im.close", { channel => $user->{DMId} };
    },
);

my %irc_command = (
    "NICK" => sub {
	my ($c, $newnick) = @_;
	return unless defined($newnick);

	if (defined $c->{Nick}) {
	    my $u = $users_by_name{irc_lcase($newnick)};
	    if (defined($u) && ($u->{Id} ne $self_id)) {
		irc_send_num $c, 433, [$newnick], "Nickname is already in use";
	    } else {
		irc_send_from $c, $self_id, ["NICK"], $newnick;
		$c->{Nick} = $newnick;
	    }
	} else {
	    $c->{Nick} = $newnick;
	    irc_check_welcome $c;
	}
    },
    "PASS" => sub {
	my ($c, $pass) = @_;

	$c->{Password} = $pass;
	irc_check_welcome $c;
    },
    "USER" => sub {
	my ($c, @arg) = @_;
	return unless scalar(@arg) >= 4;

	$c->{User} = $arg[0];
	$c->{Realname} = $arg[3];
	irc_check_welcome $c;
    },
    "AWAY" => sub {
	my ($c, $msg) = @_;
	return unless $c->{Ready};
	my $presence = defined $msg ? "away" : "auto";
	rtm_apicall "users.setPresence", { presence => $presence };
    },
    "PING" => sub {
	my ($c, $reply) = @_;
	$reply = "" unless defined($reply);
	irc_send_args $c, "localhost", ["PONG"], $reply;
    },
    "INVITE" => sub {
	my ($c, $name, $chname) = @_;
	return unless $c->{Ready};
	irc_invite_or_kick $c, "invite", $name, $chname;
    },
    "KICK" => sub {
	my ($c, $name, $chname) = @_;
	return unless $c->{Ready};
	irc_invite_or_kick $c, "kick", $name, $chname;
    },
    "JOIN" => sub {
	my ($c, $name) = @_;
	return unless $c->{Ready};
	return unless defined($name);

	foreach my $n (split(/,/, $name)) {
	    $n =~ s/^#//;
	    my $chan = $channels_by_name{irc_lcase($n)};
	    if (not defined $chan) {
		irc_send_num $c, 401, ["#$n"], "No such nick/channel";
	    } elsif ($chan->{Members}->{$self_id}) {
		# Already joined
	    } elsif ($chan->{Type} eq "G") {
		irc_send_num $c, 473, ["#$n"],
		    "<channel> :Cannot join channel (+i)";
	    } else {
		rtm_apicall "channels.join", { channel => $chan->{Id} };
	    }
	}
    },
    "MODE" => sub {
	my ($c, $arg, $what) = @_;
	return unless $c->{Ready};
	return unless defined($arg);

	$what = $what || "";

	if ($arg eq $c->{Nick}) {
	    irc_send_num $c, 221, [], "+i";
	} elsif ($arg =~ /^#(.*)$/) {
	    my $chan = $channels_by_name{$1};

	    if (defined $chan) {
		if ($what eq "b") {
		    irc_send_num $c, 368, ["#$chan->{Name}"],
			"End of channel ban list";
		} else {
		    irc_send_num $c, 324,
			["#$chan->{Name}",
			 ($chan->{Type} eq "G" ? "+ip" : "+p")];
		    irc_send_num $c, 329,
			["#$chan->{Name}", $start_time];
		}
	    } else {
		irc_send_num $c, 403, [$arg], "No such channel";
	    }
	} else {
	    irc_send_num $c, 403, [$arg], "No such channel";
	}
    },
    "TOPIC" => sub {
	my ($c, $name, $topic) = @_;
	return unless defined($name) && defined($topic);
	return unless $c->{Ready};

	$name =~ s/^#//;
	my $chan = $channels_by_name{irc_lcase($name)};
	unless (defined($chan)) {
	    irc_send_num $c, 401, ["#$name"], "No such nick/channel";
	    return;
	}

	my $what = $chan->{Type} eq "C" ? "channels" : "groups";

	rtm_apicall "$what.setTopic", { channel => $chan->{Id},
					topic => $topic };
    },
    "PART" => sub {
	my ($c, $name) = @_;
	return unless $c->{Ready};
	return unless defined($name);

	foreach my $n (split(/,/, $name)) {
	    $n =~ s/^#//;
	    my $chan = $channels_by_name{irc_lcase($n)};
	    if (not defined($chan)) {
		irc_send_num $c, 401, ["#$n"], "No such nick/channel";
	    } elsif ($chan->{Members}->{$self_id}) {
		my $what = $chan->{Type} eq "C" ? "channels" : "groups";
		rtm_apicall "$what.leave", { channel => $chan->{Id} };
	    }
	}
    },
    "LIST" => sub {
	my ($c, @arg) = @_;
	return unless $c->{Ready};

	irc_send_num $c, 321, ["Channel"], "Users Name";
	foreach my $chid (keys %channels) {
	    my $chan = $channels{$chid};
	    my $n = keys %{$chan->{Members}};

	    irc_send_num $c, 322, ["#$chan->{Name}", $n], $chan->{Topic};
	}
	irc_send_num $c, 323, [], "End of /LIST";
    },
    "WHOIS" => sub {
	my ($c, $nicklist) = @_;
	return unless $c->{Ready};
	return unless defined($nicklist);
	my $some = 0;

	for my $nick (split(/,/, $nicklist)) {
	    if (irc_eq($nick, "x")) {
		irc_send_num $c, 311,
		    ["X", "X", "localhost", "*"], "Gateway service";
		irc_send_num $c, 312, ["X", "localhost"], "slirc.pl";
	    } elsif (irc_eq($nick, $c->{Nick})) {
		irc_send_whois $c, $self_id;
	    } else {
		my $user;

		if ($nick =~ /^.*!([^@]*)/) {
		    $user = $users{$1};
		} else {
		    $user = $users_by_name{irc_lcase($nick)};
		    $user = undef if defined($user) && $user->{Id} eq $self_id;
		}

		if (defined($user)) {
		    irc_send_whois $c, $user->{Id};
		} else {
		    irc_send_num $c, 401, [$nick], "No such nick/channel";
		}
	    }
	}

	irc_send_num $c, 318, [$nicklist], "End of /WHOIS list";
    },
    "NAMES" => sub {
	my ($c, $name) = @_;
	return unless $c->{Ready};
	return unless defined($name);

	my $n = $name;
	$n =~ s/^#//;
	my $chan = $channels_by_name{irc_lcase($n)};
	unless (defined($chan)) {
	    irc_send_num $c, 401, [$name], "No such nick/channel";
	    return;
	}

	irc_send_names $c, $chan;
    },
    "WHO" => sub {
	my ($c, $name) = @_;
	return unless $c->{Ready};

	if (!defined($name)) {
	    foreach my $u (keys %users) {
		irc_send_who $c, "*", $u;
	    }
	    irc_send_num $c, 352, ["*", "X", "localhost", "localhost",
				   "X", "H"], "0 Gateway service";
	} elsif (irc_eq($name, "X")) {
	    irc_send_num $c, 352, ["*", "X", "localhost", "localhost",
				   "X", "H"], "0 Gateway service";
	} elsif ($name =~ /^.*!([^@]*)/) {
	    unless (exists $users{$1}) {
		irc_send_num $c, 401, [$name], "No such nick/channel";
		return;
	    }

	    irc_send_who $c, $name, $1;
	} elsif ($name =~ /^#(.*)$/) {
	    my $chan = $channels_by_name{irc_lcase($1)};

	    unless (defined($chan)) {
		irc_send_num $c, 401, [$name], "No such nick/channel";
		return;
	    }

	    foreach my $u (keys %{$chan->{Members}}) {
		irc_send_who $c, "#$chan->{Name}", $u;
	    }
	} else {
	    my $user = $users_by_name{irc_lcase($name)};

	    unless (defined($user)) {
		irc_send_num $c, 401, [$name], "No such nick/channel";
		return;
	    }

	    irc_send_who $c, $name, $self_id;
	}

	$name = "*" unless defined($name);
	irc_send_num $c, 315, [$name], "End of /WHO list";
    },
    "PRIVMSG" => sub {
	my ($c, $namelist, $msg) = @_;
	return unless $c->{Ready};
	return unless defined($namelist) && defined($msg);

	$msg =~ s/<@([^>]+)>/'<@' . irc_name_to_id($c, $1) . '>'/eg;
	$msg =~ s/<#([^>]+)>/'<@' . irc_chan_to_id($c, $1) . '>'/eg;

	foreach my $name (split(/,/, $namelist)) {
	    if (irc_eq($name, "X")) {
		my @args = split(/  */, $msg);
		my $cmd = shift @args;
		my $handler = $gateway_command{lc($cmd)};

		if (defined $handler) {
		    $handler->($c, @args);
		} else {
		    irc_gateway_notice $c, "Unknown command: $cmd";
		}
	    } elsif ($name =~ /^#(.*)$/) {
		my $chan = $channels_by_name{irc_lcase($1)};

		if (defined $chan) {
		    rtm_send {
			type => "message", channel => $chan->{Id},
			text => $msg };
		} else {
		    irc_send_num $c, 401, [$name], "No such nick/channel";
		}
	    } elsif (irc_eq($name, $c->{Nick})) {
		rtm_send_to_user $self_id, $msg;
	    } else {
		my $user = $users_by_name{irc_lcase($name)};

		if (defined $user) {
		    rtm_send_to_user $user->{Id}, $msg;
		} else {
		    irc_send_num $c, 401, [$name], "No such nick/channel";
		}
	    }
	}
    },
    "PONG" => sub {
	shift->{PingCount} = 0;
    },
    "QUIT" => sub {
	my $c = shift;
	irc_disconnect $c, "QUIT";
    },
);

sub irc_broadcast_notice {
    my ($msg) = @_;

    print "NOTICE: $msg\n";
    foreach my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	irc_server_notice $c, $msg if $c->{Authed};
    }
}

sub irc_id_to_name {
    my ($c, $id) = @_;
    return $c->{Nick} if $id eq $self_id;
    my $u = $users{$id};
    return $u->{Name} if defined($u);
    return $id;
}

sub irc_name_to_id {
    my ($c, $name) = @_;
    return $self_id if $name eq $c->{Nick};
    my $u = $users_by_name{$name};
    return $u->{Id} if defined($u);
    return $name;
}

sub irc_id_to_chan {
    my ($c, $id) = @_;
    my $ch = $channels{$id};
    return $ch->{Name} if defined ($ch);
    return $id;
}

sub irc_chan_to_id {
    my ($c, $chan) = @_;
    my $ch = $channels_by_name{$chan};
    return $ch->{Id} if defined($ch);
    return $chan;
}

sub irc_do_message {
    my ($srcid, $dstname, $subtype, $text) = @_;

    $text =~ s/\002//g;
    my $prefix = "";
    $prefix = "\002[$subtype]\002 " if defined($subtype);

    for my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};
	next unless $c->{Ready};

	my $translate = $text;
	$translate =~ s/<@([^>]+)>/'<@' . irc_id_to_name($c, $1) . '>'/eg;
	$translate =~ s/<#([^>]+)>/'<@' . irc_id_to_chan($c, $1) . '>'/eg;

	for my $line (split(/\n/, $translate)) {
	    irc_send_from $c, $srcid, ["PRIVMSG", $dstname], "$prefix$line";
	}
    }
}

sub irc_privmsg {
    my ($id, $subtype, $msg) = @_;
    irc_do_message $id, $users{$id}->{Name}, $subtype, $msg;
}

sub irc_chanmsg {
    my ($id, $subtype, $chid, $msg) = @_;
    irc_do_message $id, "#$channels{$chid}->{Name}", $subtype, $msg;
}

sub irc_topic_change {
    my ($id, $chid) = @_;
    my $chan = $channels{$chid};

    foreach my $k (keys %irc_clients) {
	my $c = $irc_clients{$k};

	irc_send_from $c, $id, ["TOPIC", "#$chan->{Name}"], $chan->{Topic}
	    if $c->{Ready};
    }
}

sub irc_ping {
    my $c = shift;

    if (++$c->{PingCount} >= 2) {
	irc_disconnect $c, "Ping timeout";
	return;
    }

    irc_send_args $c, "localhost", ["PING"], time();
    $c->{PingTimer} = AnyEvent->timer(after => 60, cb => sub { irc_ping($c); });
}

sub irc_line {
    my ($c, $fh, $line, $eol) = @_;

    print "IRC $fh RECV: $line\n";

    utf8::decode($line);

    my $smallargs = $line;
    my $bigarg = undef;

    if ($line =~ /^(.*?) :(.*)$/) {
	$smallargs = $1;
	$bigarg = $2;
    }

    my @words = split /  */, $smallargs;
    push @words, $bigarg if defined($bigarg);

    if (scalar(@words)) {
	my $cmd = shift @words;
	my $handler = $irc_command{uc($cmd)};

	$handler->($c, @words) if (defined($handler));
    }

    $fh->push_read(line => sub { irc_line($c, @_) });
}

sub irc_listen {
    print "Start IRC listener\n";
    my $listen_host = $config{unix_socket} ? "unix/" : "127.0.0.1";
    tcp_server $listen_host,
	       ($config{unix_socket} || $config{port} || 6667), sub {
	my ($fd, $host, $port) = @_;

	my $fh;
	$fh = new AnyEvent::Handle
	  fh => $fd,
	  on_error => sub {
	      my ($fh, $fatal, $msg) = @_;
	      irc_disconnect $irc_clients{$fh}, "error: $msg";
	  },
	  on_eof => sub {
	      my $fh = shift;
	      irc_disconnect $irc_clients{$fh}, "EOF";
	  };

	print "IRC $fh Got connection from $host:$port\n";

	my $c = { Handle => $fh };
	$c->{PingTimer} = AnyEvent->timer(after => 30,
		cb => sub { irc_ping $c; });
	$c->{PingCount} = 0;
	$irc_clients{$fh} = $c;
	$fh->push_read(line => sub { irc_line($c, @_) });

	irc_server_notice $c, "Waiting for RTM connection" if not $connected;
    }, sub {
	chmod 0600, $config{unix_socket} if $config{unix_socket};
    }
}

########################################################################
# RTM client
########################################################################

my $rtm_client;
my $rtm_con;
my $rtm_msg_id = 1;
my %rtm_apicall_handles;
my $rtm_cooldown_timer;

my %rtm_mark_queue;
my $rtm_mark_timer;

my $rtm_ping_timer;
my $rtm_ping_count;

sub rtm_apicall {
    my ($method, $args, $cb) = @_;
    my @encode;

    print "RTM APICALL $method ", Dumper($args);

    $args->{token} = $config{slack_token};

    foreach my $k (keys %$args) {
	my $ek = uri_encode($k);
	my $ev = uri_encode($args->{$k});

	push @encode, "$ek=$ev";
    }

    my $x;
    $x = http_post "https://slack.com/api/$method", join('&', @encode),
	headers => {
	    "Content-Type", "application/x-www-form-urlencoded"
	}, sub {
	    my ($body, $hdr) = @_;
	    delete $rtm_apicall_handles{$x};

	    unless ($hdr->{Status} =~ /^2/) {
		irc_broadcast_notice
		  "API HTTP error: $method: $hdr->{Status} $hdr->{Reason}";
		$cb->(undef) if defined($cb);
		return;
	    }

	    my $data = decode_json $body;

	    print "RTM REPLY $method ", Dumper($data);

	    unless ($data->{ok}) {
		irc_broadcast_notice "API error: $data->{error}";
		$cb->(undef) if defined($cb);
		return;
	    }

	    $cb->($data) if defined($cb);
	};

    $rtm_apicall_handles{$x} = 1;
}

sub rtm_send {
    my $frame = shift;

    $frame->{id} = $rtm_msg_id++;
    print "RTM SEND: ", Dumper($frame);
    $rtm_con->send(encode_json $frame);
}

sub rtm_update_join {
    my ($uid, $chid) = @_;
    my $chan = $channels{$chid};
    my $user = $users{$uid};

    if (!$chan->{Members}->{$uid}) {
	$chan->{Members}->{$uid} = 1;
	$user->{Channels}->{$chid} = 1;
	return 1;
    }

    return undef;
}

sub rtm_update_part {
    my ($uid, $chid) = @_;
    my $chan = $channels{$chid};
    my $user = $users{$uid};

    if ($chan->{Members}->{$uid}) {
	delete $channels{$chid}->{Members}->{$uid};
	delete $users{$uid}->{Channels}->{$chid};
	return 1;
    }

    return undef;
}

sub rtm_update_user {
    my $c = shift;
    my $user;

    if (exists $users{$c->{id}}) {
	$user = $users{$c->{id}};
	my $oldname = $user->{Name};
	delete $users_by_name{irc_lcase($oldname)};
	my $newname = irc_pick_name($c->{name}, \%users_by_name);

	$user->{Realname} = $c->{real_name};

	irc_broadcast_nick $c->{id}, $newname
	    if $oldname ne $newname;

	$user->{Name} = $newname;
	$user->{Presence} = $c->{presence} || 'active';
	$users_by_name{$newname} = $user;
    } else {
	my $name = irc_pick_name($c->{name}, \%users_by_name);
	$user = {
	    Id => $c->{id},
	    Name => $name,
	    Channels => {},
	    Realname => $c->{real_name},
	    TxQueue => [],
	    Presence => $c->{presence} || 'active'
	};

	$users{$c->{id}} = $user;
	$users_by_name{$name} = $user;
    }

    $user->{Realname} = "" unless defined($user->{Realname});
}

sub rtm_record_unknown_uid {
    my $uid = shift;

    unless (exists $users{$uid}) {
	# Temporary name
	my $name = irc_pick_name($uid, \%users_by_name);

	my $u = {
	    Id => $uid,
	    Name => $name,
	    Channels => {},
	    Realname => "",
	    TxQueue => []
	};

	$users{$uid} = $u;
	$users_by_name{irc_lcase($name)} = $u;

	rtm_apicall "users.info", { user => $uid }, sub {
	    my $data = shift;

	    rtm_update_user $data->{user} if defined $data;
	};
    }
}

sub rtm_update_channel {
    my ($type, $c) = @_;

    my $id = $c->{id};
    my $mhash = {};
    my $name = $c->{name};

    $name = "+$name" if $type eq "G";

    # Cross-reference users/channels
    foreach my $u (@{$c->{members}}) {
	rtm_record_unknown_uid $u;
	$mhash->{$u} = 1;
	$users{$u}->{Channels}->{$id} = 1;
    }

    if (exists $channels{$id}) {
	my $chan = $channels{$id};
	$chan->{Members} = $mhash;
	$chan->{Topic} = $c->{topic}->{value};
	$chan->{Type} = $type;
    } else {
	my $name = irc_pick_name($name, \%channels_by_name);
	my $chan = {
	    Id => $c->{id},
	    Members => $mhash,
	    Name => $name,
	    Type => $type,
	    Topic => $c->{topic}->{value}
	};

	$channels{$c->{id}} = $chan;
	$channels_by_name{irc_lcase($name)} = $chan;
    }
}

sub rtm_delete_channel {
    my $chid = shift;
    my $chan = $channels{$chid};
    return unless defined $chan;

    foreach ($chan->{Members}) {
	my $user = $users{$_};

	delete $user->{Channels}->{$chid};
    }

    delete $channels_by_name{irc_lcase($chan->{Name})};
    delete $channels{$chid};
}

sub rtm_mark_channel {
    my ($chid, $ts) = @_;

    $rtm_mark_queue{$chid} = $ts;

    unless (defined $rtm_mark_timer) {
	$rtm_mark_timer = AnyEvent->timer(after => 5, cb => sub {
	    for my $chid (keys %rtm_mark_queue ) {
		rtm_apicall "channels.mark", {
		    channel => $chid,
		    ts => $rtm_mark_queue{$chid}
		};
	    }
	    %rtm_mark_queue = ();
	    undef $rtm_mark_timer;
	});
    }
}

my %rtm_command = (
    "presence_change" => sub {
	my $msg = shift;
	my $user = $users{$msg->{user}};

	if (defined $user) {
	    my $old = $user->{Presence};
	    $user->{Presence} = $msg->{presence} if defined $user;
	    irc_broadcast_away if
	      $msg->{user} eq $self_id and $old ne $msg->{presence};
	}
    },
    "manual_presence_change" => sub {
	my $msg = shift;
	my $user = $users{$self_id};
	my $old = $user->{Presence};

	$user->{Presence} = $msg->{presence};
	irc_broadcast_away if $old ne $msg->{presence};
    },
    "im_open" => sub {
	my $msg = shift;
	rtm_record_unknown_uid $msg->{user};

	my $u = $users{$msg->{user}};
	$u->{DMId} = $msg->{channel};
	$users_by_dmid{$msg->{channel}} = $u;

	foreach my $msg (@{$u->{TxQueue}}) {
	    rtm_send { type => "message",
		channel => $u->{DMId}, text => $msg };
	}

	$u->{TxQueue} = [];
    },
    "im_close" => sub {
	my $msg = shift;
	my $u = $users_by_dmid{$msg->{channel}};
	return unless defined($u);

	delete $u->{DMId};
	delete $users_by_dmid{$msg->{channel}};
    },
    "group_joined" => sub {
	my $msg = shift;

	rtm_update_channel "G", $msg->{channel};
	irc_broadcast_join $self_id, $msg->{channel}->{id};
    },
    "group_left" => sub {
	my $msg = shift;

	irc_broadcast_part $self_id, $msg->{channel}
	  if rtm_update_part $self_id, $msg->{channel};
    },
    "group_archive" => sub {
	my $msg = shift;

	irc_broadcast_part $self_id, $msg->{channel}
	  if rtm_update_part $self_id, $msg->{channel};
	rtm_delete_channel $msg->{channel};
    },
    "channel_joined" => sub {
	my $msg = shift;

	rtm_update_channel "C", $msg->{channel};
	irc_broadcast_join $self_id, $msg->{channel}->{id};
    },
    "channel_left" => sub {
	my $msg = shift;

	irc_broadcast_part $self_id, $msg->{channel}
	  if rtm_update_part $self_id, $msg->{channel};
    },
    "channel_archive" => sub {
	my $msg = shift;

	irc_broadcast_part $self_id, $msg->{channel}
	  if rtm_update_part $self_id, $msg->{channel};
	rtm_delete_channel $msg->{channel};
    },
    "member_joined_channel" => sub {
	my $msg = shift;

	rtm_record_unknown_uid $msg->{user};
	irc_broadcast_join $msg->{user}, $msg->{channel}
	  if rtm_update_join($msg->{user}, $msg->{channel});
    },
    "member_left_channel" => sub {
	my $msg = shift;

	irc_broadcast_part $msg->{user}, $msg->{channel}
	  if rtm_update_part($msg->{user}, $msg->{channel});
    },
    "pong" => sub {
	$rtm_ping_count = 0;
    },
    "message" => sub {
	my $msg = shift;
	my $chan = $channels{$msg->{channel}};
	my $subtype = $msg->{subtype} || "";
	my $uid = $msg->{user} || $msg->{comment}->{user};
	my $text = $msg->{text};

	$text = "" unless defined($text);

	if (defined($chan)) {
	    if ($subtype eq "channel_topic" or $subtype eq "group_topic") {
		$chan->{Topic} = $msg->{topic};
		irc_topic_change $uid, $chan->{Id};
	    } else {
		irc_chanmsg $uid, $msg->{subtype}, $chan->{Id}, $text;
	    }
	    rtm_mark_channel $chan->{Id}, $msg->{ts};
	} else {
	    irc_privmsg $uid, $msg->{subtype}, $text;
	}

	if ($subtype eq "file_share") {
	    my $fid = $msg->{file}->{id};
	    rtm_apicall "files.info", { file => $fid }, sub {
		my $data = shift;
		return unless defined $data;

		my $body = $data->{content};
		return unless length($body) <= 65536;

		if (defined $chan) {
		    irc_chanmsg $uid, ">$fid", $chan->{Id}, $body;
		} else {
		    irc_privmsg $uid, ">$fid", $body;
		}
	    };
	}
    },
);

sub rtm_send_to_user {
    my ($id, $msg) = @_;
    my $u = $users{$id};

    if (defined($u->{DMId}) && length($u->{DMId})) {
	rtm_send { type => "message",
		channel => $u->{DMId}, text => $msg };
	return;
    }

    push @{$u->{TxQueue}}, $msg;

    if (!defined($u->{DMId})) {
	rtm_apicall "im.open", { user => $u->{Id} }, sub {
	    my $result = shift;
	    unless (defined $result) {
		delete $u->{DMId};
		foreach my $m (@{$u->{TxQueue}}) {
		    irc_broadcast_notice "Failed to send to $u->{Name}: $m";
		}
		$u->{TxQueue} = [];
	    }
	};

	$u->{DMId} = "";
    }
}

sub rtm_start;

sub rtm_cooldown {
    return if defined($rtm_cooldown_timer);
    print "Waiting before reinitiating RTM\n";
    $rtm_cooldown_timer = AnyEvent->timer(after => 5, cb => sub {
	undef $rtm_cooldown_timer;
	rtm_start;
    });
};

sub rtm_destroy {
    my $msg = shift;
    return unless defined($rtm_con);

    irc_broadcast_notice $msg;

    $connected = 0;
    undef $self_id;
    %channels = ();
    %channels_by_name = ();
    %users = ();
    %users_by_name = ();
    %users_by_dmid = ();

    %rtm_apicall_handles = (); # cancel outstanding requests
    %rtm_mark_queue = ();
    undef $rtm_mark_timer;
    undef $rtm_ping_timer;
    $rtm_con->close;
    undef $rtm_con;
    undef $rtm_client;

    irc_disconnect_all;
    rtm_cooldown;
}

sub rtm_ping {
    if (++$rtm_ping_count >= 2) {
	rtm_destroy "RTM ping timeout";
	return;
    }

    rtm_send { type => "ping" };
    $rtm_ping_timer = AnyEvent->timer(after => 60, cb => \&rtm_ping);
}

sub rtm_start_ws {
    my $url = shift;

    return if defined($rtm_client);
    $rtm_client = AnyEvent::WebSocket::Client->new;

    print "WSS URL: $url\n";
    $rtm_client->connect($url)->cb(sub {
	$rtm_con = eval { shift->recv; };
	if ($@) {
	    irc_broadcast_notice "WSS connection failed: $@\n";
	    undef $rtm_client;
	    rtm_cooldown;
	}

	print "WSS connected\n";
	$rtm_msg_id = 1;
	$rtm_ping_count = 0;
	$connected = 1;
	irc_check_welcome_all;

	$rtm_ping_timer = AnyEvent->timer(after => 60, cb => \&rtm_ping);

	$rtm_con->on(each_message => sub {
	    eval {
		shift;
		my $msg = decode_json shift->{body};

		print "RTM RECV: ", Dumper($msg);
		irc_broadcast_notice "RTM error: $msg->{error}->{msg}"
		    if $msg->{error};

		if (defined $msg->{type}) {
		    my $handler = $rtm_command{$msg->{type}};
		    $handler->($msg) if defined($handler);
		}
	    };
	    print "Error in message handler: $@" if $@;
	});

	$rtm_con->on(finish => sub {
	    eval {
		my ($con) = @_;

		if (defined $con->close_error) {
		    rtm_destroy "RTM connection error: $con->close_error";
		} elsif (defined $con->close_reason) {
		    rtm_destroy "RTM connection closed: $con->close_reason";
		} else {
		    rtm_destroy "RTM connection finished";
		}
	    };
	    print "Error in finish handler: $@" if $@;
	});
    });
};

sub rtm_start {
    print "Requesting RTM connection\n";
    rtm_apicall "rtm.start", {}, sub {
	my $data = shift;

	unless (defined($data)) {
	    rtm_cooldown;
	    return;
	}

	$self_id = $data->{self}->{id};

	foreach my $c (@{$data->{users}}) {
	    rtm_update_user $c;
	}

	foreach my $c (@{$data->{ims}}) {
	    my $u = $users{$c->{user}};

	    $u->{DMId} = $c->{id};
	    $users_by_dmid{$c->{id}} = $u;
	}

	foreach my $c (@{$data->{channels}}) {
	    rtm_update_channel "C", $c unless $c->{is_archived};
	}

	foreach my $c (@{$data->{groups}}) {
	    rtm_update_channel "G", $c unless $c->{is_archived};
	}

	rtm_start_ws $data->{url};
    };
};

########################################################################
# RTM kick-off
########################################################################

my $cfgfile = shift || die "You must specify a config file";
open(my $cfg, $cfgfile) || die "Can't open $cfgfile";
foreach (<$cfg>) {
    chomp;
    $config{$1} = $2 if /^([-_0-9a-zA-Z]+)=(.*)$/;
}
close($cfg);

rtm_start;
irc_listen;
AnyEvent->condvar->recv;
