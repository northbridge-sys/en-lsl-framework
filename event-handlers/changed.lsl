/*
    changed.lsl
    Event Handler
    Xi LSL Framework
    Revision 0
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

    This snippet replaces the changed event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI_CHANGED
		Xi_changed( integer change )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

	changed( integer change )
	{
        // log event if requested
        #ifdef XI_CHANGED_ENABLE_XILOG_TRACE
            XiLog_TraceParams( "changed", [ "change" ], [ XiInteger_ElemBitfield( change ) ] );
        #endif

        // check if any Xi libraries want to intercept this event
        if ( change & CHANGED_LINK )
        {
			_XiChat_RefreshLinkset();
            #ifdef XILSD_ENABLE_UUID_HEADER
                _XiLSD_CheckUUID();
            #endif
			_XiObject_UpdateUUIDs();
        }

        // pass to user-defined function if requested
		#ifdef XI_ATTACH
			Xi_changed( change );
		#endif
	}
