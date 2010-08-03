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

char* NEIGHBORS[4][2] = {
    { "bc01fg45238967deuvhjyznpkmstqrwx", "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
    { "238967debc01fg45kmstqrwxuvhjyznp", "14365h7k9dcfesgujnmqp0r2twvyx8zb" },
    { "p0r21436x8zb9dcf5h7kjnmqesgutwvy", "bc01fg45238967deuvhjyznpkmstqrwx" },
    { "14365h7k9dcfesgujnmqp0r2twvyx8zb", "238967debc01fg45kmstqrwxuvhjyznp" }
};

char* BORDERS[4][2] = {
    { "bcfguvyz", "prxz" },
    { "0145hjnp", "028b" },
    { "prxz", "bcfguvyz" },
    { "028b", "0145hjnp" }
};

STRLEN
precision(STRLEN lat, STRLEN lon) {
    IV lab;
    IV lob;
    lab = (int) ( (lat * 3.32192809488736 + 1) + 8 );
    lob = (int) ( (lon * 3.32192809488736 + 1) + 9 );
    return (int) ( ( ( lab > lob ? lab : lob ) + 1 ) / 2.5 );
}

enum GH_DIRECTION {
    RIGHT = 0,
    LEFT = 1,
    TOP = 2,
    BOTTOM = 3
};

/* need to free this return value! */
char *
adjacent(char *hash, STRLEN hashlen, enum GH_DIRECTION direction) {
    char base[8192];
    char last_ch = hash[ hashlen - 1 ];
    char *pos, *ret;
    IV type = hashlen % 2;
    IV base_len;

    if (hashlen < 1)
        croak("PANIC: hash too short!");

    memcpy(base, hash, hashlen - 1 );
    base[hashlen] = '\0';

    pos = index(BORDERS[direction][type], last_ch);
    if (pos != NULL) {
        char *tmp = adjacent(base, hashlen - 1, direction);
        strcpy(base, tmp);
        Safefree(tmp);
    }

    base_len = strlen(base);
    Newxz( ret, base_len + 1, char );
    strcpy( ret, base );
    ret[ base_len ] = PIECES[ index(NEIGHBORS[direction][type], last_ch) - NEIGHBORS[direction][type] ];
    return ret;
}

void
neighbors(char *hash, STRLEN hashlen, int around, int offset, char ***neighbors, int *nsize) {
    char *xhash;
    STRLEN xhashlen = hashlen;
    int i = 1;

    Newxz( xhash, hashlen, char );
    Copy( hash, xhash, hashlen, char );

    while ( offset > 0 ) {
        char *top = adjacent( xhash, xhashlen, TOP );
        char *left = adjacent( top, strlen(top), LEFT );
        Safefree(xhash);
        Safefree(top);
        xhash = left;
        xhashlen = strlen(xhash);

        offset--;
        i++;
    }

    {
    int n = 0;
    *nsize = 0;
    Newxz( neighbors, around, char **);
    while (around-- > 0) {
        int j;
        int m = 0;

        /* going to insert this many neighbors */
        Renew( neighbors[n], 8 * i - 1, char *);

        neighbors[n][m++] = adjacent(xhash, xhashlen, TOP);
        for ( j = 0; j < 2 * i - 1; j ++ ) {
            neighbors[n][m++] = adjacent(xhash, xhashlen, RIGHT);
        }
        for ( j = 0; j < 2 * i; j ++ ) {
            neighbors[n][m++] = adjacent(xhash, xhashlen, BOTTOM);
        }
        for ( j = 0; j < 2 * i; j ++ ) {
            neighbors[n][m++] = adjacent(xhash, xhashlen, LEFT);
        }
        for ( j = 0; j < 2 * i; j ++ ) {
            neighbors[n][m++] = adjacent(xhash, xhashlen, TOP);
        }
        i++;
        n++;
        *nsize += m;
    }
    }
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
        PERL_UNUSED_VAR(self);

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
        PERL_UNUSED_VAR(self);
        decode(hash, len, &lat, &lon);
        mXPUSHn(lat);
        mXPUSHn(lon);

char *
adjacent(self, hash, direction)
        SV *self;
        char *hash;
        int direction;
    CODE:
        PERL_UNUSED_VAR(self);
        RETVAL = adjacent(hash, strlen(hash), direction);
    OUTPUT:
        RETVAL

void
neighbors(self, hash, around = 1, offset = 0)
        SV *self;
        char *hash;
        int around;
        int offset;
    PREINIT:
        int i;
        int nsize;
        char **list;
    PPCODE:
        PERL_UNUSED_VAR(self);
        neighbors(hash, strlen(hash), around, offset, &list, &nsize);

        for( i = 0; i < nsize; i++ ) {
            mXPUSHp( list[i], strlen(list[i]) );
        }
        for( i = 0; i < nsize; i++ ) {
            Safefree(list[i]);
        }
        Safefree(list);

