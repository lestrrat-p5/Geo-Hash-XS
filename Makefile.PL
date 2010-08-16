use inc::Module::Install;
use File::Spec;

name 'Geo-Hash-XS';
all_from 'lib/Geo/Hash/XS.pm';

generate_compat_tests();

test_requires 'Test::More' => '0.94';
use_ppport;
cc_warnings;
cc_src_paths 'xs';

author_tests 'xt';

WriteAll;

sub generate_compat_tests {
    my @compat_tests = qw(
        001_geohash.t
        004_decode_to_interval.t
        005_precision.t
    );
    
    my $from_dir = 't';
    my $to_dir   = File::Spec->catdir('t', '900_compat');
    
    if (! -d $to_dir) {
        mkdir $to_dir or die "Could not make $to_dir";
    }

    foreach my $t (@compat_tests) {
        my $from = File::Spec->catfile($from_dir, $t);
        my $to = File::Spec->catfile($to_dir, $t);
        open( my $from_fh, '<', $from ) or
            die "Could not open $from for reading: $!";
        open( my $to_fh, '>', $to ) or
            die "Could not open $from for writing: $!";

        while (<$from_fh>) {
            s/Geo::Hash::XS/Geo::Hash/g;
            print $to_fh $_;
        }
        close $from_fh;
        close $to_fh;
    }
}

