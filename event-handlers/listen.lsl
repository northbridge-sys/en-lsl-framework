/*
    listen.lsl
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

    This snippet replaces the listen event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI_LISTEN
		Xi$listen( integer channel, string name, key id, string message )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#ifdef XI_ALL_ENABLE_XILOG_TRACE
    #define XI_LISTEN_ENABLE_XILOG_TRACE
#endif

	listen( integer channel, string name, key id, string message )
	{
        // log event if requested
        #ifdef XI_LISTEN_ENABLE_XILOG_TRACE
            XiLog$TraceParams( "listen", [ "channel", "name", "id", "message" ], [ channel, XiString$Elem( name ), XiObject$Elem( id ), XiString$Elem( message ) ] );
        #endif

        // check if any Xi libraries want to intercept this event
		if ( _XiChat$Process( channel, name, id, message ) ) return; // valid XiChat message
        // non-XiChat message

        // pass to user-defined function if requested
		#ifdef XI_LISTEN
			Xi$listen( channel, name, id, message );
		#endif
	}
