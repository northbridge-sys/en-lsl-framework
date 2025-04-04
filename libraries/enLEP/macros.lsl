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

#define ENLEP_TYPE_REQUEST 0x1
#define ENLEP_TYPE_RESPONSE 0x2
#define ENLEP_STATUS_ERROR 0x4

#ifndef ENLEP_LINK_MESSAGE_SCOPE
    #define ENLEP_LINK_MESSAGE_SCOPE LINK_THIS
#endif

#if defined EN_TRACE_LIBRARIES
    #define ENLEP_TRACE
#endif

#define enLEP_Generate(target_script, parameters) \
    llDumpList2String([llGetScriptName(), target_script] + parameters, "\n")
