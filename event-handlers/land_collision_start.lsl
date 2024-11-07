/*
    land_collision_start.lsl
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

    This snippet replaces the land_collision_start event handler with a version that
    calls maintenance functions required by Xi libraries, then optionally executes a
    user-defined function to handle event calls that are not intercepted by Xi
    libraries:

		#define XI_LAND_COLLISION_START
		Xi$land_collision_start( vector pos )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#ifdef XI_LAND_COLLISION_START
	land_collision_start( vector pos )
	{
        // event unused, so the only reason to define it is to log it
        XiLog$TraceParams( "land_collision_start", [ "pos" ], [
            pos
        ] );

        // event unused, so pass to user-defined function only
        Xi$land_collision_start( pos );
	}
#endif
