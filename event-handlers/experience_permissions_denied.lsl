/*
    experience_permissions_denied.lsl
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

    This snippet replaces the experience_permissions_denied event handler with a
    version that calls maintenance functions required by En libraries, then
    optionally executes a user-defined function to handle event calls that are not
    intercepted by En libraries:

		#define EN_EXPERIENCE_PERMISSIONS_DENIED
		en_experience_permissions_denied( key id, integer reason )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_EXPERIENCE_PERMISSIONS_DENIED
	experience_permissions_denied( key id, integer reason )
	{
#endif

        // log event if requested
        #if defined EN_EXPERIENCE_PERMISSIONS_DENIED && defined EN_EXPERIENCE_PERMISSIONS_DENIED_TRACE
            enLog_TraceParams( "experience_permissions_denied", [ "id", "reason" ], [
                enAvatar_Elem( id ),
                reason
            ] );
        #endif

#if defined EN_EXPERIENCE_PERMISSIONS_DENIED
        // event unused, so pass to user-defined function only
        en_experience_permissions_denied( id, reason );
	}
#endif
