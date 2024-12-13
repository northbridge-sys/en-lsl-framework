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

		#define EN$STATE_ENTRY
		en$state_entry()
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN$STATE_ENTRY_TRACE || defined EN$STATE_ENTRY || defined ENCLEP$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENLSD$ENABLE_SCRIPT_NAME_HEADER || defined ENOBJECT$ENABLE_SELF
	state_entry()
	{
#endif

        // log event if requested
        #ifdef EN$STATE_ENTRY_TRACE
            enLog$TraceParams( "state_entry", [], [] );
        #endif

        // check if any En libraries want to intercept this event
        #ifdef ENLSD$ENABLE_UUID_HEADER
            enLSD$CheckUUID();
        #endif

        #ifdef ENLSD$ENABLE_SCRIPT_NAME_HEADER
            enLSD$CheckScriptName();
        #endif

        // pass to user-defined function if requested
		#ifdef EN$STATE_ENTRY
			en$state_entry();
		#endif

		// update _ENOBJECT_UUIDS_SELF if needed
        #if defined ENCLEP$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF
            _enObject$UpdateUUIDs();
        #endif

#if defined EN$STATE_ENTRY_TRACE || defined EN$STATE_ENTRY || defined ENCLEP$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENLSD$ENABLE_SCRIPT_NAME_HEADER || defined ENOBJECT$ENABLE_SELF
	}
#endif
