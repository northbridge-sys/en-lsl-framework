/*
    remote_data.lsl
    Event Handler
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

    This snippet replaces the remote_data event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_REMOTE_DATA
		en_remote_data( integer type, key channel, key message_id, string sender,
            integer i, string s )
		{
            // code to run when event occurs that is not intercepted by En
		}
    
    NOTE: The remote_data event was deprecated in 2023, so this event will no longer
    fire; it is only included here for completeness and should not be enabled.
*/

#if defined EN_REMOTE_DATA
	remote_data( integer type, key channel, key message_id, string sender, integer i, string s )
	{
#endif

        // log event if requested
        #if defined EN_REMOTE_DATA && defined EN_REMOTE_DATA_TRACE
            enLog_TraceParams( "remote_data", [ "type", "channel", "message_id", "sender", "i", "s" ], [
                type,
                enString_Elem( channel ),
                enString_Elem( message_id ),
                enString_Elem( sender ),
                i,
                enString_Elem( s )
            ] );
        #endif

#if defined EN_REMOTE_DATA
        // event unused, so pass to user-defined function only
        en_remote_data( type, channel, message_id, sender, i, s );
	}
#endif
