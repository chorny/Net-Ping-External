# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; $num_tests = 6; print "1..$num_tests\n"; }
END {print "not ok 1\n" unless $loaded;}
use Net::Ping::External qw(ping);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

@passed = ();
push @passed, 1 if $loaded;

eval{ $ret = ping(host => "127.0.0.1") };
if ($@) {
  print "not ok 2\n";
}
else {
  print "ok 2\n";
  push @passed, 2;
}

if ($ret) {
  print "ok 3\n";
  push @passed, 3;
}
else {
  print "not ok 3\n";
}

eval { $ret = ping(host => "127.0.0.1", timeout => 5) };
if (!$@ && $ret) {
  print "ok 4\n";
  push @passed, 4;
} 
else {
  print "not ok 4\n";
}

eval { $ret = ping(host => "some.non.existent.host") };
if (!$@ && !$ret) {
  print "ok 5\n";
  push @passed, 5;
}
else {
  print "not ok 5\n";
}

eval { $ret = ping(host => "10.252.253.254") };
if (!$@ && !$ret) {
  print "ok 6\n";
  push @passed, 6;
}
else {
  print "not ok 6\n";
}

print "\nRunning a more verbose test suite.";
print "\n-------------------------------------------------\n";
print "Net::Ping::External version: ", $Net::Ping::External::VERSION, "\n";
print scalar(@passed), "/$num_tests tests passed.\n";
print "Successful tests: @passed\n";
print "Operating system: ", $^O, "\n\n";
print "Output of perl -v:\n";
@output = `perl -v`;
print @output[0..2];
print "-------------------------------------------------\n";
print "Test suite completed. If you would like to help\n";
print "further the development of Net::Ping::External,\n";
print "please e-mail the results (the bits between the\n";
print "dashed lines) to colinm\@cpan.org. Thank you!\n\n";
print "Press enter to continue: ";
<STDIN>;
