/*
    enKVS.lsl
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
list _ENKVS_NAMES;
list _ENKVS_DATA;

// ==
// == functions
// ==

integer enKVS_Exists(list name)
{ // checks if a KVS pair exists by name
    #ifdef ENKVS_TRACE
        enLog_TraceParams("enKVS_Exists", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	return ~llListFindList(_ENKVS_NAMES, [llDumpList2String(name, "\n")]); // != -1
}

integer enKVS_Write(list name, string data)
{ // writes a KVS pair value
    #ifdef ENKVS_TRACE
        enLog_TraceParams("enKVS_Write", ["name", "data"], [
            enList_Elem(name),
            enString_Elem(data)
            ]);
    #endif
	integer i = llListFindList(_ENKVS_NAMES, [llDumpList2String(name, "\n")]);
	if (~i) enKVS_Delete(name);  // != -1; delete value, then reappend
	_ENKVS_NAMES += [llDumpList2String(name, "\n")];
	_ENKVS_DATA += [data];
	return 1;
}

string enKVS_Read(list name)
{ // reads a KVS pair value
    #ifdef ENKVS_TRACE
        enLog_TraceParams("enKVS_Read", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	integer i = llListFindList(_ENKVS_NAMES, [llDumpList2String(name, "\n")]);
	if (i == -1) return ""; // doesn't exist
	return llList2String(_ENKVS_DATA, i);
}

enKVS_Delete(list name)
{ // deletes a KVS pair
    #ifdef ENKVS_TRACE
        enLog_TraceParams("enKVS_Delete", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	integer i = llListFindList(_ENKVS_NAMES, [llDumpList2String(name, "\n")]);
	if (i == -1) return; // doesn't exist
	_ENKVS_NAMES = llDeleteSubList(_ENKVS_NAMES, i, i);
	_ENKVS_DATA = llDeleteSubList(_ENKVS_DATA, i, i);
}

enKVS_Reset()
{
    #ifdef ENKVS_TRACE
        enLog_TraceParams("enKVS_Reset", [], []);
    #endif
    _ENKVS_NAMES = [];
    _ENKVS_DATA = [];
}
