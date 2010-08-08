package Geo::Hash::XS;
use strict;
use XSLoader;
use Exporter 'import';
our @EXPORT_OK = qw( ADJ_TOP ADJ_RIGHT ADJ_LEFT ADJ_BOTTOM );
our %EXPORT_TAGS = (adjacent => \@EXPORT_OK);

our $VERSION = '0.00005';
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

Geo::Hash::XS encodes and decodes geohash strings, fast. 

Currently this module is alpha quality (especially the C<adjacent()> and C<negihbors()> methods, which I just kind of copied the logic from elsewhere). Please submit tests and patches!

=head1 METHODS

=head2 $gh = Geo::Hash::XS->new()

=head2 $hash = $gh->encode($lat, $lon[, $precision])

Encodes the given C<$lat> and C<$lon> to a geohash. If C<$precision> is not
given, automatically adjusts the precision according the the given C<$lat>
and C<$lon> values.

If you do not want Geo::Hash::XS to spend time calculating this, explicitly
specify C<$precision>.

=head2 ($lat, $lon) = $gh->decode( $hash )

Decodes $hash to $lat and $lon

=head2 ($lat_range, $lon_range) = $gh->decode_to_interval( $hash )

Like C<decode()> but C<decode_to_interval()> decodes $hash to $lat_range and $lon_range. Each range is a reference to two element arrays which contains the upper and lower bounds.

=head2 $adjacent_hash = $gh->adjacent($hash, $where)

Returns the adjacent geohash. C<$where> denotes the direction, so if you
want the block to the right of C<$hash>, you say:

    use Geo::Hash::XS qw(ADJ_RIGHT);

    my $gh = Geo::Hash::XS->new();
    my $adjacent = $gh->adjacent( $hash, ADJ_RIGHT );

=head2 neighbors($hash, $around, $offset)

Returns the list of neighbors (the blocks surrounding $hash)

=head2 $precision = $gh->precision($lat, $lon)

Returns the apparent required precision to describe the given latitude and longitude.

=head1 CONSTANTS

=head2 ADJ_LEFT, ADJ_RIGHT, ADJ_TOP, ADJ_BOTTOM

Used to specify the direction in C<adjacent()>

=head1 PERFORMANCE

Here's the output from running benchmark/encode.pl:

    Geo::Hash: 0.02
    Geo::Hash::XS: 0.00006
    
    precision = auto...
              Rate   perl     xs
    perl   19638/s     --   -99%
    xs   2639682/s 13341%     --
    
    precision = 5...
              Rate   perl     xs
    perl   17600/s     --   -99%
    xs   2479507/s 13988%     --
    
    precision = 10...
              Rate   perl     xs
    perl    9286/s     --  -100%
    xs   2039615/s 21864%     --
    
    precision = 20...
              Rate   perl     xs
    perl    4884/s     --  -100%
    xs   1622943/s 33132%     --
    
    precision = 30...
              Rate   perl     xs
    perl    3254/s     --  -100%
    xs   1257127/s 38532%     --

Obviously, the benefit of doing this calculation in XS becomes larger with
higher precision, but generaly you don't need precision > 10.

=back

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=head1 AUTHOR

Copyright (c) 2010 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=cut
