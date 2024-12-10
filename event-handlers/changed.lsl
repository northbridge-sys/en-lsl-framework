/*
    changed.lsl
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

    This snippet replaces the changed event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN$CHANGED
		en$changed( integer change )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN$CHANGED_TRACE || defined EN$CHANGED || defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF || defined ENOBJECT$ENABLE_LINK_CACHE
	changed( integer change )
	{
#endif

        // log event if requested
        #ifdef EN$CHANGED_TRACE
            enLog$TraceParams( "changed", [ "change" ], [ enInteger$ElemBitfield( change ) ] );
        #endif

        #if defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF || defined ENOBJECT$ENABLE_LINK_CACHE
            if ( change & CHANGED_LINK )
            {
        #endif
        
                #ifdef ENCHAT$ENABLE
                    _enCLEP$RefreshLinkset();
                #endif
                #ifdef ENLSD$ENABLE_UUID_HEADER
                    enLSD$CheckUUID();
                #endif
                #if defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF
                    _enObject$UpdateUUIDs();
                #endif
                #ifdef ENOBJECT$ENABLE$LINK_CACHE
                    _enObject$LinkCacheUpdate();
                #endif

        #if defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF || defined ENOBJECT$ENABLE_LINK_CACHE
            }
        #endif

        // pass to user-defined function if requested
		#ifdef EN$ATTACH
			en$changed( change );
		#endif

#if defined EN$CHANGED_TRACE || defined EN$CHANGED || defined ENCHAT$ENABLE || defined ENLSD$ENABLE_UUID_HEADER || defined ENOBJECT$ENABLE_SELF || defined ENOBJECT$ENABLE_LINK_CACHE
	}
#endif
