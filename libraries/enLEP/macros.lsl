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
*/

// internal flags
#define FLAG_ENLEP_TYPE_REQUEST 0x1
#define FLAG_ENLEP_TYPE_RESPONSE 0x2
#define FLAG_ENLEP_STATUS_ERROR 0x80000000

#ifndef OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE
    #define OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE LINK_THIS
#endif

/*
Generate a LEP message string.
*/
#define _enLEP_Generate(target_script, token, json) \
    _enLEP_Generate_As(llGetScriptName(), target_script, token, json)

/*
Generate a LEP message string as a different source_script.
*/
#define _enLEP_Generate_As(source_script, target_script, token, json) \
    (llReplaceSubString(source_script, "\n", "", 0) + "\n" + llReplaceSubString(target_script, "\n", "", 0) + "\n" + llReplaceSubString(token, "\n", "", 0) + "\n" + json)

// legacy link message generation
#define _enLEP_GenerateLegacy(target_script, parameters, token) \
    llDumpList2String([llGetScriptName(), target_script] + parameters + [token], "\n")

/*
sends a LEP broadcast
target_script (if defined) in target_link will trigger first of: enlep_broadcast, enlep_message
*/
#define enLEP_Broadcast_Token(token, target_link, target_script, json, data) \
    _enLEP_Message(0, token, target_link, target_script, json, data)
#define enLEP_Broadcast(target_link, target_script, json, data) \
    _enLEP_Broadcast_Token(llGenerateKey(), target_link, target_script, json, data)

/*
sends a LEP request
target_script (if defined) in target_link will trigger first of: enlep_request, enlep_message
*/
#define enLEP_Request_Token(token, target_link, target_script, json, data) \
    _enLEP_Message(FLAG_ENLEP_TYPE_REQUEST, token, target_link, target_script, json, data)
#define enLEP_Request(target_link, target_script, json, data) \
    enLEP_Request_Token(llGenerateKey(), target_link, target_script, json, data)

/*
responds to a LEP request without adding an error message
target_script (if defined) in target_link will trigger first of: enlep_response, enlep_message
note that enLEP_Response REQUIRES the token parameter, since you can't send a response without a token
*/
#define enLEP_Response(token, target_link, target_script, json, data) \
    _enLEP_Message(FLAG_ENLEP_TYPE_RESPONSE, token, target_link, target_script, json, data)

/*
responds to a LEP request, adding an error message
target_script (if defined) in target_link will trigger first of: enlep_response, enlep_message
*/
#define enLEP_Response_Error(error, token, target_link, target_script, json, data) \
    _enLEP_Message(FLAG_ENLEP_TYPE_RESPONSE | FLAG_ENLEP_STATUS_ERROR, token, target_link, target_script, llJsonSetValue(json, ["e"], error), data)

/*
sends a message as self
*/
#define _enLEP_Message(flags, token, target_link, target_script, json, data) \
    _enLEP_Message_As(llGetScriptName(), flags, token, target_link, target_script, json, data)
