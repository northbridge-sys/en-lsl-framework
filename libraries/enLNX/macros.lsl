/*
enLNX.lsl
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

#define FLAG_ENLNX_ROOT 0x1
#define FLAG_ENLNX_PASS 0x2

#define FLAG_ENLNX_DELETE_CHILDREN 0x80000000

#if defined TRACE_EN
    #define TRACE_ENLNX
#endif

#if defined FEATURE_ENLNX_ENABLE_SCRIPT_NAME_HEADER
    string _ENLNX_SCRIPT_NAME;
#endif

#define enLNX_Head() \
    _enLNX_BuildHead(llGetScriptName(), llGetKey())

#define enLNX_GetHeadCount() \
    (llGetListLength(llParseStringKeepNulls(enLNX_Head(), ["\n"], [])) - 1)

#define enLNX_WriteRaw(name, data) \
    llLinksetDataWrite(0, enLNX_Head() + name, data)

#define enLNX_ReadRaw(name, data) \
    llLinksetDataRead(0, enLNX_Head() + name)
