/*
    LEPTap.lsl
    Utility Script
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

    This is a full script that reports all LEP messages sent via link message in the
    prim. These will be reported via "imp_message" event reports through
    enLog_TraceParams.

    Loglevel must be 6 (TRACE); otherwise, these messages will be surpressed.  You
    can either set the loglevel to 6 as follows to permanently enable output:
        #define ENLOG_DEFAULT_LOGLEVEL 6
    or you can set the "loglevel" linkset data pair to the desired loglevel as
    needed, so that inbound messages will only be reported when TRACE logging is
    enabled.  The utils/Loglevel.lsl script allows you to change the loglevel by
    renaming the script itself, which is useful for fast debugging, but the value
    can be set by any script.
*/

#define ENLEP_ALLOWED_INBOUND_TARGETS_ALL

#include "en-lsl-framework/main.lsl"

en_imp_message(
    string prim,        // the SOURCE prim UUID
    string target,      // one of the following:
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
{
    enLog_TraceParams("en_imp_message", ["prim", "target", "status", "ident", "params", "data", "linknum", "source"], [
        enObject_Elem(prim),
        enString_Elem(target),
        enString_Elem(status),
        ident,
        enList_Elem(params),
        enString_Elem(data),
        linknum,
        enString_Elem(source)
        ]);
}

default
{
    #include "en-LSL-Framework/Event-Handlers/link_message.lsl"
}
