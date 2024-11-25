/*
    linkset_data.lsl
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

    This snippet replaces the linkset_data event handler with a version that
    calls maintenance functions required by Xi libraries, then optionally executes a
    user-defined function to handle event calls that are not intercepted by Xi
    libraries:

		#define XI$LINKSET_DATA
		Xi$linkset_data( integer action, string name, string value )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$LINKSET_DATA_TRACE || defined XI$LINKSET_DATA
    linkset_data( integer action, string name, string value )
    {
#endif

        // log event if requested
        #ifdef XI$LINKSET_DATA_TRACE
            XiLog$TraceParams( "linkset_data", [ "action", "name", "value" ], [ action, XiString$Elem(name), XiString$Elem(value) ] );
        #endif

        // pass to user-defined function if requested
		#ifdef XI$LINKSET_DATA
			Xi$linkset_data(action, name, value);
		#endif

#if defined XI$LINKSET_DATA_TRACE || defined XI$LINKSET_DATA
	}
#endif