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

/*
this is loosely based on JSON-RPC, optimized for LSL's tight memory limits and adding LEP routing metadata: https://en.wikipedia.org/wiki/JSON-RPC
*/
string _enLEP_FormJsonRPC(
    string source_script,
    string target_script,
    string method,
    string id,
    string result,
    integer error_code,
    string error_message,
    string error_data
)
{
    /*
    LEP requests are:
    {
        "t":"RPC",
        "ss":"(name of source script)",
        "ts":"(name of target script)",
        "id":"(any string)", <- can be omitted if no response requested (broadcast)
        "m":"any.method"
    }
    LEP responses swap "ss" and "ts", and add either:
    {
        "e":{
            "c":(integer error code),
            "m":"(string error message)",
            "d":(any JSON data) <- can be omitted if no error_data provided
        }
    }
    or:
    {
        "r":(any JSON data)
    }
    LEP sends the raw "params" value to an independent string so it can handle any data (JSON-RPC packs it into the JSON).
    LEP also passes through target_link and int directly to llMessageLinked().
    The "p" param is optionally reserved for params (used in CLEP, but not LEP for message processing efficiency)
    Technically no other params are allowed, and the whole spec is reserved for future expansion - all user values must be passed via existing params in the spec
    */
    string json = "{\"t\":\"RPC\",\"ss\":" + enString_EscapedQuote(source_script) + ",\"ts\":" + enString_EscapedQuote(target_script) + ",\"m\":" + enString_EscapedQuote(method) + "\"}";
    if (id != "") json = llJsonSetValue(json, ["id"], enString_EscapedQuote(id));
    if (llJsonGetType(result, []) != JSON_INVALID)
    { // we are sending a response with a result
        json = llJsonSetValue(json, ["r"], result);
    }
    else if (error_code || error_message != "" || error_data != "")
    { // we are sending a response with an error
        json = llJsonSetValue(json, ["e", "c"], (string)error_code);
        json = llJsonSetValue(json, ["e", "m"], enString_EscapedQuote(error_message));
    }
    // else, we are sending a request
    // return whatever we're sending
    return json;
}

/*!
Sends a request using the LEP-RPC protocol.
@param integer target_link Target link number.
@param string target_script Target script name ("" for all in targeted link(s)).
@param integer int Any integer.
@param string method Any method. Typically separated by periods ("."), e.g.: system.display.pixel.color
@param string params Any JSON. This parameter is passed as a raw string, but needs to be valid JSON for CLEP encapsulation, which assumes it is valid JSON.
@param string id Any string. If "", will be omitted.
*/
#define enLEP_RequestRPC(target_link, target_script, int, method, params, id) \
    _enLEP_SendRPC(target_link, target_script, int, method, params, id, "", 0, "", "")

/*!
Responds using the LEP-RPC protocol.
@param integer target_link source_link sent via link_message.
@param string target_script source_script sent in request.
@param integer int Integer sent in request.
@param string method Method sent in request.
@param string id ID sent in request.
@param string result SUCCESSFUL RESPONSES ONLY: Any JSON. This parameter is passed as a raw string, but needs to be valid JSON for CLEP encapsulation, which assumes it is valid JSON. If "", will be omitted.
@param integer error_code ERROR RESPONSES ONLY: Any integer. If 0 and both other error_* params are "", the error information will be omitted.
@param string error_message ERROR RESPONSES ONLY: Any string.
@param string error_data ERROR RESPONSES ONLY: Any JSON.
*/
#define _enLEP_RespondRPC(target_link, target_script, int, method, params, id, result, error_code, error_message, error_data) \
    _enLEP_SendRPC(target_link, target_script, int, method, params, id, result, error_code, error_message, error_data)

/*!
Responds with a result using the LEP-RPC protocol.
@param integer target_link source_link sent via link_message.
@param string target_script source_script sent in request.
@param integer int Integer sent in request.
@param string method Method sent in request.
@param string id ID sent in request.
@param string result Any JSON. This parameter is passed as a raw string, but needs to be valid JSON for CLEP encapsulation, which assumes it is valid JSON.
*/
#define enLEP_RespondRPCResult(target_link, target_script, int, method, params, id, result) \
    _enLEP_RespondRPC(target_link, target_script, int, method, params, id, result, 0, "", "")

/*!
Responds with an error using the LEP-RPC protocol.
@param integer target_link source_link sent via link_message.
@param string target_script source_script sent in request.
@param integer int Integer sent in request.
@param string method Method sent in request.
@param string id ID sent in request.
@param integer error_code Any integer.
@param string error_message Any string.
@param string error_data Any JSON.
*/
#define enLEP_RespondRPCError(target_link, target_script, int, method, params, id, error_code, error_message, error_data) \
    _enLEP_RespondRPC(target_link, target_script, int, method, params, id, "", error_code, error_message, error_data)

string _enLEP_SendRPC(
    integer target_link,
    string target_script,
    integer int,
    string method,
    string params,
    string id,
    string result,
    integer error_code,
    string error_message,
    string error_data
)
{
    #if defined TRACE_ENLEP_SENDRPC
        enLog_TraceParams(
            "_enLEP_SendRPC",
            [
                "target_link",
                "target_script",
                "int",
                "method",
                "params",
                "id",
                "result",
                "error_code",
                "error_message",
                "error_data"
            ],
            [
                target_link,
                enString_Elem(target_script),
                int,
                method,
                params,
                id,
                result,
                error_code,
                enString_Elem(error_message),
                error_data
            ]
        );
    #endif

    if (!target_link) target_link = OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, int, _enLEP_FormJsonRPC(llGetScriptName(), target_script, method, id, result, error_code, error_message, error_data), params);
    return id;
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
    #if defined TRACE_ENLEP_LINK_MESSAGE
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

    if (llJsonGetType(s, []) != JSON_OBJECT) return __LINE__; // LEP messages are always objects
    
    string source_script = llJsonGetValue(s, ["ss"]);
    string target_script = llJsonGetValue(s, ["ts"]);

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
            if (llSubStringIndex(llGetScriptName(), target_script) == -1) return 0; // discard otherwise valid LEP message, not targeted to us
        #else
            // using exact matching
            return 0; // discard otherwise valid LEP message, not targeted to us
        #endif
    }

    if (llJsonGetValue(s, ["t"] != "RPC")) return __LINE__; // LEP messages always have "t":"RPC", though other types may be added within LEP spec eventually

    string source_prim = llGetLinkKey(l);
    string id = llJsonGetValue(s, ["id"]);
    list method = llParseStringKeepNulls(llJsonGetValue(s, ["m"]), ["."], []);
    string params = llJsonGetValue(s, ["p"]);
    string result = llJsonGetValue(s, ["r"]);

    if (result == JSON_INVALID)
    {
        if (llJsonGetType(s, ["e"]) == JSON_INVALID)
        { // request
            #if defined EVENT_ENLEP_RPC_REQUEST && defined TRACE_EVENT_ENLEP_RPC_REQUEST
                enLog_TraceParams(
                    "enlep_rpc_request",
                    [
                        "source_link",
                        "source_script",
                        "target_script",
                        "int",
                        "method",
                        "params",
                        "id"
                    ], [
                        l, // source_link
                        enString_Elem(source_script),
                        enString_Elem(target_script),
                        int,
                        method,
                        params,
                        id
                    ]
                );
            #endif
            #if defined EVENT_ENLEP_RPC_REQUEST
                enlep_rpc_request(
                    l, // source_link
                    source_script,
                    target_script,
                    int,
                    method,
                    params,
                    id
                );
            #endif
            return 0;
        }

        // error response
        integer error_code = (integer)llJsonGetValue(s, ["e", "c"]);
        string error_message = llJsonGetValue(s, ["e", "m"]);
        string error_data = llJsonGetValue(s, ["e", "d"]);
        #if defined EVENT_ENLEP_RPC_ERROR && defined TRACE_EVENT_ENLEP_RPC_ERROR
            enLog_TraceParams(
                "enlep_rpc_error",
                [
                    "source_link",
                    "source_script",
                    "target_script",
                    "int",
                    "method",
                    "params",
                    "id",
                    "error_code",
                    "error_message",
                    "error_data"
                ], [
                    l, // source_link
                    enString_Elem(source_script),
                    enString_Elem(target_script),
                    int,
                    method,
                    params,
                    id,
                    error_code,
                    enString_Elem(error_message),
                    error_data
                ]
            );
        #endif
        #if defined EVENT_ENLEP_RPC_ERROR
            enlep_rpc_error(
                l, // source_link
                source_script,
                target_script,
                int,
                method,
                params,
                id,
                error_code,
                error_message,
                error_data
            );
        #endif
        return 0;
    }

    // result response
    integer result = llJsonGetValue(s, ["r"]);
    #if defined EVENT_ENLEP_RPC_RESULT && defined TRACE_EVENT_ENLEP_RPC_RESULT
        enLog_TraceParams(
            "enlep_rpc_result",
            [
                "source_link",
                "source_script",
                "target_script",
                "int",
                "method",
                "params",
                "id",
                "result"
            ], [
                l, // source_link
                enString_Elem(source_script),
                enString_Elem(target_script),
                int,
                method,
                params,
                id,
                result
            ]
        );
    #endif
    #if defined EVENT_ENLEP_RPC_RESULT
        enlep_rpc_result(
            l, // source_link
            source_script,
            target_script,
            int,
            method,
            params,
            id,
            result
        );
    #endif
    return 0;
}
