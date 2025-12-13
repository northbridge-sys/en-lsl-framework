/*
enLEP.lsl
Library Functions
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
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

integer _enLEP_Message_As(
    integer flags,
    integer target_link,
    string source_script,
    string target_script,
    string token,
    string json,
    string data
)
{
    #if defined TRACE_ENLEP_MESSAGE
        enLog_TraceParams("_enLEP_Message_As", ["flags", "target_link", "source_script", "target_script", "token", "json", "data"], [
            enInteger_ElemBitfield(flags),
            target_link,
            enString_Elem(source_script),
            enString_Elem(target_script),
            enString_Elem(token),
            enString_Elem(json),
            enString_Elem(data)
        ]);
    #endif

    /*
    llJsonValueType check should only be run if FEATURE_ENLEP_SKIP_JSON_VALIDATION is NOT defined
    this can be defined to skip the check to save a few bytes of memory when enLEP functions won't be called with unsafe JSON (always hard-coded)
    NOTE: JSON object is mandatory for LEP spec compliance, so do not disable this to use non-JSON messages unless you are OK with non-compliance!
    */
    #if !defined FEATURE_ENLEP_SKIP_JSON_VALIDATION
        if (llJsonValueType(json) != JSON_OBJECT)
        {
            enLog_Error("_enLEP_Message_As JSON error: " + json);
            return;
        }
    #endif

    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;

    llMessageLinked(target_link, flags, _enLEP_Generate_As(source_script, target_script, token, json), data);
}

/*!
Processes link_message events if EVENT_ENLEP_* is defined.
@param integer 
*/
integer _enLEP_link_message(
    integer l,
    integer i,
    string s,
    string k
)
{
    #if TRACE_ENLEP_LINK_MESSAGE
        enLog_TraceParams("_enLEP_link_message", [
            "l",
            "i",
            "s",
            "k"
        ], [
            l,
            i,
            enString_Elem(s),
            enString_Elem(k)
        ]);
    #endif

    // extract source_script
    integer n = llSubStringIndex(s, "\n");
    if (n == -1) return __LINE__; // not a valid LEP message
    string source_script = llDeleteSubString(s, n, -1);

    // extract target_script
    n = llSubStringIndex(s, "\n");
    if (n == -1) return __LINE__; // not a valid LEP message
    string target_script = llDeleteSubString(s, n, -1);

    // extract token
    n = llSubStringIndex(s, "\n");
    if (n == -1) return __LINE__; // not a valid LEP message
    string token = llDeleteSubString(s, n, -1);

    // remaining message is presumably json
    s = llDeleteSubString(s, 0, n);

    // filter out messages that don't match OVERRIDE_ENLEP_ALLOWED_SOURCE_SCRIPTS list
    #if defined OVERRIDE_ENLEP_ALLOWED_SOURCE_SCRIPTS
        if (llListFindList(OVERRIDE_ENLEP_ALLOWED_SOURCE_SCRIPTS, [source_script]) == -1) return 0; // discard otherwise valid LEP message, not sent from an allowed source script
    #endif

    /// generate allowed target_scripts list
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #if defined OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS
        allowed_targets += OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS; // allow messages targeted to OVERRIDE_ENLEP_ALLOWED_TARGET_SCRIPTS list as well
    #endif
    #if defined FEATURE_ENLEP_ALLOW_ALL_TARGET_SCRIPTS
        allowed_targets += [target_script]; // always match - this is less efficient, but this flag is only used for debugging anyway
    #endif

    // filter out messages not targeted to a script in allowed_targets
    if (llListFindList(allowed_targets, [target_script]) == -1)
    {
        #if defined FEATURE_ENLEP_ALLOW_FUZZY_TARGET_SCRIPT
            // using substring matching
            if (llSubStringIndex(llGetScriptName(), llList2String(parameters, 1)) == -1) return 0; // discard otherwise valid LEP message, not targeted to us
        #else
            // using exact matching
            return 0; // discard otherwise valid LEP message, not targeted to us
        #endif
    }

    if (flags & FLAG_ENLEP_TYPE_REQUEST)
    {
        #if defined EVENT_ENLEP_REQUEST
            enlep_request(
                source_link,
                source_script,
                target_script,
                token,
                json,
                data
            );
        #elif defined EVENT_ENLEP_MESSAGE
            enlep_message(
                flags,
                source_link,
                source_script,
                target_script,
                token,
                json,
                data
            );
        #endif

        return 0;
    }

    if (flags & FLAG_ENLEP_TYPE_RESPONSE)
    {
        #if defined EVENT_ENLEP_RESPONSE
            enlep_response(
                !(flags & FLAG_ENLEP_STATUS_ERROR),
                source_link,
                source_script,
                target_script,
                token,
                json,
                data
            );
        #endif
        #elif defined EVENT_ENLEP_MESSAGE
            enlep_message(
                flags,
                source_link,
                source_script,
                target_script,
                token,
                json,
                data
            );
        #endif

        return 0;
    }

    #if defined EVENT_ENLEP_BROADCAST
        enlep_broadcast(
            source_link,
            source_script,
            target_script,
            token,
            json,
            data
        );
    #endif
    #elif defined EVENT_ENLEP_MESSAGE
        enlep_message(
            flags,
            source_link,
            source_script,
            target_script,
            token,
            json,
            data
        );
    #endif

    return 0;
}

/*
sends a generic LEP message
DEPRECATED - use enLEP_Broadcast, enLEP_Request, enLEP_Response, or enLEP_Response_Error
*/
enLEP_Send(
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined TRACE_ENLEP_SEND
        enLog_TraceParams("enLEP_Send", ["target_link", "target_script", "flags", "parameters", "data"], [
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    // we don't need to send a token with this
    llMessageLinked(target_link, flags, _enLEP_GenerateLegacy(target_script, parameters, ""), data);
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
    #if defined TRACE_ENLEP_SENDAS
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
    string source_script = llList2String(parameters, 0);
    string target_script = llList2String(parameters, 1);
    list parameters = llDeleteSubList(llDeleteSubList(parameters, 0, 1), -1, -1);

    if (token == "")
    { // not using LEP token
        #if defined EVENT_ENLEP_MESSAGE && defined TRACE_ENLEP_MESSAGE
            enLog_TraceParams("enlep_message", ["source_link", "source_script", "target_script", "flags", "parameters", "data"], [
                source_link,
                enString_Elem(source_script),
                enString_Elem(target_script),
                enInteger_ElemBitfield(flags),
                enList_Elem(parameters),
                enString_Elem(k)
            ]);
        #endif
        #if defined EVENT_ENLEP_MESSAGE
            enlep_message(
                source_link,
                source_script,
                target_script,
                flags,
                parameters,
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
                source_script,
                target_script,
                flags,
                parameters,
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
                source_script,
                target_script,
                flags,
                parameters,
                k
            );
        }
    #endif

    return 1;
}
