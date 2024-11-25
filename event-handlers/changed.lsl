/*
    changed.lsl
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

    This snippet replaces the changed event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$CHANGED
		Xi$changed( integer change )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$CHANGED_TRACE || defined XI$CHANGED || defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF || defined XIOBJECT$ENABLE_LINK_CACHE
	changed( integer change )
	{
#endif

        // log event if requested
        #ifdef XI$CHANGED_TRACE
            XiLog$TraceParams( "changed", [ "change" ], [ XiInteger$ElemBitfield( change ) ] );
        #endif

        #if defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF || defined XIOBJECT$ENABLE_LINK_CACHE
            if ( change & CHANGED_LINK )
            {
        #endif
        
                #ifdef XICHAT$ENABLE
                    _XiChat$RefreshLinkset();
                #endif
                #ifdef XILSD$ENABLE_UUID_HEADER
                    _XiLSD$CheckUUID();
                #endif
                #if defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF
                    _XiObject$UpdateUUIDs();
                #endif
                #ifdef XIOBJECT$ENABLE$LINK_CACHE
                    _XiObject$LinkCacheUpdate();
                #endif

        #if defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF || defined XIOBJECT$ENABLE_LINK_CACHE
            }
        #endif

        // pass to user-defined function if requested
		#ifdef XI$ATTACH
			Xi$changed( change );
		#endif

#if defined XI$CHANGED_TRACE || defined XI$CHANGED || defined XICHAT$ENABLE || defined XILSD$ENABLE_UUID_HEADER || defined XIOBJECT$ENABLE_SELF || defined XIOBJECT$ENABLE_LINK_CACHE
	}
#endif
