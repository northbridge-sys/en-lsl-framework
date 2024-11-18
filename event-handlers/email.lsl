/*
    email.lsl
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

    This snippet replaces the email event handler with a version that calls
    maintenance functions required by Xi libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by Xi libraries:

		#define XI$EMAIL
		Xi$email( string time, string address, string subject, string message,
            integer remaining )
		{
            // code to run when event occurs that is not intercepted by Xi
		}
*/

#ifdef XI$EMAIL
	email( string time, string address, string subject, string message, integer remaining )
	{
        // event unused, so the only reason to define it is to log it
        XiLog$TraceParams( "email", [ "time", "address", "subject", "message", "remaining" ], [
            XiString$Elem( time ),
            XiString$Elem( address ),
            XiString$Elem( subject ),
            XiString$Elem( message ),
            remaining
        ] );

        // event unused, so pass to user-defined function only
        Xi$email( time, address, subject, message, remaining );
	}
#endif
