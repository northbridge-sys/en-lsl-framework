/*
    attach.lsl
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

    This snippet replaces the attach event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN$ATTACH
		en$attach( key id )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN$ATTACH_TRACE || defined EN$ATTACH || defined EN$ATTACH_BLOCK
	attach( key id )
	{
#endif

        // log event if requested
        #ifdef EN$ATTACH_TRACE
            enLog$TraceParams( "attach", [ "id" ], [ enString$Elem( id ) ]);
        #endif

        // if attaches are blocked, perform auto-detach procedure
        #ifdef EN$ATTACH_BLOCK
            if ((string)id != NULL_KEY && llGetAttached()) // check both to be safe, never know
            {
                enLog$FatalDie("This object cannot be used as an attachment.");
                return;
            }
        #endif

        // pass to user-defined function if requested
		#ifdef EN$ATTACH
			en$attach( id );
		#endif

#if defined EN$ATTACH_TRACE || defined EN$ATTACH || defined EN$ATTACH_BLOCK
	}
#endif
