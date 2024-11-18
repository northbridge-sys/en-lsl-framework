/*
    dataserver.lsl
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

    This snippet replaces the dataserver event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$DATASERVER
		Xi$dataserver( key query, string data )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$DATASERVER_TRACE || defined XI$DATASERVER || defined XIINVENTORY$ENABLE_NC
	dataserver( key query, string data )
	{
#endif

        // log event if requested
        #ifdef XI$DATASERVER_TRACE
            XiLog$TraceParams( "dataserver", [ "query", "data" ], [ XiString$Elem( query ), XiString$Elem( data ) ] );
        #endif

        // check if any Xi libraries want to intercept this event
        #ifdef XIINVENTORY$ENABLE_NC
            if ( query == XIINVENTORY$NC_K ) _XiInventory$NCParse( data ); // XiInventory$NCRead(...) response
        #endif

        // pass to user-defined function if requested
		#ifdef XI$DATASERVER
			Xi$dataserver( query, data );
		#endif

#if defined XI$DATASERVER_TRACE || defined XI$DATASERVER || defined XIINVENTORY$ENABLE_NC
	}
#endif
