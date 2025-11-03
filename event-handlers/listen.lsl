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

#if defined EVENT_EN_LISTEN || defined FEATURE_ENCLEP_ENABLE
	listen( integer channel, string name, key id, string message )
	{
#endif

        // log event if requested
        #if defined TRACE_EVENT_EN_LISTEN && (defined EVENT_EN_LISTEN || defined FEATURE_ENCLEP_ENABLE)
            enLog_TraceParams( "listen", [ "channel", "name", "id", "message" ], [ channel, enString_Elem( name ), enObject_Elem( id ), enString_Elem( message ) ] );
        #endif

        #if defined FEATURE_ENCLEP_ENABLE
		    if ( !_enclep_listen( channel, name, id, message ) ) return; // valid enCLEP message
        #endif
        
        // pass to user-defined function if requested
		#if defined EVENT_EN_LISTEN
			en_listen( channel, name, id, message );
		#endif

#if defined EVENT_EN_LISTEN || defined FEATURE_ENCLEP_ENABLE
	}
#endif
