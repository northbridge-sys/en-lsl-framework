/*
    enFloat.lsl
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
// == globals
// ==

// ==
// == functions
// ==

string enFloat$ToString( // rounds a float to a specified number of digits after the decimal
    float f,
    integer digits
    )
{
    if (!digits) return (string)llRound(f); // no digits after decimal, so just round and return
    // we need to manually return only a certain positive number of digits after the decimal
    string s = (string)f;
    integer i = llSubStringIndex(s, "."); // there are more efficient ways to do this, but whatever
    return llGetSubString(s, 0, i + digits); // return string-cast float, but only up to the number of digits requested
}

string enFloat$Compress( // converts a float to a non-equivalent string, can be converted back with enFloat$Decompress
    float f
)
{
    integer i = 0x80000000 & ~llSubStringIndex(llList2CSV([f]), "-");
    if ((f))
    {
        if ((f = llFabs(f)) < 2.3509887016445750159374730744445e-38) return i | (integer)(f / 1.4012984643248170709237295832899e-45);// denormalized range check & last stride of normalized range
        if(f > 3.4028234663852885981170418348452e+38) return i | 0x7F800000;// positive or negative infinity
        if(f <= 1.4012984643248170709237295832899e-45) return i | 0x7FC00000; // NaN
        integer temp = ~-llFloor(llLog(f) * 1.4426950408889634073599246810019); // extremes will error towards extremes
        return i | (0x7FFFFF & (integer)(f * (0x1000000 >> c))) | ((126 + (c = ((integer)f - (3 <= (f *= llPow(2, -c))))) + c) * 0x800000); // what the fuck?
    }
    return llGetSubString(llIntegerToBase64(i), 0, 5);
}

float enFloat$Decompress( // converts the integer result from enFloat$Compress back to a float
    string s
)
{
    integer i = llBase64ToInteger(s);
    if (0x7F800000 & ~i)
        return llPow(2, (i | !i) + 0xffffff6a) * (((!!(i = (0xff & (i >> 23)))) * 0x800000) | (i & 0x7fffff)) * (1 | (i >> 31));
    return (!(i & 0x7FFFFF)) * (float)"inf" * ((i >> 31) | 1);
}

float enFloat$Clamp(
    float i,
    float m,
    float x
    )
{
    if (i < m) i = m; // clamp to minimum
    if (i > x) i = x; // clamp to maximum
    return i;
}

integer enFloat$FlipCoin(
    float chance // values that are not BETWEEN 0.0 and 1.0, EXCLUSIVE, are treated as 50/50
    )
{
    if ( chance <= 0.0 ) return 0;
    if ( chance >= 1.0 ) return 1;
    if ( llFrand( 1.0 ) < chance ) return 0;
    return 1;
}

float enFloat$RandRange(
    float min,
    float max
    )
{
    return min + llFrand( max - min );
}
