/*
ping.lsl
LEP Processor Snippet
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

if (llList2String(params, 0) == "ping" && status & FLAG_ENLEP_TYPE_REQUEST)
{ // return script info
    enLEP_Send(
        source_link,
        source_script,
        FLAG_ENLEP_TYPE_RESPONSE,
        params,
        "lsl\n" + (string)llGetMemoryLimit() + "\n" + (string)llGetUsedMemory()
    );
}
