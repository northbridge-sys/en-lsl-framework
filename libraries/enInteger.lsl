/*
    enInteger.lsl
    Library
    En LSL Framework
    Copyright (C) 2024  Northbridge Business Systems
    https://docs.northbridgesys.com/en-lsl-framework

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ LICENSE                                                                      │
    └──────────────────────────────────────────────────────────────────────────────┘

    This script is free software: you can redistribute it and/or modify it under the
    terms of the GNU Lesser General Public License as published by the Free Software
    Foundation, either version 3 of the License, or (at your option) any later
    version.

    This script is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
    PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along
    with this script.  If not, see <https://www.gnu.org/licenses/>.

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

    TBD
*/

// ==
// == macros
// ==

#define enInteger_Rand() \
    (integer)( "0x" + llGetSubString( llGenerateKey(), 0, 7 ))

// WARNING: THIS IS LAZY AND BAD, DON'T USE
#define enInteger_GetSign(i) \
    (!!(i & INTEGER_NEGATIVE) * 2 - 1)

#define enInteger_InvertNegative(i) \
    (i ^ INTEGER_NEGATIVE)

// this is not ideal C practice for this implementation due to llAbs
// randomness at ranges larger than INTEGER_MAX will just have to do it themselves.
// idk what you would even be doing that for tbh
#define enInteger_RandRange(n,x) \
    (n + llAbs(enInteger_Rand()) / (INTEGER_MAX / (x - n + 1) + 1))

// use enInteger_RandRange unless you absolutely need speed
// this has really bad randomness on low-order bits
#define enInteger_RandRangeFast(n,x) \
    (enInteger_Rand() % (x - n + 1) + n)

// since > and < always return integer 0x1, effectively equivalent to:
//if (i < m || i > x) i = t; // set to target if outside min/max
//return i;
// except at extremely large ranges
#define enInteger_ResetTarget(i,m,x,t) \
    (i + ((t - i) * (i < m || i > x)))

// ==
// == functions
// ==

string enInteger_ElemBitfield(integer var)
{
    list flags;
    integer bit;
    // TODO: support for non-32-bit bitfields?
    for (bit = 0; bit < 32; bit++)
    {
        if (var & (0x1 << bit)) flags += ["0x" + enInteger_ToHex(var & (0x1 << bit), 1) + " (" + (string)(var & (0x1 << bit)) + ")"];
    }
    return "{" + llList2CSV(flags) + "}";
}

string enInteger_ToHex( // converts a 32-bit signed integer in its entirety to hex - for the reverse, use: integer i = (integer)( "0x" + h );
    integer i, // integer
    integer digits // number of hex digits
    )
{
    integer init_digits = digits;
    integer lsn; // least significant nybble
    string hex;
    do
    {
        hex = llGetSubString( ENINTEGER_CHARSET_16, lsn = ( i & 0xF ), lsn ) + hex;
        digits--;
    }
    while ( i = ( 0xFFFFFFF & ( i >> 4 ) ) );
    if ( digits > 0 )
    {
        while ( digits-- ) hex = "0" + hex; // pad with leading zeroes until we have reached the minimum digits
    }
    return hex;
}

integer enInteger_ToNybbles( // grabs the specified nybbles out of an integer
    integer i, // integer
    integer start_index, // start index
    integer digits // number of nybbles to return
    )
{
    while ( --start_index & 0x80000000 ) i = ( 0xFFFFFFF & ( i >> 4 ) ); // drop {start_index} least significant nybbles for
    integer lsn; // least significant nybble
    integer digit; // which digit is being added
    integer nybbles;
    do nybbles = ( ( lsn = ( i & 0xF ) ) << ( 4 * digit++ ) ) | nybbles; // bitwise out the least significant nybble, insert it into nybbles at current digit
    while ( --digits && i = ( 0xFFFFFFF & ( i >> 4 ) ) );
    return nybbles;
}

string enInteger_ToString64( // converts int to string of length using 64-character charset, ENTYPE_CHARSET_64
    integer int,
    integer length
    )
{
    string o;
    integer x;
    integer y;
    if ( int < 0 )
    { // fix for negative values
        x = ( (0x7FFFFFFF & int) % 64 ) - ( 0x80000000 % 64 );
        y = x % 64;
        int = ( x / 64 ) + ( ( 0x7FFFFFFF & int ) / 64 ) - ( 0x80000000 / 64 );
        o = llGetSubString( ENVAR_CHARSET_64, y, y );
    }
    do o = llGetSubString( ENVAR_CHARSET_64, x = int % 64, x ) + o;
    while ( int /= 64 );
    while ( llStringLength(o) < length ) o = "0" + o;
    return o;
}

integer enInteger_FromStr64( // inverse of enInteger_ToString64
    string str
    )
{
    integer i = -llStringLength(str);
    integer x = 0;
    while (i) x = (x * 64) + llSubStringIndex(ENVAR_CHARSET_64, llGetSubString(str, i, i++));
    return x;
}

integer enInteger_Clamp(
    integer i,
    integer m,
    integer x
    )
{
    if (i < m) i = m; // clamp to minimum
    if (i > x) i = x; // clamp to maximum
    return i;
}

integer enInteger_ResetChunk(
    integer i,
    integer m,
    integer x,
    integer c
)
{
    if (c < 0) c = -c; // make c positive
    if (i < m) i += c * ((m - i) + (c - 1) / c);
    if (i > x) i -= c * ((i - x) + (c - 1) / c);
    return i;
}
