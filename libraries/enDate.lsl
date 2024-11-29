/*
    enDate.lsl
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

integer enDate$MS( // gets an integer that represents the current millisecond of a month
    string timestamp // llGetTimestamp string (use enDate$MSNow() for the current value)
    )
{
    return 0x80000000 + // start at -2147483648
        (integer)llGetSubString( timestamp, 8, 9 ) * 86400000 + // days * ms_per_day (-2147483648 + (31 * 86400000) = 530916352)
        (integer)llGetSubString( timestamp, 11, 12 ) * 3600000 + // hours * ms_per_hour (530916352 + (23 * 3600000) = 613716352)
        (integer)llGetSubString( timestamp, 14, 15 ) * 60000 + // minutes * ms_per_minute (613716352 + (59 * 60000) = 617256352)
        (integer)( (float)llGetSubString( timestamp, 17, -2 ) * 1000.0 ); // seconds.ms * ms_per_second (617256352 + 60000 = 617316352)
    // total range is 2764800000 ms, or ms in 31 days
}

integer enDate$MSNow() // gets the value of enDate$MS( ... ) for the current datetime
{
    return enDate$MS( llGetTimestamp() );
}

integer enDate$MSAdd( // since milliseconds can wrap around in a weird way at the start of the month
    integer ms, // enDate$MS result
    integer add // milliseconds to add - note this is limited to 
)
{
    // check if adding takes us into the "dead zone" of 617316352 to 2147483647
    if ( ms + add > 617316352 ) return ( ms + add ) + 2764800000 * ( -1 * ( add > 0 ) ); // if we are adding +, subtract the entire range; otherwise, add it
    return ms + add; // no adjustment needed
}
