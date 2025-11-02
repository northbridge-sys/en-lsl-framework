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

#define FLAG_ENLEP_TYPE_REQUEST 0x1
#define FLAG_ENLEP_TYPE_RESPONSE 0x2
#define FLAG_ENLEP_STATUS_ERROR 0x4

#ifndef OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE
    #define OVERRIDE_ENLEP_LINK_MESSAGE_SCOPE LINK_THIS
#endif

#if defined TRACE_EN
    #define TRACE_ENLEP
#endif

#define enLEP_Generate(target_script, parameters) \
    llDumpList2String([llGetScriptName(), target_script] + parameters, "\n")
