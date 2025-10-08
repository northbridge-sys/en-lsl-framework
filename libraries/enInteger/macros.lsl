/*
enInteger.lsl
Library Macros
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
*/

#define INTEGER_MAX 0x7FFFFFFF
#define INTEGER_MIN 0x80000000
#define INTEGER_NEGATIVE 0x80000000

#ifndef ENINTEGER_CHARSET_16
    #define ENINTEGER_CHARSET_16 "0123456789abcdef"
#endif
#ifndef ENINTEGER_CHARSET_64
    #define ENINTEGER_CHARSET_64 "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-="
#endif
#ifndef ENINTEGER_CHARSET_256
    #define ENINTEGER_CHARSET_256 ""
#endif

#if defined EN_TRACE_LIBRARIES
    #define ENINTEGER_TRACE
#endif

#define enInteger_Rand() \
    (integer)( "0x" + llGetSubString( llGenerateKey(), 0, 7 ))

// good enough!
#define enInteger_IsPositiveOrZero(i) \
    !(i & INTEGER_NEGATIVE)
#define enInteger_IsNegative(i) \
    (i & INTEGER_NEGATIVE)
#define enInteger_GetSignZeroPositive(i) \
    (enInteger_IsPositiveOrZero(i) * 2 - 1)

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

/*
flips bits efficiently
just a reminder that bitwise XOR exists, so you don't try doing any shenanigans with enInteger_SetBit
*/
#define enInteger_FlipBits(bitfield, position) \
    (bitfield ^ position)
