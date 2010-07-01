#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

char PIECES[32] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'm',
    'n', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
};

void
encode(char *buf, STRLEN precision, NV lat, NV lon) {
    IV which = 0;
    STRLEN count = 0;
    NV 
        lat_min = -90,
        lat_max = 90,
        lon_min = -180,
        lon_max = 180
    ;

    while ( count < precision ) {
        IV i;
        IV bits = 0;
        for( i = 0; i < 5; i++ ) {
            IV bit;
            if (which) {
                NV mid = (lat_max + lat_min) / 2;
                bit = lat >= mid ? 1 : 0;
                if ( bit ) { lat_min = mid; }
                else       { lat_max = mid; }
            } else {
                NV mid = (lon_max + lon_min) / 2;
                bit = lon >= mid ? 1 : 0;
                if ( bit ) { lon_min = mid; }
                else       { lon_max = mid; }
            }
            bits = ( ( bits << 1 ) | bit );
            which ^= 1;
        }

        buf[count] = PIECES[bits];
        count++;
    }


    buf[count] = '\0';
}

void
decode(char *hash, STRLEN len, NV *lat, NV *lon) {
    STRLEN i, j;
    IV which = 0, min_or_max;
    NV 
        lat_min = -90,
        lat_max = 90,
        lon_min = -180,
        lon_max = 180
    ;
    for (i = 0; i < len; i++ ) {
        IV bits;
        int x = (int) hash[i];
        if (x >= 48 && x <= 57) {
            bits = x - 48;
        } else if ( x >= 98 && x <= 104 ) {
            bits = x - 88;
        } else if ( x >= 106 && x <= 107 ) {
            bits = x - 89;
        } else if ( x >= 109 && x <= 110 ) {
            bits = x - 90;
        } else if ( x >= 112 && x <= 122 ) {
            bits = x - 91;
        } else {
            croak("Bad character '%c' in hash '%s'", hash[i], hash);
        }

        for (j = 0; j < 5; j++){ 
            min_or_max = ( bits & 16 ) >> 4;
            if (which) {
                NV mid = (lat_max + lat_min ) / 2;
                if (min_or_max) { /* max */
                    lat_min = mid;
                } else {
                    lat_max = mid;
                }
            } else {
                NV mid = (lon_max + lon_min ) / 2;
                if (min_or_max) { /* max */
                    lon_min = mid;
                } else {
                    lon_max = mid;
                }
            }

            which ^= 1;
            bits <<= 1;
        }
    }

    *lat = (lat_max + lat_min) / 2;
    *lon = (lon_max + lon_min) / 2;
}

STRLEN
precision(STRLEN lat, STRLEN lon) {
    IV lab;
    IV lob;
    lab = (int) ( (lat * 3.32192809488736 + 1) + 8 );
    lob = (int) ( (lon * 3.32192809488736 + 1) + 9 );
    return (int) ( ( ( lab > lob ? lab : lob ) + 1 ) / 2.5 );
}
    
MODULE = Geo::Hash::XS PACKAGE = Geo::Hash::XS

PROTOTYPES: DISABLE

char *
encode(self, lat, lon, p = 32)
        SV *self;
        SV *lat;
        SV *lon;
        IV p;
    CODE:
        /*
        if (p <= 0) {
            p = precision( SvLEN(lat), SvLEN(lon) );
        }
        */

        Newxz(RETVAL, p + 1, char);
        encode(RETVAL, p, SvNV(lat), SvNV(lon));
    OUTPUT:
        RETVAL

void
decode(self, hash)
        SV *self;
        char *hash;
    INIT:
        NV lat = 0, lon = 0;
        STRLEN len = strlen(hash);
    PPCODE:
        decode(hash, len, &lat, &lon);
        mXPUSHn(lat);
        mXPUSHn(lon);

