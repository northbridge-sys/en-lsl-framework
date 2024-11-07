/*
    XiKVP.lsl
    Library
    Xi LSL Framework
    Revision 0
    Copyright (C) 2024  BuildTronics
    https://docs.buildtronics.net/xi-lsl-framework

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

    These functions allow scripts to access an in-memory key-value pair list.  This
    is mainly used for dynamic configuration value options in situations where
    linkset data cannot be used and the values only need to be known at runtime.
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XIKVP_ENABLE_XILOG_TRACE
#endif

// ==
// == globals
// ==

// these are done as separate lists for speed, the memory difference is negligible
list XIKVP_NAMES;
list XIKVP_DATA;

// ==
// == functions
// ==

integer XiKVP_EXists(string name)
{ // checks if a KVP pair eXists by name
    #ifdef XIKVP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiKVP_EXists", ["name"], [
            XiString_Elem(name)
            ]);
    #endif
	return llListFindList(XIKVP_NAMES, [name]) != -1;
}

integer XiKVP_Write(string name, string data)
{ // writes a KVP pair value
    #ifdef XIKVP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiKVP_Write", ["name", "data"], [
            XiString_Elem(name),
            XiString_Elem(data)
            ]);
    #endif
	integer i = llListFindList(XIKVP_NAMES, [name]);
	if (i != -1) XiKVP_Delete(name); // delete value, then reappend
	XIKVP_NAMES += [name];
	XIKVP_DATA += [data];
	return 1;
}

string XiKVP_Read(string name)
{ // reads a KVP pair value
    #ifdef XIKVP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiKVP_Read", ["name"], [
            XiString_Elem(name)
            ]);
    #endif
	integer i = llListFindList(XIKVP_NAMES, [name]);
	if (i == -1) return ""; // doesn't eXist
	return llList2String(XIKVP_DATA, i);
}

XiKVP_Delete(string name)
{ // deletes a KVP pair
    #ifdef XIKVP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiKVP_Delete", ["name"], [
            XiString_Elem(name)
            ]);
    #endif
	integer i = llListFindList(XIKVP_NAMES, [name]);
	if (i == -1) return; // doesn't eXist
	XIKVP_NAMES = llDeleteSubList(XIKVP_NAMES, i, i);
	XIKVP_DATA = llDeleteSubList(XIKVP_DATA, i, i);
}
