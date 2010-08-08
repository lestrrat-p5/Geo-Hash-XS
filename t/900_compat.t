use strict;
use Test::More;

while (<t/900_compat/*.t>) {
    subtest $_ => sub { do $_ };
}

done_testing();