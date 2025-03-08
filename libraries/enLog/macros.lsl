/*
enLog.lsl
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

#define enLog_Print(...) enLog_To( 0, __LINE__, "", __VA_ARGS__ )
#define enLog_Fatal(...) enLog_To( 1, __LINE__, "", __VA_ARGS__ )
#define enLog_Error(...) enLog_To( 2, __LINE__, "", __VA_ARGS__ )
#define enLog_Warn(...) enLog_To( 3, __LINE__, "", __VA_ARGS__ )
#define enLog_Info(...) enLog_To( 4, __LINE__, "", __VA_ARGS__ )
#define enLog_Debug(...) enLog_To( 5, __LINE__, "", __VA_ARGS__ )
#define enLog_Trace(...) enLog_To( 6, __LINE__, "", __VA_ARGS__ )

#define enLog_PrintTo(...) enLog_To( 0, __LINE__, __VA_ARGS__ )
#define enLog_FatalTo(...) enLog_To( 1, __LINE__, __VA_ARGS__ )
#define enLog_ErrorTo(...) enLog_To( 2, __LINE__, __VA_ARGS__ )
#define enLog_WarnTo(...) enLog_To( 3, __LINE__, __VA_ARGS__ )
#define enLog_InfoTo(...) enLog_To( 4, __LINE__, __VA_ARGS__ )
#define enLog_DebugTo(...) enLog_To( 5, __LINE__, __VA_ARGS__ )
#define enLog_TraceTo(...) enLog_To( 6, __LINE__, __VA_ARGS__ )

#define enLog_TraceVars(var_names, var_values) \
    enLog_TraceParams("enLog_TraceVars", var_names, var_values)

#define enLog_GetLogtarget() \
    llLinksetDataRead("logtarget")

#define enLog_SetLogtarget(target) \
    llLinksetDataWrite("logtarget", target)
