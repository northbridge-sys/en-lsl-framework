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

#if defined EVENT_EN_AT_TARGET
	at_target( integer handle, vector target, vector current )
	{
#endif

        // log event if requested
        #if defined TRACE_EVENT_EN_AT_TARGET && defined EVENT_EN_AT_TARGET
            enLog_TraceParams( "at_target", [ "handle", "target", "current" ], [
                handle,
                target
                current
            ] );
        #endif

        // event unused, so pass to user-defined function only
        #if defined EVENT_EN_AT_TARGET
            en_at_target( handle, target, current );
	}
#endif
