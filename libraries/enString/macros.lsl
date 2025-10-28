/*
enString.lsl
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
*/

#define ENSTRING_PAD_ALIGN_LEFT 0
#define ENSTRING_PAD_ALIGN_RIGHT 1
#define ENSTRING_PAD_ALIGN_CENTER 2
#define ENSTRING_ESCAPE_FILTER_REGEX 0x1
#define ENSTRING_ESCAPE_FILTER_JSON 0x2
#define ENSTRING_ESCAPE_REVERSE 0x40000000

#if defined EN_TRACE_LIBRARIES
    #define ENSTRING_TRACE
#endif

#define enString_Elem(s) \
    "\"" + s + "\""

#define enString_UTF8Bytes(s) \
    ((llStringLength((string)llParseString2List(llStringToBase64(s), ["="], [])) * 3) >> 2)
