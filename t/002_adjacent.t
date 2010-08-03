use strict;
use warnings;
use Test::More;
use Geo::Hash::XS;

ok my $gh = Geo::Hash::XS->new;
isa_ok $gh, 'Geo::Hash::XS';

# Made these tests by using 
# http://blog.masuidrive.jp/wp-content/uploads/2010/01/geohash.html
is $gh->adjacent('xn76gg', 0), lc 'xn76u5'; # RIGHT
is $gh->adjacent('xn76gg', 1), lc 'xn76ge'; # LEFT
is $gh->adjacent('xn76gg', 2), lc 'xn76gu'; # TOP
is $gh->adjacent('xn76gg', 3), lc 'xn76gf'; # BOTTOM

is $gh->adjacent('xpst02vt', 0), 'xpst02vv'; # RIGHT
is $gh->adjacent('xpst02vt', 1), 'xpst02vm'; # LEFT
is $gh->adjacent('xpst02vt', 2), 'xpst02vw'; # TOP
is $gh->adjacent('xpst02vt', 3), 'xpst02vs'; # BOTTOM

done_testing;
