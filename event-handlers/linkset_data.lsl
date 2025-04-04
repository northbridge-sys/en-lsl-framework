/*
    linkset_data.lsl
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

    This snippet replaces the linkset_data event handler with a version that
    calls maintenance functions required by En libraries, then optionally executes a
    user-defined function to handle event calls that are not intercepted by En
    libraries:

		#define EN_LINKSET_DATA
		en_linkset_data( integer action, string name, string value )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_LINKSET_DATA
    linkset_data( integer action, string name, string value )
    {
#endif

        // log event if requested
        #if defined EN_LINKSET_DATA_TRACE && defined EN_LINKSET_DATA
            enLog_TraceParams( "linkset_data", [ "action", "name", "value" ], [ action, enString_Elem(name), enString_Elem(value) ] );
        #endif

        // pass to user-defined function if requested
		#if defined EN_LINKSET_DATA
			en_linkset_data(action, name, value);
		#endif

#if defined EN_LINKSET_DATA
	}
#endif
