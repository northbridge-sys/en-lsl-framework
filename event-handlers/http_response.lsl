/*
    http_response.lsl
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

    This snippet replaces the http_response event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN$HTTP_RESPONSE
		en$http_response( key request, integer status, list metadata, string body )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#if defined EN$HTTP_RESPONSE_TRACE || defined EN$HTTP_RESPONSE
	http_response( key request, integer status, list metadata, string body )
	{
#endif

        // log event if requested
        #ifdef EN$HTTP_RESPONSE_TRACE
            enLog$TraceParams( "http_response", [ "request", "status", "metadata", "body" ], [
                enString$Elem( request ),
                status,
                enList$Elem( metadata ),
                enString$Elem( body )
            ] );
        #endif

        // pass to user-defined function if requested
		#ifdef EN$HTTP_RESPONSE
            en$http_response( request, status, metadata, body );
		#endif

#if defined EN$HTTP_RESPONSE_TRACE || defined EN$HTTP_RESPONSE
	}
#endif
