/*
enLSD.lsl
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

#if defined EN_TRACE_LIBRARIES
    #define ENLSD_TRACE
#endif

string _ENLSD_PASS;

#if defined ENLSD_ENABLE_SCRIPT_NAME_HEADER
    string _ENLSD_SCRIPT_NAME;
#endif

#define enLSD_SetPass(s) \
    (_ENLSD_PASS = s)

#define enLSD_Head() \
    enLSD_BuildHead(llGetScriptName(), llGetKey())

#define enLSD_GetHeadCount() \
    (llGetListLength(llParseStringKeepNulls(enLSD_Head(), ["\n"], [])) - 1)

#define enLSD_WriteRaw(name, data) \
    llLinksetDataWrite(enLSD_Head() + name, data)

#define enLSD_ReadRaw(name, data) \
    llLinksetDataRead(enLSD_Head() + name)

#define enLSD_WriteProtectedRaw(name, data, pass) \
    llLinksetDataWriteProtected(enLSD_Head() + name, data, pass)

#define enLSD_ReadProtectedRaw(name, pass) \
    llLinksetDataReadProtected(enLSD_Head() + name, pass)
