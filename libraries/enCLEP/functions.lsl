/*
enCLEP.lsl
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
enCLEP_DialogListen opens a regular llListen on an enCLEP channel tied to this prim UUID and script name.
This can be used in conjunction with enCLEP_DialogChannel for a safe nearly-guaranteed-random channel for this script.
*/
enCLEP_DialogListen()
{
    _enCLEP_UnListenDomains();
    if (_ENCLEP_DIALOG_LSN) llListenRemove(_ENCLEP_DIALOG_LSN);
    integer channel = enCLEP_DialogChannel();
    _ENCLEP_DIALOG_LSN = llListen(channel, "", "", "");
    enLog_Trace("Dialog listening on channel " + (string)channel + " handle " + (string)_ENCLEP_DIALOG_LSN);
    _enCLEP_ListenDomains();
}

/*
Removes the listen created by enCLEP_DialogListen.
*/
enCLEP_DialogListenRemove()
{
    if (!_ENCLEP_DIALOG_LSN) return;
    _enCLEP_UnListenDomains();
    llListenRemove(_ENCLEP_DIALOG_LSN);
    _ENCLEP_DIALOG_LSN = 0;
    _enCLEP_ListenDomains();
}

/*
Initializes or updates a dynamically managed enCLEP listener.
This is like llListen, but easier to use.

enCLEP_Listen(...) will return 0 and fail to add the listen if you attempt to
add more than 65 listeners (the maximum allowed per script). If you call
llListen separately, set the number of listens you want reserved for non-enCLEP\
use by adding the following line:
    #define OVERRIDE_INTEGER_ENCLEP_RESERVE_LISTENS x
where x is the number of listens you want to allocate for non-enCLEP use.

Note: domains can be set as the local prim's UUID, in which case they will be
automatically refreshed on key or link change. However, this ONLY works if the
domain itself is just the UUID - no other data can be added.

WARNING: If the local prim's UUID is used as the domain, you MUST use the
state_entry, on_rez, and changed event handler include files, which will
dynamically update the domain after a key change. (This is done automatically
in event-handlers.lsl if you use it.)
*/
integer enCLEP_Listen(
    string domain,  // domain to listen to
    integer flags   // ENCLEP_LISTEN_* flags
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_Listen", ["domain", "flags"], [
            enString_Elem(domain),
            enInteger_ElemBitfield(flags)
            ]);
    #endif
    _enCLEP_UnListenDomains();
    integer index = llListFindList(_ENCLEP_DOMAINS, [domain]);
    if (index == -1 && flags & FLAG_ENCLEP_LISTEN_REMOVE)
    { // nothing to remove, so return error
        _enCLEP_ListenDomains();
        return __LINE__;
    }
    if (~index) _ENCLEP_DOMAINS = llDeleteSubList(_ENCLEP_DOMAINS, index, index + _ENCLEP_DOMAINS_STRIDE - 1); // index == -1; delete existing domain enCLEP, so it can be cleanly appended to the end
    if (llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE + OVERRIDE_INTEGER_ENCLEP_RESERVE_LISTENS > 63)
    { // too many listens (maximum 65, so if we are currently at 64 or more, fail)
        _enCLEP_ListenDomains();
        return __LINE__;
    }
    if (~flags & FLAG_ENCLEP_LISTEN_REMOVE) _ENCLEP_DOMAINS += [domain, flags, 0]; // add to _ENCLEP_DOMAINS only if we aren't removing it
    _enCLEP_ListenDomains();
    return 0;
}

//  resets and removes all enCLEP listeners, for single-purpose scripts to not have to independently keep track of listen handles
enCLEP_Reset()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_Reset", [], []);
    #endif
    _enCLEP_UnListenDomains();
    _ENCLEP_DOMAINS = [];
}

//  Internal function that dynamically selects a chat method to use based on the target prim
//  NULL_KEY or "" can be passed as a prim to use llRegionSay automatically
//  If FEATURE_ENCLEP_ENABLE_SHOUT is defined, a llRegionSayTo message will be sent via llShout to attempt to reach a prim across a nearby sim border
_enCLEP_SendRaw( // llRegionSayTo with llRegionSay for NULL_KEY instead of silently failing
    string prim,
    integer channel,
    string message
    )
{
    #if defined TRACE_ENCLEP_SENDRAW
        enLog_TraceParams("_enCLEP_SendRaw", ["prim", "channel", "message"], [
            enString_Elem(prim),
            channel,
            enString_Elem(message)
        ]);
    #endif
        if (prim == "") prim = NULL_KEY;
        if (prim == NULL_KEY) llRegionSay(channel, message); // RS if prim is not specified
        else if (llGetObjectDetails(prim, [OBJECT_PHANTOM]) != []) llRegionSayTo(prim, channel, message); // RST if prim is in region
    #if defined FEATURE_ENCLEP_ENABLE_SHOUT
        else llShout(channel, message); // shout if prim is not in region and FEATURE_ENCLEP_ENABLE_SHOUT is defined
    #elif defined FEATURE_ENCLEP_ENABLE_SAY
        else llSay(channel, message); // say if prim is not in region and FEATURE_ENCLEP_ENABLE_SAY is defined
    #elif defined FEATURE_ENCLEP_ENABLE_WHISPER
        else llWhisper(channel, message); // whisper if prim is not in region and FEATURE_ENCLEP_ENABLE_WHISPER is defined
    #endif
}

/*
CLEP-RPC, compatible with LEP-RPC.
*/
string _enCLEP_SendRPC(
    string target_prim,
    string target_script,
    string clep_domain,
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
    #if defined TRACE_ENCLEP_SENDRPC
        enLog_TraceParams(
            "_enCLEP_SendRPC",
            [
                "target_prim",
                "target_script",
                "clep_domain",
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
                enPrim_Elem(target_prim),
                enString_Elem(target_script),
                enString_Elem(clep_domain),
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

    string json = 
        llJsonSetValue(
            _enLEP_FormJsonRPC(llGetScriptName(), target_script, method, id, result, error_code, error_message, error_data),
            ["i"],
            (string)int
        );
    
    if (llJsonGetType(clep_domain, []) == JSON_INVALID) json = llJsonSetValue(json, ["cd"], clep_domain);
    else json = llJsonSetValue(json, ["cd"], enString_EscapedQuote(clep_domain));

    if (llJsonGetType(params, []) != JSON_INVALID) json = llJsonSetValue(json, ["p"], params);

    _enCLEP_SendRaw(target_prim, enCLEP_Channel(clep_domain), json);

    return id;
}

/*
Process incoming listen event to see if it is a CLEP message.
If not, return a positive integer.
If so, check that the message is acceptable (matches a listened-to domain, ownership checks, etc.)
If the message is acceptable, route it appropriately (either to enLEP, or whatever other library or protocol) and return 0.
If not, return 0 to signal a CLEP message even if it wasn't routable.
*/

integer _enCLEP_listen(
    integer channel,
    string source_name,
    string source_prim,
    string s
)
{
    #if defined TRACE_ENCLEP_LISTEN
        enLog_TraceParams("_enCLEP_listen", ["channel", "source_name", "source_prim", "s"], [
            channel,
            enString_Elem(source_name),
            enString_Elem(source_prim),
            enString_Elem(s)
            ]);
    #endif

    if (llJsonGetType(s, []) != JSON_OBJECT) return __LINE__; // CLEP messages are always objects
    
    string source_script = llJsonGetValue(s, ["ss"]);
    string target_script = llJsonGetValue(s, ["ts"]);

    // filter out messages that don't match OVERRIDE_ENCLEP_ALLOWED_SOURCE_SCRIPTS list
    #if defined OVERRIDE_ENCLEP_ALLOWED_SOURCE_SCRIPTS
        if (llListFindList(OVERRIDE_ENCLEP_ALLOWED_SOURCE_SCRIPTS, [source_script]) == -1) return 0; // discard otherwise valid CLEP message, not sent from an allowed source script
    #endif

    /// generate allowed target_scripts list
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #if defined OVERRIDE_ENCLEP_ALLOWED_TARGET_SCRIPTS
        allowed_targets += OVERRIDE_ENCLEP_ALLOWED_TARGET_SCRIPTS; // allow messages targeted to OVERRIDE_ENCLEP_ALLOWED_TARGET_SCRIPTS list as well
    #endif
    #if defined FEATURE_ENCLEP_ALLOW_ALL_TARGET_SCRIPTS
        allowed_targets += [target_script]; // always match - this is less efficient, but this flag is only used for debugging anyway
    #endif

    // filter out messages not targeted to a script in allowed_targets
    if (llListFindList(allowed_targets, [target_script]) == -1)
    {
        #if defined FEATURE_ENCLEP_ALLOW_FUZZY_TARGET_SCRIPT
            // using substring matching
            if (llSubStringIndex(llGetScriptName(), target_script) == -1) return 0; // discard otherwise valid CLEP message, not targeted to us
        #else
            // using exact matching
            return 0; // discard otherwise valid CLEP message, not targeted to us
        #endif
    }

    if (llJsonGetValue(s, ["t"] != "RPC")) return __LINE__; // CLEP messages always have "t":"RPC", though other types may be added within CLEP spec eventually

    string id = llJsonGetValue(s, ["id"]);
    integer int = (integer)llJsonGetValue(s, ["i"]);
    list method = llParseStringKeepNulls(llJsonGetValue(s, ["m"]), ["."], []);
    string params = llJsonGetValue(s, ["p"]);
    string result = llJsonGetValue(s, ["r"]);

    if (result == JSON_INVALID)
    {
        if (llJsonGetType(s, ["e"]) == JSON_INVALID)
        { // request
            #if defined EVENT_ENCLEP_RPC_REQUEST && defined TRACE_EVENT_ENCLEP_RPC_REQUEST
                enLog_TraceParams(
                    "enclep_rpc_request",
                    [
                        "source_prim",
                        "source_script",
                        "target_script",
                        "int",
                        "method",
                        "params",
                        "id"
                    ], [
                        source_prim,
                        enString_Elem(source_script),
                        enString_Elem(target_script),
                        int,
                        method,
                        params,
                        id
                    ]
                );
            #endif
            #if defined EVENT_ENCLEP_RPC_REQUEST
                enclep_rpc_request(
                    source_prim,
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
        #if defined EVENT_ENCLEP_RPC_ERROR && defined TRACE_EVENT_ENCLEP_RPC_ERROR
            enLog_TraceParams(
                "enclep_rpc_error",
                [
                    "source_prim",
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
                    source_prim,
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
        #if defined EVENT_ENCLEP_RPC_ERROR
            enclep_rpc_error(
                source_prim,
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
    #if defined EVENT_ENCLEP_RPC_RESULT && defined TRACE_EVENT_ENCLEP_RPC_RESULT
        enLog_TraceParams(
            "enclep_rpc_result",
            [
                "source_prim",
                "source_script",
                "target_script",
                "int",
                "method",
                "params",
                "id",
                "result"
            ], [
                source_prim,
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
    #if defined EVENT_ENCLEP_RPC_RESULT
        enlep_rpc_result(
            source_prim,
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

//  internal function that runs llListenRemove on everything in _ENCLEP_DOMAINS
_enCLEP_UnListenDomains()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_UnListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    for (i = 0; i < l; i++) llListenRemove((integer)llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 2)); // for each domain in _ENCLEP_DOMAINS, remove listen by handle (we'll be replacing later)
}

//  internal function that runs llListen on everything in _ENCLEP_DOMAINS - DON'T run this without running _enCLEP_UnListenDomains() first!
_enCLEP_ListenDomains()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_ListenDomains", [], []);
    #endif

    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    if (l > 64 - enCLEP_Reserved())
    {
        enLog_Warn("enCLEP overflow (" + (string)l + " + " + (string)enCLEP_Reserved() + " reserved > 64)");
        l = 64 - enCLEP_Reserved();
    }
    list c;
    // for each domain in _ENCLEP_DOMAINS, add listen and update _ENCLEP_DOMAINS with handle
    for (i = 0; i < l; i++)
    {
        string domain = llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE);
        integer channel = enCLEP_Channel(service, domain);
        c += [channel];
        integer handle = llListen(llList2Integer(c, -1), "", "", "");
        llListReplaceList(_ENCLEP_DOMAINS, [handle], i * _ENCLEP_DOMAINS_STRIDE + 2, i * _ENCLEP_DOMAINS_STRIDE + 2);
        enLog_Trace("enCLEP listening on domain \"" + domain + "\" channel " + (string)channel + " handle " + (string)handle);
    }
}

//  internal function that runs after key change to reset any listens based on previous UUID
_enCLEP_uuid_changed(
    string last_uuid
)
{
    _enCLEP_UnListenDomains();
    // are we listening to a self-domain?
    integer index = llListFindList(llList2ListSlice(_ENCLEP_DOMAINS, 0, -1, _ENCLEP_DOMAINS_STRIDE, 0), [last_uuid]);
    // if we are, replace it
    if (index != -1) _ENCLEP_DOMAINS = llListReplaceList(_ENCLEP_DOMAINS,
        [(string)llGetKey()],
        index * _ENCLEP_DOMAINS_STRIDE,
        index * _ENCLEP_DOMAINS_STRIDE);
    _enCLEP_ListenDomains();
}
