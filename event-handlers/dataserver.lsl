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

		#define XI_DATASERVER
		Xi_dataserver( key query, string data )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#ifdef XI_ALL_ENABLE_XILOG_TRACE
    #define XI_DATASERVER_ENABLE_XILOG_TRACE
#endif

	dataserver( key query, string data )
	{
        // log event if requested
        #ifdef XI_DATASERVER_ENABLE_XILOG_TRACE
            XiLog_TraceParams( "dataserver", [ "query", "data" ], [ XiString_Elem( query ), XiString_Elem( data ) ] );
        #endif

        // check if any Xi libraries want to intercept this event
        #ifdef XIINVENTORY_ENABLE_NC
            if ( query == XIINVENTORY_NC_K ) _XiInventory_NCParse( data ); // XiInventory_NCRead(...) response
        #endif

        // pass to user-defined function if requested
		#ifdef XI_DATASERVER
			Xi_dataserver( query, data );
		#endif
	}
