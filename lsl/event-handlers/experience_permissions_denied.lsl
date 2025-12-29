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

#if defined EVENT_EN_EXPERIENCE_PERMISSIONS_DENIED
	experience_permissions_denied( key id, integer reason )
	{
#endif

        // log event if requested
        #if defined EVENT_EN_EXPERIENCE_PERMISSIONS_DENIED && defined TRACE_EVENT_EN_EXPERIENCE_PERMISSIONS_DENIED
            enLog_TraceParams( "experience_permissions_denied", [ "id", "reason" ], [
                enAvatar_Elem( id ),
                reason
            ] );
        #endif

#if defined EVENT_EN_EXPERIENCE_PERMISSIONS_DENIED
        // event unused, so pass to user-defined function only
        en_experience_permissions_denied( id, reason );
	}
#endif
