/*
LEPTap.lsl
Utility Script
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

This is a full script that reports all LEP messages sent via link_message to
this prim.
*/

#define EVENT_ENLEP_RPC_REQUEST
#define EVENT_ENLEP_RPC_RESULT
#define EVENT_ENLEP_RPC_ERROR
#define FEATURE_ENLEP_ALLOW_ALL_TARGET_SCRIPTS
#define OVERRIDE_ENLOG_DEFAULT_LOGLEVEL 6

#include "northbridge-sys/en-lsl-framework/libraries.lsl"

enlep_rpc_request(
    integer source_link,
    string source_script,
    string target_script,
    integer int,
    string method,
    string params,
    string id
)
{
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
            source_link,
            enString_Elem(source_script),
            enString_Elem(target_script),
            int,
            method,
            params,
            id
        ]
    );
}

enlep_rpc_result(
    integer source_link,
    string source_script,
    string target_script,
    integer int,
    string method,
    string params,
    string id,
    string result
)
{
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
            "result"
        ], [
            source_link,
            enString_Elem(source_script),
            enString_Elem(target_script),
            int,
            method,
            params,
            id,
            result
        ]
    );
}

enlep_rpc_error(
    integer source_link,
    string source_script,
    string target_script,
    integer int,
    string method,
    string params,
    string id,
    integer error_code,
    string error_message,
    string error_data
)
{
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
            source_link,
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
}

default
{
    #include "northbridge-sys/en-lsl-framework/event-handlers.lsl"
}
