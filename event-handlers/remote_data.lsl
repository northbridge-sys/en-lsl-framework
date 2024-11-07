/*
    remote_data.lsl
    Event Handler
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

    This snippet replaces the remote_data event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI_REMOTE_DATA
		Xi$remote_data( integer type, key channel, key message_id, string sender,
            integer i, string s )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
    
    NOTE: The remote_data event was deprecated in 2023, so this event will no longer
    fire; it is only included here for completeness and should not be enabled.
*/

#ifdef XI_REMOTE_DATA
	remote_data( integer type, key channel, key message_id, string sender, integer i, string s )
	{
        // event unused, so the only reason to define it is to log it
        XiLog$TraceParams( "remote_data", [ "type", "channel", "message_id", "sender", "i", "s" ], [
            type,
            XiString$Elem( channel ),
            XiString$Elem( message_id ),
            XiString$Elem( sender ),
            i,
            XiString$Elem( s )
        ] );

        // event unused, so pass to user-defined function only
        Xi$remote_data( type, channel, message_id, sender, i, s );
	}
#endif
