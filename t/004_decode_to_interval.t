use strict;
use warnings;
use Test::More;
use Geo::Hash::XS;

# The test data are introduced from 
# http://github.com/masuidrive/pr_geohash/blob/master/test/test_pr_geohash.rb

my %tests = (
    'c216ne' => [
        [45.3680419921875, 45.37353515625],
        [-121.70654296875, -121.695556640625] 
    ],
    'dqcw4' => [
        [39.0234375, 39.0673828125], 
        [-76.552734375, -76.5087890625]
    ],
);

my $gh = Geo::Hash::XS->new;
for (keys %tests) {
    is_deeply [$gh->decode_to_interval($_)], $tests{$_};
}

done_testing;
