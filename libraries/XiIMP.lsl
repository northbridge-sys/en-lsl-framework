 /*
    XiIMP.lsl
    Library
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

    TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XIIMP_ENABLE_XILOG_TRACE
#endif

#ifndef XIIMP_LINK_MESSAGE_SCOPE
#define XIIMP_LINK_MESSAGE_SCOPE LINK_THIS
#endif

// ==
// == functions
// ==

XiIMP_Send( // sends an IMP message
    string prim,        // the TARGET prim, valid values:
                            //  - "" (empty string): send via llMessageLinked(XIIMP_LINK_MESSAGE_SCOPE, ...)
                            //  - (integer cast as string): send via llMessageLinked(...) to linknum or LINK_* constant
                            //  - NULL_KEY: send via XiChat to all prims in the region listening to target domain
                            //  - (any other UUID): send via XiChat to prim with UUID, as long as it is listening to target domain
    string target,      // one of the following:
                            // - if llMessageLinked is used, the name of the script to target (or custom target)
                            // - if XiChat is used, the XiChat domain to use (cannot target by script when using XiChat)
    string status,      // ":" (broadcast), "" (request), "err:_" (error response), "ok" (generic success), or any other value (success)
    integer ident,      // the integer ident value
    list params,        // the message params
    string data         // the message data
    )
{
    #ifdef XIIMP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiIMP_Send", ["prim", "target", "status", "ident", "params", "data"], [
            XiObject_Elem(prim),
            XiString_Elem(target),
            XiString_Elem(status),
            ident,
            XiList_Elem(params),
            XiString_Elem(data)
            ]);
    #endif
    string message = "\n" + llGetScriptName() + "\n" + status + "\n" + llDumpList2String(params, "\n");
    integer enable;
    #ifdef XIIMP_ENABLE_XICHAT
        enable = 1;
        if (XiKey_Is(prim))
        { // XiChat via specified URL and domain
            XiChat_Send(prim, target, "XiIMP", XiList_ToString([ident, message, data]));
            return;
        }
    #endif
    #ifdef XIIMP_ENABLE_LINK_MESSAGE
        enable = 1;
        integer linknum = (integer)prim;
        if (prim == "") linknum = XIIMP_LINK_MESSAGE_SCOPE; // blank prim uses default scope
        if (linknum || prim == "0") // either prim is literally "0", or we have found a valid linknum, so send to it
        { // llMessageLinked via specified linknum
            llMessageLinked(linknum, ident, target + message, data); // note that we can add the target to the front of the message in this case
            return;
        }
    #endif
    #ifndef XIIMP_ENABLE_LINK_MESSAGE
        // only add this code if XIIMP_ENABLE_LINK_MESSAGE is not defined (to save memory)
        if (!enable) XiLog(WARN, "XIIMP_ENABLE_* not defined.");
    #endif
}

integer _XiIMP_Process(
    string prim,
    integer linknum,
    integer num,
    string message,
    key id
    )
{
    #ifdef XIIMP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiIMP_Process", ["prim", "linknum", "num", "message", "id"], [
            XiObject_Elem(prim),
            linknum,
            num,
            XiString_Elem(message),
            XiString_Elem(id)
            ]);
    #endif
    list parts = llParseStringKeepNulls(message, ["\n"], []); // parse Interface Message Protocol
    // target, source, status, params
    if (llGetListLength(parts) < 4) return 0; // invalid message
    if (prim == (string)llGetKey() && llList2String(parts, 1) == llGetScriptName()) return 1; // discard own feedback message
    #ifdef XIIMP_ALLOWED_INBOUND_SOURCES
        // XIIMP_ALLOWED_SOURCES was defined, so use it to filter out messages that don't match the allowed source list
        if (llListFindList(XIIMP_ALLOWED_INBOUND_SOURCES, [llList2String(parts, 1)]) == -1) return 1; // discard message, not sent from an allowed source
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef XIIMP_ALLOWED_INBOUND_TARGETS
        // XIIMP_ALLOWED_TARGETS was defined, so use it as well
        allowed_targets += XIIMP_ALLOWED_INBOUND_TARGETS;
    #endif
    #ifndef XIIMP_ALLOWED_INBOUND_TARGETS_ALL
        // XIIMP_ALLOWED_INBOUND_TARGETS_ALL was not defined (see IMPTap.lsl), so filter out messages that don't match the allowed targets list
        if (llListFindList(allowed_targets, [llList2String(parts, 0)]) == -1) return 0; // discard message, not targeted to us
    #endif
    Xi_imp_message(
        prim, // SOURCE prim
        llList2String(parts, 0), // target
        llList2String(parts, 2), // status
        num, // IMP message ident (link_message integer)
        XiList_Empty(llDeleteSubList(parts, 0, 2)), // params
        id, // IMP data (link_message key)
        linknum,
        llList2String(parts, 1) // source
        );
    return 1;
}
