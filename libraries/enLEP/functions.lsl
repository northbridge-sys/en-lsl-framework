/*
enLEP.lsl
Library Functions
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
*/

/*
sends a LEP request, returning an enLEP token that will be also sent with enlep_response
*/
string enLEP_SendRequest(
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined TRACE_ENLEP
        enLog_TraceParams("enLEP_SendRequest", ["target_link", "target_script", "flags", "paramters", "data"], [
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    flags = (flags | ENLEP_TYPE_REQUEST) & ~ENLEP_TYPE_RESPONSE; // add ENLEP_TYPE_REQUEST flag, remove ENLEP_TYPE_RESPONSE if it was provided
    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    string token = (string)llGenerateKey();
    llMessageLinked(target_link, flags, _enLEP_Generate(target_script, parameters, token), data);
    return token;
}

/*
responds to a LEP request
*/
enLEP_SendResponse(
    string token,
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined TRACE_ENLEP
        enLog_TraceParams("enLEP_SendResponse", ["token", "target_link", "target_script", "flags", "paramters", "data"], [
            enString_Elem(token),
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    flags = (flags | ENLEP_TYPE_RESPONSE) & ~ENLEP_TYPE_REQUEST; // add ENLEP_TYPE_RESPONSE flag, remove ENLEP_TYPE_REQUEST
    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, _enLEP_Generate(target_script, parameters, token), data);
}

/*
sends a generic LEP message
*/
enLEP_Send(
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined TRACE_ENLEP
        enLog_TraceParams("enLEP_Send", ["target_link", "target_script", "flags", "paramters", "data"], [
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    // we don't need to send a token with this
    llMessageLinked(target_link, flags, _enLEP_Generate(target_script, parameters, ""), data);
}

//  sends a LEP message as a specific source_script name
enLEP_SendAs(
    string source_script,
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined TRACE_ENLEP
        enLog_TraceParams("enLEP_SendAs", ["source_script", "target_link", "target_script", "flags", "paramters", "data"], [
            enString_Elem(source_script),
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, llDumpList2String([source_script, target_script] + parameters, "\n"), data);
}

integer enLEP_Process(
    integer source_link,
    integer flags,
    string s,
    string k
)
{
    #if defined TRACE_ENLEP || defined TRACE_ENLEP_PROCESS
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
    #if defined OVERRIDE_ENLEP_ALLOWED_SOURCE_SCRIPTS
        // filter out messages that don't match the allowed source script list
        if (llListFindList(OVERRIDE_ENLEP_ALLOWED_SOURCE_SCRIPTS, [llList2String(parameters, 0)]) == -1) return 1; // discard message, not sent from an allowed source script
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #if defined OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS
        allowed_targets += OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS; // allow messages targeted to any value in the macro OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS
    #endif
    #if defined FEATURE_ENLEP_ALLOW_ALL_TARGET_SCRIPTS
        allowed_targets += [llList2String(parameters, 1)]; // always match - this is less efficient, but this flag is only used for debugging anyway
    #endif
    if (llListFindList(allowed_targets, [llList2String(parameters, 1)]) == -1)
    {
        #if defined FEATURE_ENLEP_ALLOW_FUZZY_TARGET_SCRIPT
            // using substring matching due to FEATURE_ENLEP_ALLOW_FUZZY_TARGET_SCRIPT
            if (llSubStringIndex(llGetScriptName(), llList2String(parameters, 1)) == -1) return 0; // discard message, not targeted to us
        #else
            // using exact matching
            return 0; // discard messages, not targeted to us
        #endif
    }
    string token = llList2String(parameters, -1);

    if (token == "")
    { // not using LEP token
        #if defined EVENT_ENLEP_MESSAGE && defined TRACE_ENLEP_MESSAGE
            enLog_TraceParams("enlep_message", ["source_link", "source_script", "target_script", "flags", "parameters", "data"], [
                source_link,
                enString_Elem(llList2String(parameters, 0)),
                enString_Elem(llList2String(parameters, 1)),
                enInteger_ElemBitfield(flags),
                enList_Elem(llDeleteSubList(llDeleteSubList(parameters, 0, 1), -1, -1)),
                enString_Elem(k)
            ]);
        #endif
        #if defined EVENT_ENLEP_MESSAGE
            enlep_message(
                source_link,
                llList2String(parameters, 0),
                llList2String(parameters, 1),
                flags,
                llDeleteSubList(parameters, 0, 1),
                k
            );
        #endif
    }

    // using LEP token
    #if defined EVENT_ENLEP_REQUEST
        if (flags & ENLEP_TYPE_REQUEST)
        {
            enlep_request(
                token,
                source_link,
                llList2String(parameters, 0),
                llList2String(parameters, 1),
                flags,
                llDeleteSubList(parameters, 0, 1),
                k
            );
        }
    #endif

    #if defined EVENT_ENLEP_RESPONSE
        if (flags & ENLEP_TYPE_RESPONSE)
        {
            enlep_response(
                token,
                source_link,
                llList2String(parameters, 0),
                llList2String(parameters, 1),
                flags,
                llDeleteSubList(parameters, 0, 1),
                k
            );
        }
    #endif

    return 1;
}
