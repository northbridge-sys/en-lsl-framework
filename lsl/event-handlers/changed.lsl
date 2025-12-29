/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-framework

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

// if we want enLNX to allow prim-scope or script-scope pairs, and we have not marked this as a "passive" script (only one script needs to run enLEP_changed() to maintain the datastore), trigger _enLEP_changed()
#if defined FEATURE_ENLNX_ENABLE_SCOPE && defined FEATURE_ENLNX_PRIM_MONITOR
    #define _EVENT_CHANGED
    #define _HOOK_ENLNX_CHANGED
#endif

/*
if:
- we want to receive any CLEP-RPC messages
- we are using enLNX scopes
- we have manually enabled enPrim_GetMyLast() support
- we have manually enabled enPrim link caching
- we have enabled FEATURE_ENPRIM_ALWAYS_PHANTOM
trigger _enPrim_changed()
*/
#if defined _HOOK_ENCLEP_CHANGED || defined _HOOK_ENLNX_CHANGED || OVERRIDE_ENPRIM_LIMIT_GETMYSELF > 0 || defined FEATURE_ENPRIM_ENABLE_LINK_CACHE || defined FEATURE_ENPRIM_ALWAYS_PHANTOM
    #define _EVENT_CHANGED
    #define _HOOK_ENPRIM_CHANGED
#endif

// if we defined EVENT_EN_CHANGED, pass all non-caught changed() events to en_changed()
#if defined EVENT_EN_CHANGED
    #define _EVENT_CHANGED
    #define _HOOK_EN_CHANGED
#endif

// if we are using changed() and want to trace it, define the trace hook
#if defined _EVENT_CHANGED && defined TRACE_EVENT_CHANGED
    #define _TRACE_EVENT_CHANGED
#endif

#if defined _EVENT_CHANGED
	changed( integer change )
	{
#endif

        // drop changes that are in FEATURE_CHANGED_DROP (used to drop spurious changes in certain edge cases)
        #if defined FEATURE_CHANGED_DROP
            if (!(change & ~FEATURE_CHANGED_DROP)) return;
        #endif

        // log event if requested
        #if defined _TRACE_EVENT_CHANGED
            enLog_TraceParams(
                "changed",
                [
                    "change"
                ],
                [
                    enInteger_ElemBitfield(change)
                ]
            );
        #endif

        #if defined _HOOK_ENLNX_CHANGED 
            _enLNX_changed(change);
        #endif

        #if defined _HOOK_ENPRIM_CHANGED
            _enPrim_changed(change);
        #endif

		#if defined _HOOK_EN_CHANGED
			en_changed(change);
		#endif

#if defined _EVENT_CHANGED
	}
#endif
