/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework

This script is free software: you can redistribute it and/or modify it under the
terms of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this script.  If not, see <https://www.gnu.org/licenses/>.
*/

#if defined EVENT_EN_CHANGED \
 || defined FEATURE_ENCLEP_ENABLE \
 || defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER \
 || defined FEATURE_ENLSD_ENABLE_UUID_HEADER \
 || defined FEATURE_ENOBJECT_ENABLE_SELF \
 || defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE \
 || defined FEATURE_ENOBJECT_ALWAYS_PHANTOM
	changed( integer change )
	{
#endif

        #if defined EVENT_EN_CHANGED_DROP
            if (!(change & ~EVENT_EN_CHANGED_DROP)) return;
        #endif

        // log event if requested
        #if defined EVENT_EN_CHANGED_TRACE && ( \
                defined EVENT_EN_CHANGED \
             || defined FEATURE_ENCLEP_ENABLE \
             || defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER \
             || defined FEATURE_ENLSD_ENABLE_UUID_HEADER \
             || defined FEATURE_ENOBJECT_ENABLE_SELF \
             || defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE \
             || defined FEATURE_ENOBJECT_ALWAYS_PHANTOM \
            )
            enLog_TraceParams( "changed", [ "change" ], [ enInteger_ElemBitfield( change ) ] );
        #endif

        #if defined FEATURE_ENCLEP_ENABLE \
         || defined FEATURE_ENLSD_ENABLE_UUID_HEADER \
         || defined FEATURE_ENOBJECT_ENABLE_SELF \
         || defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE \
         || defined FEATURE_ENOBJECT_ALWAYS_PHANTOM
            if ( change & CHANGED_LINK )
            {
        #endif
        
                #if defined FEATURE_ENCLEP_ENABLE
                    _enCLEP_RefreshLinkset();
                #endif

                #if defined FEATURE_ENLSD_ENABLE_UUID_HEADER && !defined FEATURE_ENLSD_DISABLE_UUID_CHECK
                    enLSD_CheckUUID();
                #endif

                #if defined FEATURE_ENCLEP_ENABLE || defined FEATURE_ENLSD_ENABLE_UUID_HEADER || defined FEATURE_ENOBJECT_ENABLE_SELF
                    enObject_UpdateUUIDs();
                #endif

                #if defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE
                    enObject_LinkCacheUpdate();
                #endif

                #if defined FEATURE_ENOBJECT_ALWAYS_PHANTOM
                    enObject_AlwaysPhantom();
                #endif

        #if defined FEATURE_ENCLEP_ENABLE \
         || defined FEATURE_ENLSD_ENABLE_UUID_HEADER \
         || defined FEATURE_ENOBJECT_ENABLE_SELF \
         || defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE \
         || defined FEATURE_ENOBJECT_ALWAYS_PHANTOM
            }
        #endif

        #if defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER
            if ( change & CHANGED_INVENTORY )
            {
                enLSD_CheckScriptName();
            }
        #endif

        // pass to user-defined function if requested
		#if defined EVENT_EN_CHANGED
			en_changed( change );
		#endif

#if defined EVENT_EN_CHANGED \
 || defined FEATURE_ENCLEP_ENABLE \
 || defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER \
 || defined FEATURE_ENLSD_ENABLE_UUID_HEADER \
 || defined FEATURE_ENOBJECT_ENABLE_SELF \
 || defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE \
 || defined FEATURE_ENOBJECT_ALWAYS_PHANTOM
	}
#endif
