 /*
    enIMP.lsl
    Library
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

    TBD
*/

// ==
// == globals
// ==

// ==
// == functions
// ==

enIMP$Send( // sends an IMP message
    string prim,        // the TARGET prim, valid values:
                            //  - "" (empty string): send via llMessageLinked(ENIMP$LINK_MESSAGE_SCOPE, ...)
                            //  - (integer cast as string): send via llMessageLinked(...) to linknum or LINK_* constant
                            //  - NULL_KEY: send via enChat to all prims in the region listening to target domain
                            //  - (any other UUID): send via enChat to prim with UUID, as long as it is listening to target domain
    string target,      // one of the following:
                            // - if llMessageLinked is used, the name of the script to target (or custom target)
                            // - if enChat is used, the enChat domain to use (cannot target by script when using enChat)
    string status,      // ":" (broadcast), "" (request), "err:_" (error response), "ok" (generic success), or any other value (success)
    integer ident,      // the integer ident value
    list params,        // the message params
    string data         // the message data
    )
{
    #ifdef ENIMP$TRACE
        enLog$TraceParams("enIMP$Send", ["prim", "target", "status", "ident", "params", "data"], [
            enObject$Elem(prim),
            enString$Elem(target),
            enString$Elem(status),
            ident,
            enList$Elem(params),
            enString$Elem(data)
            ]);
    #endif
    string message = "\n" + llGetScriptName() + "\n" + status + "\n" + llDumpList2String(params, "\n");
    integer enable;
    #ifdef ENIMP$ENABLE_ENCHAT
        enable = 1;
        if (enKey$Is(prim))
        { // enChat via specified URL and domain
            enChat$Send(prim, target, "enIMP", enList$ToString([ident, message, data]));
            return;
        }
    #endif
    #ifdef ENIMP$ENABLE_LINK_MESSAGE
        enable = 1;
        integer linknum = (integer)prim;
        if (prim == "") linknum = ENIMP$LINK_MESSAGE_SCOPE; // blank prim uses default scope
        if (linknum || prim == "0") // either prim is literally "0", or we have found a valid linknum, so send to it
        { // llMessageLinked via specified linknum
            llMessageLinked(linknum, ident, target + message, data); // note that we can add the target to the front of the message in this case
            return;
        }
    #endif
    #ifndef ENIMP$ENABLE_LINK_MESSAGE
        // only add this code if ENIMP$ENABLE_LINK_MESSAGE is not defined (to save memory)
        if (!enable) enLog$(WARN, "ENIMP$ENABLE_* not defined.");
    #endif
}

integer _enIMP$Process(
    string prim,
    integer linknum,
    integer num,
    string message,
    key id
    )
{
    #ifdef ENIMP$TRACE
        enLog$TraceParams("_enIMP$Process", ["prim", "linknum", "num", "message", "id"], [
            enObject$Elem(prim),
            linknum,
            num,
            enString$Elem(message),
            enString$Elem(id)
            ]);
    #endif
    list parts = llParseStringKeepNulls(message, ["\n"], []); // parse Interface Message Protocol
    // target, source, status, params
    if (llGetListLength(parts) < 4) return 0; // invalid message
    if (prim == (string)llGetKey() && llList2String(parts, 1) == llGetScriptName()) return 1; // discard own feedback message
    #ifdef ENIMP$ALLOWED_INBOUND_SOURCES
        // ENIMP$ALLOWED_SOURCES was defined, so use it to filter out messages that don't match the allowed source list
        if (llListFindList(ENIMP$ALLOWED_INBOUND_SOURCES, [llList2String(parts, 1)]) == -1) return 1; // discard message, not sent from an allowed source
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef ENIMP$ALLOWED_INBOUND_TARGETS
        // ENIMP$ALLOWED_TARGETS was defined, so use it as well
        allowed_targets += ENIMP$ALLOWED_INBOUND_TARGETS;
    #endif
    #ifndef ENIMP$ALLOWED_INBOUND_TARGETS_ALL
        // ENIMP$ALLOWED_INBOUND_TARGETS_ALL was not defined (see IMPTap.lsl), so filter out messages that don't match the allowed targets list
        if (llListFindList(allowed_targets, [llList2String(parts, 0)]) == -1) return 0; // discard message, not targeted to us
    #endif
    #ifdef EN$IMP_MESSAGE
        en$imp_message(
            prim, // SOURCE prim
            llList2String(parts, 0), // target
            llList2String(parts, 2), // status
            num, // IMP message ident (link_message integer)
            enList$Empty(llDeleteSubList(parts, 0, 2)), // params
            id, // IMP data (link_message key)
            linknum,
            llList2String(parts, 1) // source
            );
    #endif
    return 1;
}
