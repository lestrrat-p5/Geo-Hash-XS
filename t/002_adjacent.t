use strict;
use warnings;
use Test::More;
use Geo::Hash::XS;

TODO: {
    todo_skip "Don't know how to test this", 2;

    ok my $gh = Geo::Hash::XS->new;
    isa_ok $gh, 'Geo::Hash::XS';
    my $hash = $gh->encode( 50, 30 );
    my $adjacent = $gh->adjacent($hash, 0);
}

done_testing;