package Geo::Hash::XS;
use strict;
use XSLoader;

our $VERSION = '0.00001';
XSLoader::load __PACKAGE__, $VERSION;

sub new { bless {}, shift }

1;

__END__

=head1 NAME

Geo::Hash::XS - Geo::Hash in XS

=head1 SYNOPSIS

    my $gh = Geo::Hash::XS->new();
    my $hash = $gh->encode( $lat, $lon );  # default precision = 32
    my $hash = $gh->encode( $lat, $lon, $precision ); 
    my ($lat, $lon) = $gh->decode( $hash );

=head1 DESCRIPTION

Geo::Hash::XS encodes and decodes geohash strings, fast. It does nothing
else.

=head1 METHOD

=head2 $gh = Geo::Hash::XS->new()

=head2 $hash = $gh->encode($lat, $lon[, $precision])

One notable difference between Geo::Hash::XS and Geo::Hash is that
encode() does NOT dynamically adjust the precision when $precision is not
given. If not given, $precision is always 32

=head2 ($lat, $lon) = $gh->decode( $hash )

Decodes $hash to $lat and $lon

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=head1 AUTHOR

Copyright (c) 2010 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=cut