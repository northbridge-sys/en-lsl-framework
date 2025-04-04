/*
    land_collision_end.lsl
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

    This snippet replaces the land_collision_end event handler with a version that
    calls maintenance functions required by En libraries, then optionally executes a
    user-defined function to handle event calls that are not intercepted by En
    libraries:

		#define EN_LAND_COLLISION_END
		en_land_collision_end( vector pos )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_LAND_COLLISION_END
	land_collision_end( vector pos )
	{
#endif

        // log event if requested
        #if defined EN_LAND_COLLISION_END && defined EN_LAND_COLLISION_END_TRACE
            enLog_TraceParams( "land_collision_end", [ "pos" ], [
                pos
            ] );
        #endif

#if defined EN_LAND_COLLISION_END
        // event unused, so pass to user-defined function only
        en_land_collision_end( pos );
	}
#endif
