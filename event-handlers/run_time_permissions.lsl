/*
    run_time_permissions.lsl
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

    This snippet replaces the run_time_permissions event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$RUN_TIME_PERMISSIONS
		Xi$run_time_permissions( integer perm )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#ifdef XI$RUN_TIME_PERMISSIONS
	run_time_permissions( integer perm )
	{
        // event unused, so the only reason to define it is to log it
        XiLog$TraceParams( "run_time_permissions", [ "perm" ], [
            XiInteger$ElemBitwise( perm )
        ] );

        // event unused, so pass to user-defined function only
        Xi$run_time_permissions( perm );
	}
#endif
