/*
    listen.lsl
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

    This snippet replaces the listen event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_LISTEN
		en_listen( integer channel, string name, key id, string message )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_LISTEN_TRACE || defined EN_LISTEN || defined ENCLEP_ENABLE
	listen( integer channel, string name, key id, string message )
	{
#endif

        // log event if requested
        #ifdef EN_LISTEN_TRACE
            enLog_TraceParams( "listen", [ "channel", "name", "id", "message" ], [ channel, enString_Elem( name ), enObject_Elem( id ), enString_Elem( message ) ] );
        #endif

        #ifdef ENCLEP_ENABLE
		    if ( enCLEP_Process( channel, name, id, message ) ) return; // valid enCLEP message
        #endif
        
        // pass to user-defined function if requested
		#ifdef EN_LISTEN
			en_listen( channel, name, id, message );
		#endif

#if defined EN_LISTEN_TRACE || defined EN_LISTEN || defined ENCLEP_ENABLE
	}
#endif
