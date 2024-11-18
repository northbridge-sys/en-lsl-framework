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

		#define XI$LISTEN
		Xi$listen( integer channel, string name, key id, string message )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$LISTEN_TRACE || defined XI$LISTEN || defined XICHAT$ENABLE
	listen( integer channel, string name, key id, string message )
	{
#endif

        // log event if requested
        #ifdef XI$LISTEN_TRACE
            XiLog$TraceParams( "listen", [ "channel", "name", "id", "message" ], [ channel, XiString$Elem( name ), XiObject$Elem( id ), XiString$Elem( message ) ] );
        #endif

        #ifdef XICHAT$ENABLE
		    if ( _XiChat$Process( channel, name, id, message ) ) return; // valid XiChat message
        #endif
        
        // pass to user-defined function if requested
		#ifdef XI$LISTEN
			Xi$listen( channel, name, id, message );
		#endif

#if defined XI$LISTEN_TRACE || defined XI$LISTEN || defined XICHAT$ENABLE
	}
#endif
