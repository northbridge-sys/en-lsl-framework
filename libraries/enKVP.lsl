/*
    enKVP.lsl
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

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

    These functions allow scripts to access an in-memory key-value pair list.  This
    is mainly used for dynamic configuration value options in situations where
    linkset data cannot be used and the values only need to be known at runtime.
*/

// ==
// == globals
// ==

// these are done as separate lists for speed, the memory difference is negligible
list _ENKVP_NAMES;
list _ENKVP_DATA;

// ==
// == functions
// ==

integer enKVP_Exists(list name)
{ // checks if a KVP pair exists by name
    #ifdef ENKVP_TRACE
        enLog_TraceParams("enKVP_Exists", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	return llListFindList(_ENKVP_NAMES, [llDumpList2String(name, "\n")]) != -1;
}

integer enKVP_Write(list name, string data)
{ // writes a KVP pair value
    #ifdef ENKVP_TRACE
        enLog_TraceParams("enKVP_Write", ["name", "data"], [
            enList_Elem(name),
            enString_Elem(data)
            ]);
    #endif
	integer i = llListFindList(_ENKVP_NAMES, [llDumpList2String(name, "\n")]);
	if (i != -1) enKVP_Delete(name); // delete value, then reappend
	_ENKVP_NAMES += [llDumpList2String(name, "\n")];
	_ENKVP_DATA += [data];
	return 1;
}

string enKVP_Read(list name)
{ // reads a KVP pair value
    #ifdef ENKVP_TRACE
        enLog_TraceParams("enKVP_Read", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	integer i = llListFindList(_ENKVP_NAMES, [llDumpList2String(name, "\n")]);
	if (i == -1) return ""; // doesn't exist
	return llList2String(_ENKVP_DATA, i);
}

enKVP_Delete(list name)
{ // deletes a KVP pair
    #ifdef ENKVP_TRACE
        enLog_TraceParams("enKVP_Delete", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	integer i = llListFindList(_ENKVP_NAMES, [llDumpList2String(name, "\n")]);
	if (i == -1) return; // doesn't exist
	_ENKVP_NAMES = llDeleteSubList(_ENKVP_NAMES, i, i);
	_ENKVP_DATA = llDeleteSubList(_ENKVP_DATA, i, i);
}

enKVP_Reset()
{
    #ifdef ENKVP_TRACE
        enLog_TraceParams("enKVP_Reset", [], []);
    #endif
    _ENKVP_NAMES = [];
    _ENKVP_DATA = [];
}
