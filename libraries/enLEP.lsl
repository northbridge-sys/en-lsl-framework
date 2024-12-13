 /*
    enLEP.lsl
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
// == macros
// ==

#define enLEP$Generate(target_script, parameters) \
    llDumpList2String([llGetScriptName(), target_script] + parameters, "\n")

// ==
// == functions
// ==

enLEP$Send( // sends a LEP message
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #ifdef ENLEP$TRACE
        enLog$TraceParams("enLEP$Send", ["target_link", "target_script", "flags", "paramters", "data"], [
            target_link,
            enString$Elem(target_script),
            enInteger$ElemBitfield(flags),
            enList$Elem(parameters),
            enString$Elem(data)
            ]);
    #endif
    if (!target_link) target_link = ENLEP$LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, enLEP$Generate(target_script, parameters), data);
}

/*enLEP$Send( // sends an LEP message
    string prim,        // the TARGET prim, valid values:
                            //  - "" (empty string): send via llMessageLinked(ENLEP$LINK_MESSAGE_SCOPE, ...)
                            //  - (integer cast as string): send via llMessageLinked(...) to linknum or LINK_* constant
                            //  - NULL_KEY: send via enCLEP to all prims in the region listening to target domain
                            //  - (any other UUID): send via enCLEP to prim with UUID, as long as it is listening to target domain
    string target,      // one of the following:
                            // - if llMessageLinked is used, the name of the script to target (or custom target)
                            // - if enCLEP is used, the enCLEP domain to use (cannot target by script when using enCLEP)
    string status,      // ":" (broadcast), "" (request), "err:_" (error response), "ok" (generic success), or any other value (success)
    integer ident,      // the integer ident value
    list params,        // the message params
    string data         // the message data
    )
{
    #ifdef ENLEP$TRACE
        enLog$TraceParams("enLEP$Send", ["prim", "target", "status", "ident", "params", "data"], [
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
    #ifdef ENLEP$ENABLE_ENCLEP
        enable = 1;
        if (enKey$Is(prim))
        { // enCLEP via specified URL and domain
            enCLEP$Send(prim, target, "enLEP", enList$ToString([ident, message, data]));
            return;
        }
    #endif
    #ifdef ENLEP$ENABLE_LINK_MESSAGE
        enable = 1;
        integer linknum = (integer)prim;
        if (prim == "") linknum = ENLEP$LINK_MESSAGE_SCOPE; // blank prim uses default scope
        if (linknum || prim == "0") // either prim is literally "0", or we have found a valid linknum, so send to it
        { // llMessageLinked via specified linknum
            llMessageLinked(linknum, ident, target + message, data); // note that we can add the target to the front of the message in this case
            return;
        }
    #endif
    #ifndef ENLEP$ENABLE_LINK_MESSAGE
        // only add this code if ENLEP$ENABLE_LINK_MESSAGE is not defined (to save memory)
        if (!enable) enLog$Warn("ENLEP$ENABLE_* not defined.");
    #endif
}*/

integer enLEP$Process(
    integer source_link,
    integer flags,
    string s,
    key k
)
{
    #ifdef ENLEP$TRACE
        enLog$TraceParams("enLEP$Process", ["source_link", "flags", "s", "k"], [
            source_link,
            flags,
            enString$Elem(s),
            enString$Elem(k)
            ]);
    #endif
    list parameters = llParseStringKeepNulls(s, ["\n"], []);
    if (llGetListLength(parameters) < 2) return 0; // not a valid LEP message
    if (source_link == llGetLinkNumber() && llList2String(parameters, 0) == llGetScriptName()) return 1; // discard message loopback even
    #ifdef ENLEP$ALLOWED_SOURCE_SCRIPTS
        // filter out messages that don't match the allowed source script list
        if (llListFindList(ENLEP$ALLOWED_SOURCE_SCRIPTS, [llList2String(parameters, 0)]) == -1) return 1; // discard message, not sent from an allowed source script
    #endif
    #ifdef ENLEP$ALLOWED_TARGET_SCRIPTS
        // filter out messages that don't match the allowed target script list
        if (llListFindList(["", llGetScriptName()] + ENLEP$ALLOWED_TARGET_SCRIPTS, [llList2String(parameters, 1)]) == -1) return 1; // discard message, not sent to an allowed target script
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef ENLEP$ALLOWED_TARGET_SCRIPTS
        allowed_targets += ENLEP$ALLOWED_TARGET_SCRIPTS;
    #endif
    #ifndef ENLEP$ALLOW_ALL_TARGET_SCRIPTS
        if (llListFindList(allowed_targets, [llList2String(parameters, 1)]) == -1) return 0; // discard message, not targeted to us
    #endif
    #ifdef EN$LEP_MESSAGE
        en$lep_message(
            source_link,
            source_script,
            target_script,
            flags,
            llDeleteSubList(parameters, 0, 1),
            (string)k
            );
    #endif
    return 1;
}

/*integer _enLEP$Process(
    string prim,
    integer linknum,
    integer num,
    string message,
    key id
    )
{
    #ifdef ENLEP$TRACE
        enLog$TraceParams("_enLEP$Process", ["prim", "linknum", "num", "message", "id"], [
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
    #ifdef ENLEP$ALLOWED_INBOUND_SOURCES
        // ENLEP$ALLOWED_SOURCES was defined, so use it to filter out messages that don't match the allowed source list
        if (llListFindList(ENLEP$ALLOWED_INBOUND_SOURCES, [llList2String(parts, 1)]) == -1) return 1; // discard message, not sent from an allowed source
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef ENLEP$ALLOWED_INBOUND_TARGETS
        // ENLEP$ALLOWED_TARGETS was defined, so use it as well
        allowed_targets += ENLEP$ALLOWED_INBOUND_TARGETS;
    #endif
    #ifndef ENLEP$ALLOWED_INBOUND_TARGETS_ALL
        // ENLEP$ALLOWED_INBOUND_TARGETS_ALL was not defined (see LEPTap.lsl), so filter out messages that don't match the allowed targets list
        if (llListFindList(allowed_targets, [llList2String(parts, 0)]) == -1) return 0; // discard message, not targeted to us
    #endif
    #ifdef EN$LEP_MESSAGE
        en$lep_message(
            prim, // SOURCE prim
            llList2String(parts, 0), // target
            llList2String(parts, 2), // status
            num, // LEP message ident (link_message integer)
            enList$Empty(llDeleteSubList(parts, 0, 2)), // params
            id, // LEP data (link_message key)
            linknum,
            llList2String(parts, 1) // source
            );
    #endif
    return 1;
}*/
