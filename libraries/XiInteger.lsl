/*
    XiInteger.lsl
    Library
    Xi LSL Framework
    Copyright (C) 2024  BuildTronics
    https://docs.buildtronics.net/xi-lsl-framework

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
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XIINTEGER_ENABLE_XILOG_TRACE
#endif

#ifndef XIINTEGER_CHARSET_16
#define XIINTEGER_CHARSET_16 "0123456789abcdef"
#endif

#ifndef XIINTEGER_CHARSET_64
#define XIINTEGER_CHARSET_64 "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-="
#endif

#ifndef XIINTEGER_CHARSET_256
#define XIINTEGER_CHARSET_256 ""
#endif

// ==
// == functions
// ==

string XiInteger_ElemBitfield(integer var)
{
    integer test = 1;
    list flags;
    while (test <= var)
    {
        if (test & var) flags += ["0x" + XiInteger_ToHex(test, 1) + " (" + (string)test + ")"];
        test *= 2;
    }
    return "{" + llList2CSV(flags) + "}";
}

integer XiInteger_Rand() // random integer
{
    return (integer)( "0x" + llGetSubString( llGenerateKey(), 0, 7 ));
}

string XiInteger_ToHex( // converts a 32-bit signed integer in its entirety to hex - for the reverse, use: integer i = (integer)( "0x" + h );
    integer i, // integer
    integer digits // number of hex digits
    )
{
    integer init_digits = digits;
    integer lsn; // least significant nybble
    string hex;
    do
    {
        if (digits)
        {
            hex = llGetSubString( XIINTEGER_CHARSET_16, lsn = ( i & 0xF ), lsn ) + hex;
            digits--;
        }
    }
    while ( i = ( 0xFFFFFFF & ( i >> 4 ) ) );
    while ( digits-- ) hex = "0" + hex; // pad with leading zeroes until we have reached the minimum digits
    return hex;
}

integer XiInteger_ToNybbles( // grabs the specified nybbles out of an integer
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

string XiInteger_ToString64( // converts int to string of length using 64-character charset, XITYPE_CHARSET_64
    integer int,
    integer length
    )
{
    string o;
    integer x;
    integer y;
    if (int < 0)
    {
        x = ((0x7FFFFFFF & int) % 64) - (0x80000000 % 64);
        y = x % 64;
        int = (x / 64) + ((0x7FFFFFFF & int) / 64) - (0x80000000 / 64);
        o = llGetSubString(XIVAR_CHARSET_64, y, y);
    }
    do o = llGetSubString(XIVAR_CHARSET_64, x = int % 64, x) + o;
    while (int /= 64);
    while (llStringLength(o) < length) o = "0" + o;
    return o;
}

integer XiInteger_FromStr64( // inverse of XiInteger_ToString64
    string str
    )
{
    integer i = -llStringLength(str);
    integer x = 0;
    while (i) x = (x * 64) + llSubStringIndex(XIVAR_CHARSET_64, llGetSubString(str, i, i++));
    return x;
}

integer XiInteger_Clamp(
    integer i,
    integer m,
    integer x
    )
{
    if (i < m) i = m; // clamp to minimum
    if (i > x) i = x; // clamp to maXimum
    return i;
}

integer XiInteger_Reset(
    integer i,
    integer m,
    integer x,
    integer t
    )
{
    if (i < m || i > x) i = t; // set to target if outside min/max
    return i;
}
