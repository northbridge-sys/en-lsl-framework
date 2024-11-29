/*
    on_rez.lsl
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

    This snippet replaces the on_rez event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN$ON_REZ
		en$on_rez( integer param )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN$ON_REZ_TRACE || defined EN$ON_REZ || defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF
	on_rez( integer param )
	{
#endif

        // log event if requested
        #ifdef EN$ON_REZ_TRACE
            enLog$TraceParams( "on_rez", [], [ param ] );
        #endif

        // update enChat channels if any are just the UUID
        #ifdef ENCHAT$ENABLE
            _enChat$RefreshLinkset();
        #endif

        // update enLSD names if any use the UUID header
        #ifdef ENLSD$ENABLE_UUID_HEADER
            _enLSD$CheckUUID();
        #endif

        // pass to user-defined function if requested
		#ifdef EN$ON_REZ
			en$on_rez(param);
		#endif

		// update _ENOBJECT_UUIDS_SELF
        #if defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF
            _enObject$UpdateUUIDs();
        #endif

#if defined EN$ON_REZ_TRACE || defined EN$ON_REZ || defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF
	}
#endif
