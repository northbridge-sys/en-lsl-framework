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

This is a full script that reports all LEP messages sent via link message in the
prim. These will be reported via "en_lep_message" event reports through
enLog_TraceParams.

Loglevel must be 6 (TRACE); otherwise, these messages will be surpressed.  You
can either set the loglevel to 6 as follows to permanently enable output:
    #define ENLOG_DEFAULT_LOGLEVEL 6
or you can set the "loglevel" linkset data pair to the desired loglevel as
needed, so that inbound messages will only be reported when TRACE logging is
enabled.
*/

#define ENLEP_MESSAGE
#define ENLEP_ALLOW_ALL_TARGET_SCRIPTS

#include "en-lsl-framework/libraries.lsl"

enlep_message(
    integer source_link,
    string source_script,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    enLog_TraceParams("en_lep_message", ["source_link", "source_script", "target_script", "flags", "parameters", "data", "ENCLEP_LEP_SOURCE_PRIM", "ENCLEP_LEP_SOURCE_DOMAIN"], [
        source_link + " (" + enString_Elem(llGetLinkName(source_link)) + ")",
        enString_Elem(source_script),
        enString_Elem(target_script),
        enInteger_ElemBitwise(flags),
        enList_Elem(parameters),
        enString_Elem(data),
        enObject_Elem(ENCLEP_LEP_SOURCE_PRIM),
        enObject_Elem(ENCLEP_LEP_SOURCE_DOMAIN)
    ]);
}

default
{
    #include "en-lsl-framework/event-handlers.lsl"
}
