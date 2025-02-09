/*
    link_message.lsl
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

    This snippet replaces the link_message event handler with a version that calls
    maintenance functions required by En libraries, then optionally executes a user-
    defined function to handle event calls that are not intercepted by En libraries:

		#define EN_LINK_MESSAGE
		en_link_message( integer l, integer i, string s, string k )
		{ // NOTE: the key k is passed as a string, or can be passed as a key
            // code to run when event occurs that is not intercepted by En
		}



    OLD INSTRUCTIONS:

    This snippet replaces the link_message event definition with a verion that
    filters for Interface Message Protocol messages.  Valid LEP messages will be
    passed to a user-defined imp_message(...) function.

    Valid LEP messages are defined, by default, as the following link message:
        integer: ident, should be returned with response, if any
        string: newline-separated message
            The message value is defined as a list with the following elements:
                - target: one of the following:
                    - "" (empty string): broadcast targeted at all scripts
                    - (script name): message targeted at a specific script
                    - (any other value): message targeted at any script with this
                                         value in its EN_LEP_WHITELIST list
                - source: script name of source script
                - status: one of the following:
                    - "" (empty string): the script requests a response
                    - ":": the script does not request a response (broadcast)
                    - "err:_": failure response to "" request;
                               _ can be any short descriptive string identifying the
                               error without "\n" (e.g. "err:out of memory")
                    - (any other value): successful response to "" request
                                         ("ok" is the suggested generic response,
                                         but any value other than ":" or anything
                                         starting with "err:" indicates success)
                - params: zero or more command/parameter strings
        key: newline-separated data
            The data value can be any data and is defined by the interface's
            specification.  However, in general, responses over LEP should append
            any response data as a new line (or new lines) at the end of the data
            value that was received in the request.

    Valid messages will call the user-defined en_imp_message function:
		en_imp_message(
            string prim,        // the SOURCE prim UUID
            string target,  	// one of the following:
                                    //  - (the target script name): this script name
                                    //  - "": all scripts in the prim
                                    //  - (any other value): scripts with this value
                                    //      set in ENLEP_ALLOWED_TARGETS list
			string status,      // one of the following:
                                    // - ":": broadcast (no response requested)
                                    // - "": request
                                    // - "ok": generic success response
                                    // - "err:_": error response
                                    //      _ is defined as any string describing
                                    //      the nature of the error (no newlines!)
                                    // - (any other value): specific success response
			integer ident,      // LEP message ident (link_message integer)
			list params,        // list of parameter strings
			string data,        // LEP data (link_message key)
			integer linknum,    // linknum of prim that sent enLEP(...)
                                //      (-1 if received via enCLEP)
            string source       // the source script name
                                //      (can be pre-filtered by defining
                                //      ENLEP_ALLOWED_SOURCES list)
			)
    Define this function directly in the script to process LEP messages.
*/

#if defined EN_LINK_MESSAGE_TRACE || defined EN_LINK_MESSAGE || defined ENLEP_MESSAGE
    link_message( integer l, integer i, string s, key k )
    {
#endif

        // log event if requested
        #ifdef EN_LINK_MESSAGE_TRACE
            enLog_TraceParams( "link_message", [ "l", "i", "s", "k" ], [ l, i, enString_Elem( s ), enString_Elem( k ) ] );
        #endif

        #ifdef ENLEP_MESSAGE
            if ( enLEP_Process(l, i, s, k)) return; // valid LEP message
        #endif

        // pass to user-defined function if requested
		#ifdef EN_LINK_MESSAGE
			en_link_message( l, i, s, k );
		#endif

#if defined EN_LINK_MESSAGE_TRACE || defined EN_LINK_MESSAGE || defined ENLEP_MESSAGE
	}
#endif
