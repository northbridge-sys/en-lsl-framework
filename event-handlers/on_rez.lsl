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

		#define EN_ON_REZ
		en_on_rez( integer param )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

	on_rez( integer param )
	{
        // log event if requested
        #ifdef EN_ON_REZ_TRACE
            enLog_TraceParams( "on_rez", [], [ param ] );
        #endif

        // stop immediately if the "stop" LSD pair is set (used for updaters)
        enObject_StopIfFlagged();

        // stop immediately if rezzed by owner and flag is set (used for objects intended to be rezzed by a rezzer)
        #ifdef ENOBJECT_STOPIFOWNERREZZED
            enObject_StopIfOwnerRezzed();
        #endif

        // update enCLEP channels if any are just the UUID
        #ifdef ENCLEP_ENABLE
            enCLEP_RefreshLinkset();
        #endif

        // update enLSD names if any use the UUID header
        #if defined ENLSD_ENABLE_UUID_HEADER && !defined ENLSD_SKIP_CHECK_UUID
            enLSD_CheckUUID();
        #endif

        // pass to user-defined function if requested
		#ifdef EN_ON_REZ
			en_on_rez(param);
		#endif

		// update _ENOBJECT_UUIDS_SELF
        #if defined ENCLEP_ENABLE || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF
            enObject_UpdateUUIDs();
        #endif
	}
