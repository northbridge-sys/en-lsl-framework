 /*
    XiAvatar.lsl
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

    TBD
*/

// ==
// == globals
// ==

// ==
// == functions
// ==

string XiAvatar$Elem( string id )
{
    return "\"" + id + "\" (secondlife:///app/agent/" + id + "/username)";
}

string XiAvatar$GetGroup(
    string id
)
{
    list attach = llGetAttachedList(id);
    string group = NULL_KEY;
    string first = llList2String(attach, 0);
    if (attach != [] && first != "NOT ON REGION" && first != "NOT FOUND") group = llList2String(llGetObjectDetails(llList2String(attaches, 0), [OBJECT_GROUP]), 0);
    return group;
}
