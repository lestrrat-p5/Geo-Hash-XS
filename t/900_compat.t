use strict;
use Test::More;
use Test::Requires 'Geo::Hash';

while (<t/900_compat/*.t>) {
    subtest $_ => sub { do $_ };
}

done_testing();