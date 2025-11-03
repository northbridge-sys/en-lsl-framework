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

	on_rez( integer param )
	{
        // log event if requested
        #if defined TRACE_EVENT_EN_ON_REZ
            enLog_TraceParams( "on_rez", [], [ param ] );
        #endif

        // stop immediately if the "stop" LSD pair is set (used for updaters)
        #if !defined FEATURE_ENOBJECT_DISABLE_STOPIFFLAGGED
            enObject_StopIfFlagged();
        #endif

        // stop immediately if rezzed by owner and flag is set (used for objects intended to be rezzed by a rezzer)
        #if defined FEATURE_ENOBJECT_ENABLE_STOPIFOWNERREZZED
            enObject_StopIfOwnerRezzed();
        #endif

		// update _ENOBJECT_UUIDS_SELF
        #if defined FEATURE_ENCLEP_ENABLE || defined FEATURE_ENLSD_ENABLE_UUID_HEADER || defined FEATURE_ENOBJECT_ENABLE_SELF
            enObject_UpdateUUIDs();
        #endif

        // update enCLEP channels if any are just the UUID
        #if defined FEATURE_ENCLEP_ENABLE
            _enCLEP_RefreshLinkset();
        #endif

        // update enLSD names if any use the UUID header
        #if defined FEATURE_ENLSD_ENABLE_UUID_HEADER && !defined FEATURE_ENLSD_DISABLE_UUID_CHECK
            enLSD_CheckUUID();
        #endif

        // pass to user-defined function if requested
		#if defined EVENT_EN_ON_REZ
			en_on_rez(param);
		#endif
	}
