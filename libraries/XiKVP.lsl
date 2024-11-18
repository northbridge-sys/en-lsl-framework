/*
    XiKVP.lsl
    Library
    Xi LSL Framework
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
// == globals
// ==

// these are done as separate lists for speed, the memory difference is negligible
list _XIKVP_NAMES;
list _XIKVP_DATA;

// ==
// == functions
// ==

integer XiKVP$Exists(string name)
{ // checks if a KVP pair eXists by name
    #ifdef XIKVP$TRACE
        XiLog$TraceParams("XiKVP$Exists", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
	return llListFindList(_XIKVP_NAMES, [name]) != -1;
}

integer XiKVP$Write(string name, string data)
{ // writes a KVP pair value
    #ifdef XIKVP$TRACE
        XiLog$TraceParams("XiKVP$Write", ["name", "data"], [
            XiString$Elem(name),
            XiString$Elem(data)
            ]);
    #endif
	integer i = llListFindList(_XIKVP_NAMES, [name]);
	if (i != -1) XiKVP$Delete(name); // delete value, then reappend
	_XIKVP_NAMES += [name];
	_XIKVP_DATA += [data];
	return 1;
}

string XiKVP$Read(string name)
{ // reads a KVP pair value
    #ifdef XIKVP$TRACE
        XiLog$TraceParams("XiKVP$Read", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
	integer i = llListFindList(_XIKVP_NAMES, [name]);
	if (i == -1) return ""; // doesn't eXist
	return llList2String(_XIKVP_DATA, i);
}

XiKVP$Delete(string name)
{ // deletes a KVP pair
    #ifdef XIKVP$TRACE
        XiLog$TraceParams("XiKVP$Delete", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
	integer i = llListFindList(_XIKVP_NAMES, [name]);
	if (i == -1) return; // doesn't eXist
	_XIKVP_NAMES = llDeleteSubList(_XIKVP_NAMES, i, i);
	_XIKVP_DATA = llDeleteSubList(_XIKVP_DATA, i, i);
}
