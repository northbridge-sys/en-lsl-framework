/*
    state_entry.lsl
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

    This snippet replaces the state_entry event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_STATE_ENTRY
		en_state_entry()
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

	state_entry()
	{
        // log event if requested
        #if defined EN_STATE_ENTRY_TRACE
            enLog_TraceParams( "state_entry", [], [] );
        #endif

        // stop immediately if the "stop" LSD pair is set (used for updaters)
        #if !defined ENOBJECT_DISABLE_STOPIFFLAGGED
            enObject_StopIfFlagged();
        #endif

        // stop immediately if rezzed by owner and flag is set (used for objects intended to be rezzed by a rezzer)
        #if defined ENOBJECT_STOPIFOWNERREZZED
            enObject_StopIfOwnerRezzed();
        #endif

		// update _ENOBJECT_UUIDS_SELF if needed
        #if defined FEATURE_ENCLEP_ENABLE || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF
            enObject_UpdateUUIDs();
        #endif

        // check if any En libraries want to intercept this event
        #if defined ENLSD_ENABLE_UUID_HEADER && !defined ENLSD_DISABLE_UUID_CHECK
            enLSD_CheckUUID();
        #endif

        #if defined ENLSD_ENABLE_SCRIPT_NAME_HEADER
            enLSD_CheckScriptName();
        #endif

        #if defined ENOBJECT_ALWAYS_PHANTOM
            enObject_AlwaysPhantom();
        #endif

        // pass to user-defined function if requested
		#if defined EN_STATE_ENTRY
			en_state_entry();
		#endif
	}
