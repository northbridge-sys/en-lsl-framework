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

#define enLEP_Generate(target_script, parameters) \
    llDumpList2String([llGetScriptName(), target_script] + parameters, "\n")

// ==
// == functions
// ==

enLEP_Send( // sends a LEP message
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #ifdef ENLEP_TRACE
        enLog_TraceParams("enLEP_Send", ["target_link", "target_script", "flags", "paramters", "data"], [
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, enLEP_Generate(target_script, parameters), data);
}

enLEP_SendAs( // sends a LEP message as a specific source_script name
    string source_script,
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #ifdef ENLEP_TRACE
        enLog_TraceParams("enLEP_SendAs", ["source_script", "target_link", "target_script", "flags", "paramters", "data"], [
            enString_Elem(source_script),
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, llDumpList2String([source_script, target_script] + parameters, "\n"), data);
}

/*enLEP_Send( // sends an LEP message
    string prim,        // the TARGET prim, valid values:
                            //  - "" (empty string): send via llMessageLinked(ENLEP_LINK_MESSAGE_SCOPE, ...)
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
    #ifdef ENLEP_TRACE
        enLog_TraceParams("enLEP_Send", ["prim", "target", "status", "ident", "params", "data"], [
            enObject_Elem(prim),
            enString_Elem(target),
            enString_Elem(status),
            ident,
            enList_Elem(params),
            enString_Elem(data)
            ]);
    #endif
    string message = "\n" + llGetScriptName() + "\n" + status + "\n" + llDumpList2String(params, "\n");
    integer enable;
    #ifdef ENLEP_ENABLE_ENCLEP
        enable = 1;
        if (enKey_Is(prim))
        { // enCLEP via specified URL and domain
            enCLEP_Send(prim, target, "enLEP", enList_ToString([ident, message, data]));
            return;
        }
    #endif
    #ifdef ENLEP_ENABLE_LINK_MESSAGE
        enable = 1;
        integer linknum = (integer)prim;
        if (prim == "") linknum = ENLEP_LINK_MESSAGE_SCOPE; // blank prim uses default scope
        if (linknum || prim == "0") // either prim is literally "0", or we have found a valid linknum, so send to it
        { // llMessageLinked via specified linknum
            llMessageLinked(linknum, ident, target + message, data); // note that we can add the target to the front of the message in this case
            return;
        }
    #endif
    #ifndef ENLEP_ENABLE_LINK_MESSAGE
        // only add this code if ENLEP_ENABLE_LINK_MESSAGE is not defined (to save memory)
        if (!enable) enLog_Warn("ENLEP_ENABLE_* not defined.");
    #endif
}*/

integer enLEP_Process(
    integer source_link,
    integer flags,
    string s,
    string k
)
{
    #ifdef ENLEP_TRACE
        enLog_TraceParams("enLEP_Process", ["source_link", "flags", "s", "k"], [
            source_link,
            flags,
            enString_Elem(s),
            enString_Elem(k)
            ]);
    #endif
    list parameters = llParseStringKeepNulls(s, ["\n"], []);
    if (llGetListLength(parameters) < 2) return 0; // not a valid LEP message
    if (source_link == llGetLinkNumber() && llList2String(parameters, 0) == llGetScriptName()) return 1; // discard message loopback even
    #ifdef ENLEP_ALLOWED_SOURCE_SCRIPTS
        // filter out messages that don't match the allowed source script list
        if (llListFindList(ENLEP_ALLOWED_SOURCE_SCRIPTS, [llList2String(parameters, 0)]) == -1) return 1; // discard message, not sent from an allowed source script
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef ENLEP_ALLOWED_TARGET_SCRIPTS
        allowed_targets += ENLEP_ALLOWED_TARGET_SCRIPTS; // allow messages targeted to any value in the macro ENLEP_ALLOWED_TARGET_SCRIPTS
    #endif
    #ifndef ENLEP_ALLOW_ALL_TARGET_SCRIPTS
        if (llListFindList(allowed_targets, [llList2String(parameters, 1)]) == -1) return 0; // discard message, not targeted to us
    #endif
    #if defined EN_LEP_MESSAGE && defined EN_LEP_MESSAGE_TRACE
        enLog_TraceParams("en_lep_message", ["source_link", "source_script", "target_script", "flags", "parameters", "data"], [
            source_link,
            enString_Elem(llList2String(parameters, 0)),
            enString_Elem(llList2String(parameters, 1)),
            enInteger_ElemBitfield(flags),
            enList_Elem(llDeleteSubList(parameters, 0, 1)),
            enString_Elem(k)
        ]);
    #endif
    #ifdef EN_LEP_MESSAGE
        en_lep_message(
            source_link,
            llList2String(parameters, 0),
            llList2String(parameters, 1),
            flags,
            llDeleteSubList(parameters, 0, 1),
            k
            );
    #endif
    return 1;
}

/*integer enLEP_Process(
    string prim,
    integer linknum,
    integer num,
    string message,
    key id
    )
{
    #ifdef ENLEP_TRACE
        enLog_TraceParams("enLEP_Process", ["prim", "linknum", "num", "message", "id"], [
            enObject_Elem(prim),
            linknum,
            num,
            enString_Elem(message),
            enString_Elem(id)
            ]);
    #endif
    list parts = llParseStringKeepNulls(message, ["\n"], []); // parse Interface Message Protocol
    // target, source, status, params
    if (llGetListLength(parts) < 4) return 0; // invalid message
    if (prim == (string)llGetKey() && llList2String(parts, 1) == llGetScriptName()) return 1; // discard own feedback message
    #ifdef ENLEP_ALLOWED_INBOUND_SOURCES
        // ENLEP_ALLOWED_SOURCES was defined, so use it to filter out messages that don't match the allowed source list
        if (llListFindList(ENLEP_ALLOWED_INBOUND_SOURCES, [llList2String(parts, 1)]) == -1) return 1; // discard message, not sent from an allowed source
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #ifdef ENLEP_ALLOWED_INBOUND_TARGETS
        // ENLEP_ALLOWED_TARGETS was defined, so use it as well
        allowed_targets += ENLEP_ALLOWED_INBOUND_TARGETS;
    #endif
    #ifndef ENLEP_ALLOWED_INBOUND_TARGETS_ALL
        // ENLEP_ALLOWED_INBOUND_TARGETS_ALL was not defined (see LEPTap.lsl), so filter out messages that don't match the allowed targets list
        if (llListFindList(allowed_targets, [llList2String(parts, 0)]) == -1) return 0; // discard message, not targeted to us
    #endif
    #ifdef EN_LEP_MESSAGE
        en_lep_message(
            prim, // SOURCE prim
            llList2String(parts, 0), // target
            llList2String(parts, 2), // status
            num, // LEP message ident (link_message integer)
            enList_Empty(llDeleteSubList(parts, 0, 2)), // params
            id, // LEP data (link_message key)
            linknum,
            llList2String(parts, 1) // source
            );
    #endif
    return 1;
}*/
