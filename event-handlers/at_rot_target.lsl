/*
    at_rot_target.lsl
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

    This snippet replaces the at_rot_target event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$AT_ROT_TARGET
		Xi$at_rot_target( integer handle, rotation target, rotation current )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#if defined XI$AT_ROT_TARGET_TRACE || defined XI$AT_ROT_TARGET
	at_rot_target( integer handle, rotation target, rotation current )
	{
#endif

        // log event if requested
        #ifdef XI$AT_ROT_TARGET_TRACE
            XiLog$TraceParams( "at_rot_target", [ "handle", "target", "current" ], [
                handle,
                XiRotation$Elem( target ),
                XiRotation$Elem( current )
            ] );
        #endif

        // event unused, so pass to user-defined function only
        #ifdef XI$AT_ROT_TARGET
            Xi$at_rot_target( handle, target, current );
        #endif

#if defined XI$AT_ROT_TARGET_TRACE || defined XI$AT_ROT_TARGET
	}
#endif
