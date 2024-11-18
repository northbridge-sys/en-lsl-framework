/*
    on_rez.lsl
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

    This snippet replaces the on_rez event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$ON_REZ
		Xi$on_rez( integer param )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$ON_REZ_TRACE || defined XI$ON_REZ || defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF
	on_rez( integer param )
	{
#endif

        // log event if requested
        #ifdef XI$ON_REZ_TRACE
            XiLog$TraceParams( "on_rez", [], [ i ] );
        #endif

        // update XiChat channels if any are just the UUID
        #ifdef XICHAT$ENABLE
            _XiChat$RefreshLinkset();
        #endif

        // update XiLSD names if any use the UUID header
        #ifdef XILSD$ENABLE_UUID_HEADER
            _XiLSD$CheckUUID();
        #endif

        // pass to user-defined function if requested
		#ifdef XI$ON_REZ
			Xi$on_rez(i);
		#endif

		// update _XIOBJECT_UUIDS_SELF
        #if defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF
            _XiObject$UpdateUUIDs();
        #endif

#if defined XI$ON_REZ_TRACE || defined XI$ON_REZ || defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF
	}
#endif
