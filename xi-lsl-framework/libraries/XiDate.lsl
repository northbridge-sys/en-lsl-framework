/*
    XiDate.lsl
    Library
    Xi LSL Framework
    Revision 0
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

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XIDATE_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

integer XiDate_MS( // gets an integer in the range [ -617316353, 2147483547 ] that represents the current millisecond of a month
    string timestamp // llGetTimestamp string (use XiDate_MSNow() for the current value)
    )
{
    return (integer)llGetSubString( timestamp, 8, 9 ) * 86400000 + // days * ms_per_day
        (integer)llGetSubString( timestamp, 11, 12 ) * 3600000 + // hours * ms_per_hour
        (integer)llGetSubString( timestamp, 14, 15 ) * 60000 + // minutes * ms_per_minute
        llRound( ( (float)llGetSubString( timestamp, 17, -2 ) * 1000.0 ) ) // seconds.ms * ms_per_second
        - 617316353; // offset negative so it fits within [ -617316353, 2147483547 ]
}

integer XiDate_MSNow() // gets the value of XiDate_MS( ... ) for the current datetime
{
    return XiDate_MS( llGetTimestamp() );
}
