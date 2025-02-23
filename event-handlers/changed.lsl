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

		#define EN_CHANGED
		en_changed( integer change )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_CHANGED_TRACE || defined EN_CHANGED || defined ENCLEP_ENABLE || defined ENLSD_ENABLE_SCRIPT_NAME_HEADER || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF || defined ENOBJECT_ENABLE_LINK_CACHE || defined ENOBJECT_ALWAYS_PHANTOM
	changed( integer change )
	{
#endif

        // log event if requested
        #if defined EN_CHANGED_TRACE
            enLog_TraceParams( "changed", [ "change" ], [ enInteger_ElemBitfield( change ) ] );
        #endif

        #if defined ENCLEP_ENABLE || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF || defined ENOBJECT_ENABLE_LINK_CACHE || defined ENOBJECT_ALWAYS_PHANTOM
            if ( change & CHANGED_LINK )
            {
        #endif
        
                #if defined ENCLEP_ENABLE
                    enCLEP_RefreshLinkset();
                #endif

                #if defined ENLSD_ENABLE_UUID_HEADER && !defined ENLSD_DISABLE_UUID_CHECK
                    enLSD_CheckUUID();
                #endif

                #if defined ENCLEP_ENABLE || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF
                    enObject_UpdateUUIDs();
                #endif

                #if defined ENOBJECT_ENABLE_LINK_CACHE
                    enObject_LinkCacheUpdate();
                #endif

                #if defined ENOBJECT_ALWAYS_PHANTOM
                    enObject_AlwaysPhantom();
                #endif

        #if defined ENCLEP_ENABLE || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF || defined ENOBJECT_ENABLE_LINK_CACHE || defined ENOBJECT_ALWAYS_PHANTOM
            }
        #endif

        #if defined ENLSD_ENABLE_SCRIPT_NAME_HEADER
            if ( change & CHANGED_INVENTORY )
            {
                enLSD_CheckScriptName();
            }
        #endif

        // pass to user-defined function if requested
		#if defined EN_CHANGED
			en_changed( change );
		#endif

#if defined EN_CHANGED_TRACE || defined EN_CHANGED || defined ENCLEP_ENABLE || defined ENLSD_ENABLE_SCRIPT_NAME_HEADER || defined ENLSD_ENABLE_UUID_HEADER || defined ENOBJECT_ENABLE_SELF || defined ENOBJECT_ENABLE_LINK_CACHE || defined ENOBJECT_ALWAYS_PHANTOM
	}
#endif
