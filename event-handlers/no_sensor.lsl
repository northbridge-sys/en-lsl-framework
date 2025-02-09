/*
    no_sensor.lsl
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

    This snippet replaces the no_sensor event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_NO_SENSOR
		en_no_sensor( key id, integer level, integer edge )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN_NO_SENSOR
	no_sensor()
	{
#endif

        // log event if requested
        #if defined EN_NO_SENSOR && defined EN_NO_SENSOR_TRACE
            enLog_TraceParams( "no_sensor", [], [] );
        #endif

#if defined EN_NO_SENSOR
        // event unused, so pass to user-defined function only
        en_no_sensor();
	}
#endif
