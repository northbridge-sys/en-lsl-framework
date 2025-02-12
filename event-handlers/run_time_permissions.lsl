/*
    run_time_permissions.lsl
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

    This snippet replaces the run_time_permissions event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_RUN_TIME_PERMISSIONS
		en_run_time_permissions( integer perm )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_RUN_TIME_PERMISSIONS
	run_time_permissions( integer perm )
	{
#endif

        // log event if requested
        #if defined EN_RUN_TIME_PERMISSIONS && defined EN_RUN_TIME_PERMISSIONS_TRACE
            enLog_TraceParams( "run_time_permissions", [ "perm" ], [
                enInteger_ElemBitfield( perm )
            ] );
        #endif

#if defined EN_RUN_TIME_PERMISSIONS
        // event unused, so pass to user-defined function only
        en_run_time_permissions( perm );
	}
#endif
