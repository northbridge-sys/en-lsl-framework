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

#if defined EVENT_EN_ON_DAMAGE
	on_damage( integer num )
	{
#endif

        // log event if requested
        #if defined EVENT_EN_ON_DAMAGE && defined TRACE_EVENT_EN_ON_DAMAGE
            enLog_TraceParams( "on_damage", [ "num" ], [
                num
            ] );
        #endif

#if defined EVENT_EN_ON_DAMAGE
        // event unused, so pass to user-defined function only
        en_on_damage( num );
	}
#endif
