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

#if defined EVENT_EN_ATTACH || defined FUNCTION_EN_ATTACH_BLOCK
	attach( key id )
	{
#endif

        // log event if requested
        #if defined TRACE_EVENT_EN_ATTACH && (defined EVENT_EN_ATTACH || defined FUNCTION_EN_ATTACH_BLOCK)
            enLog_TraceParams( "attach", [ "id" ], [ enString_Elem( id ) ]);
        #endif

        // if attaches are blocked, perform auto-detach procedure
        #if defined FUNCTION_EN_ATTACH_BLOCK
            if ((string)id != NULL_KEY && llGetAttached()) // check both to be safe, never know
            {
                enLog_FatalDie("This object cannot be used as an attachment.");
                return;
            }
        #endif

        // pass to user-defined function if requested
		#if defined EVENT_EN_ATTACH
			en_attach( id );
		#endif

#if defined EVENT_EN_ATTACH || defined FUNCTION_EN_ATTACH_BLOCK
	}
#endif
