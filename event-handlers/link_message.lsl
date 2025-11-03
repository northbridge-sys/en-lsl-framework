/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework

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

#if defined EVENT_EN_LINK_MESSAGE || defined EVENT_ENLEP_MESSAGE
    link_message( integer l, integer i, string s, key k )
    {
#endif

        // log event if requested
        #if defined TRACE_EVENT_EN_LINK_MESSAGE && (defined EVENT_EN_LINK_MESSAGE || defined EVENT_ENLEP_MESSAGE)
            enLog_TraceParams( "link_message", [ "l", "i", "s", "k" ], [ l, i, enString_Elem( s ), enString_Elem( k ) ] );
        #endif

        #if defined EVENT_ENLEP_MESSAGE
            if ( enLEP_Process(l, i, s, k)) return; // valid LEP message
        #endif

        // pass to user-defined function if requested
		#if defined EVENT_EN_LINK_MESSAGE
			en_link_message( l, i, s, k );
		#endif

#if defined EVENT_EN_LINK_MESSAGE || defined EVENT_ENLEP_MESSAGE
	}
#endif
