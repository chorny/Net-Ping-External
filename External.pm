package Net::Ping::External;

# Author:   Colin McMillen (colinm@cpan.org)
#
# Copyright (c) 2001 Colin McMillen.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Carp;
use Socket qw(inet_ntoa);
require Exporter;

$VERSION = "0.02";
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw(ping);

sub ping {
  my %args = @_;

  # "host" and "hostname" are synonyms.
  $args{host} = $args{hostname} if defined $args{hostname};

  # If we have an "ip" argument, convert it to a hostname and use that.
  $args{host} = inet_ntoa($args{ip}) if defined $args{ip};

  # croak() if no hostname was provided.
  croak("You must provide a hostname") unless defined $args{host};
  $args{timeout} = 5 unless defined $args{timeout} && $args{timeout} > 0;

  my %dispatch = 
    (linux   => \&_ping_linux,
     mswin32 => \&_ping_win32,
     solaris => \&_ping_solaris,
     openbsd => \&_ping_unix,
     freebsd => \&_ping_unix,
     netbsd  => \&_ping_unix,
     irix    => \&_ping_unix,
     aix     => \&_ping_unix,
    );

  my $subref = $dispatch{lc $^O};

  croak("External ping not supported on your system") unless $subref;

  return $subref->($args{host}, $args{timeout});
}

# Win32 is the only system so far for which we actually need to parse the
# results of the system ping command.
sub _ping_win32 {
  my ($hostname, $timeout) = @_;
  $timeout *= 1000;    # Win32 ping timeout is specified in milliseconds
  my $command = "ping -n 1 -w $timeout $hostname";
  my $result = `$command`;
  return 1 if $result =~ /\(0% loss\)/i;
  return 0;
}

# Generic subroutine to handle pinging using the system() function. Generally,
# UNIX-like systems return 0 on a successful ping and something else on
# failure. If the return value of running $command is equal to the value
# specified as $success, the ping succeeds. Otherwise, it fails.
sub _ping_system {
  my ($command,   # The ping command to run
      $success,   # What value the system ping command returns on success
     ) = @_;
  my $devnull = "/dev/null";
  $command .= " 1>$devnull 2>$devnull";
  my $exit_status = system($command) >> 8;
  return 1 if $exit_status == $success;
  return 0;
}

# Below are all the systems on which _ping_system() has been tested
# and found OK.

# OpenBSD 2.7 OK, IRIX 6.5 OK
# Assumed OK for NetBSD, FreeBSD, and AIX, but needs testing
sub _ping_unix {
  my ($hostname, $timeout) = @_;
  my $command = "ping -c 1 -w $timeout $hostname";
  return _ping_system($command, 0);
}

# Debian 2.2 OK, RedHat 6.2 OK
sub _ping_linux {
  my ($hostname, $timeout) = @_;
  my $command = "ping -c 1 $hostname";
  return _ping_system($command, 0);
}

# Solaris 2.6, 2.7 OK
sub _ping_solaris {
  my ($hostname, $timeout) = @_;
  my $command = "ping $hostname $timeout";
  return _ping_system($command, 0);
}

1;

__END__

=head1 NAME

Net::Ping::External - Cross-platform interface to ICMP "ping" utilities

=head1 SYNOPSIS

In general:

  use Net::Ping::External qw(ping);
  ping(%options);

Some examples:

  use Net::Ping::External qw(ping);

  # Ping a single host
  my $alive = ping(host => "127.0.0.1");
  print "127.0.0.1 is online" if $alive;

  # Or a list of hosts
  my @hosts = qw(127.0.0.1 127.0.0.2 127.0.0.3 127.0.0.4);
  my $num_alive = 0;
  foreach (@hosts) {
    $alive = ping(hostname => $_, timeout => 5);
    print "$_ is alive!\n" if $alive;
    $num_alive++;
  }
  print "$num_alive hosts are alive.\n";

=head1 DESCRIPTION

Net::Ping::External is a module which interfaces with the "ping" command
on many systems. It presently provides a single function, C<ping()>, that
takes in a hostname and (optionally) a timeout and returns true if the
host is alive, and false otherwise. Unless you have the ability (and
willingness) to run your scripts as the superuser on your system, this
module will probably provide more accurate results than Net::Ping will.

Why?

=over 4

=item *

ICMP ping is the most reliable way to tell whether a remote host is alive.

=item *

However, Net::Ping cannot use an ICMP ping unless you are running your
script with privileged (AKA "root") access.

=item *

The system's "ping" command uses ICMP and does not usually require
privileged access.

=item *

While it is relatively trivial to write a Perl script that parses the
output of the "ping" command on a given system, the aim of this module
is to encapsulate this functionality and provide a single interface for
it that works on many systems.

=back

Support currently exists for interfacing with the standard ping
utilities on the following systems:

=over 4

=item * Win32

Tested OK on Win98. It should work on other Windows systems as well.

=item * Linux

Tested OK on Debian 2.2 and Redhat 6.2, although Linux ping appears not to
support the "timeout" option. If you are using this module on
a different flavor of Linux, please test it and let me know of the results.

=item * BSD

Tested OK on OpenBSD 2.7. Needs testing for FreeBSD, NetBSD, and BSDi.

=item * Solaris

Tested OK on Solaris 2.6 and 2.7.

=item * IRIX

Tested OK on IRIX 6.5.

=item * AIX

I have been informed that this module should work on AIX as well. No
official test results yet.

=back

More systems will be added as soon as any users request them. If your
system is not currently supported, e-mail me; adding support to your
system is probably trivial.

=head2 ping() options

This module is still "alpha"; it is expected that more options to the C<ping()>
function will be added soon.

=over 4

=item * C<host, hostname>

The hostname (or dotted-quad IP address) of the remote host you are trying
to ping. You must specify either the "hostname" option or the "ip" option.

"host" and "hostname" are synonymous.

=item * C<ip>

A packed bit-string representing the 4-byte packed IP address (as
returned by C<Socket.pm>'s C<inet_aton()> function) of the host that you
would like to ping.

=item * C<timeout>

The maximum amount of time, in seconds, that C<ping()> will wait for a response.
If the remote system does not respond before the timeout has elapsed, C<ping()>
will return false.

Default value: 5.

=back

=head1 BUGS

This module should be considered alpha. Bugs may exist. Although no
specific bugs are known at this time, the module could use testing
on a greater variety of systems.

See the warning below.

=head1 WARNING

This module calls whatever "ping" program it first finds in your PATH
environment variable. If your PATH contains a trojan "ping" program,
this module will call that program. This involves a small amount of
risk, but no more than simply typing "ping" at a system prompt.

Beware Greeks bearing gifts.

=head1 AUTHOR

Colin McMillen (colinm@cpan.org)

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

Net::Ping

=cut



