/*
    IMPTap.lsl
    Utility Script
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

    This is a full script that reports all IMP messages sent via link message in the
    prim. These will be reported via "imp_message" event reports through
    XiLog$TraceParams.

    Loglevel must be 6 (TRACE); otherwise, these messages will be surpressed.  You
    can either set the loglevel to 6 as follows to permanently enable output:
        #define XILOG$DEFAULT_LOGLEVEL 6
    or you can set the "loglevel" linkset data pair to the desired loglevel as
    needed, so that inbound messages will only be reported when TRACE logging is
    enabled.  The utils/Loglevel.lsl script allows you to change the loglevel by
    renaming the script itself, which is useful for fast debugging, but the value
    can be set by any script.
*/

#define XIIMP$ALLOWED_INBOUND_TARGETS_ALL

#include "xi-lsl-framework/main.lsl"

Xi$imp_message(
    string prim,        // the SOURCE prim UUID
    string target,      // one of the following:
                            //  - (the target script name): this script name
                            //  - "": all scripts in the prim
                            //  - (any other value): scripts with this value
                            //      set in XIIMP$ALLOWED_TARGETS list
    string status,      // one of the following:
                            // - ":": broadcast (no response requested)
                            // - "": request
                            // - "ok": generic success response
                            // - "err:_": error response
                            //      _ is defined as any string describing
                            //      the nature of the error (no newlines!)
                            // - (any other value): specific success response
    integer ident,      // IMP message ident (link_message integer)
    list params,        // list of parameter strings
    string data,        // IMP data (link_message key)
    integer linknum,    // linknum of prim that sent XiIMP(...)
                        //      (-1 if received via XiChat)
    string source       // the source script name
                        //      (can be pre-filtered by defining
                        //      XIIMP$ALLOWED_SOURCES list)
    )
{
    XiLog$TraceParams("Xi$imp_message", ["prim", "target", "status", "ident", "params", "data", "linknum", "source"], [
        XiObject$Elem(prim),
        XiString$Elem(target),
        XiString$Elem(status),
        ident,
        XiList$Elem(params),
        XiString$Elem(data),
        linknum,
        XiString$Elem(source)
        ]);
}

default
{
    #include "Xi-LSL-Framework/Event-Handlers/link_message.lsl"
}
