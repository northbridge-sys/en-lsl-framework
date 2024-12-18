/*
    transaction_result.lsl
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

    This snippet replaces the transaction_result event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_TRANSACTION_RESULT
		en_transaction_result( key id, integer success, string data )
		{
            // code to run when event occurs that is not intercepted by En
		}
*/

#ifdef EN_TRANSACTION_RESULT
	transaction_result( key transaction, integer success, string data )
	{
        // event unused, so the only reason to define it is to log it
        enLog_TraceParams( "transaction_result", [ "transaction", "success", "data" ], [
            enString_Elem( transaction ),
            success,
            enString_Elem( data )
        ] );

        // event unused, so pass to user-defined function only
        en_transaction_result( transaction, success, data );
	}
#endif
