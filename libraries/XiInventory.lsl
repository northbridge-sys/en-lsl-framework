/*
    XiInventory.lsl
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

string _XIINVENTORY_NC_N; // notecard name
string _XIINVENTORY_NC_K; // notecard key
integer _XIINVENTORY_NC_L; // notecard line being read
integer _XIINVENTORY_NC_T; // notecard total lines
string _XIINVENTORY_NC_H; // notecard read handle
string _XIINVENTORY_NC_G; // llGetNumberOfNotecardLines handle

list _XIINVENTORY_REMOTE; // start_param, script_name, running
#define _XIINVENTORY_REMOTE_STRIDE 3

// ==
// == functions
// ==

list XiInventory$List(
    integer t
    )
{
    list x;
    integer i;
    integer l = llGetInventoryNumber(t);
    for (i = 0; i < l; i++)
    {
        x += llGetInventoryName(t, i);
    }
    return x;
}

integer XiInventory$Copy( // copies an inventory item to another object
    string prim,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams("XiInventory$Copy", ["prim", "name", "type", "pin", "run", "param"], [
            XiObject$Elem(prim),
            XiString$Elem(name),
            type,
            pin,
            run,
            param
            ]);
    #endif
    integer t = llGetInventoryType(name);
    if (type != INVENTORY_ALL && type != t) return 0; // type check failed
    if (t == INVENTORY_NONE) return 0; // can't push anything
    integer p = llGetInventoryPermMask(name, MASK_OWNER);
    if (!(p & PERM_COPY)) return 0; // can't push a no-copy inventory item
    if (t == INVENTORY_SCRIPT && pin) llRemoteLoadScriptPin(prim, name, pin, run, param);
    else llGiveInventory(prim, name);
    return 1;
}

integer XiInventory$OwnedByCreator(
    string name
)
{
    return llGetInventoryCreator( name ) == llGetOwner();
}

integer XiInventory$RezRemote( // rezzes a remote object with Remote.lsl
    string name,
    vector pos,
    vector vel,
    rotation rot,
    integer param,
    list scripts,
    list runs
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams( "XiInventory$RezRemote", [ "name", "pos", "vel", "rot", "param", "scripts", "runs" ], [
            XiString$Elem( name ),
            (string)pos,
            (string)vel,
            (string)rot,
            (string)param,
            XiList$Elem( scripts ),
            XiList$Elem( runs )
            ] );
    #endif
    XiLog$( DEBUG, "Rezzing remote object with loglevel " + XiLog$LevelToString( (integer)llLinksetDataRead( "loglevel" ) ) + "." );
    llRezAtRoot( name, pos, vel, rot, (integer)llLinksetDataRead( "loglevel" ) );
    _XIINVENTORY_REMOTE += [ param, XiList$ToString( scripts ), XiList$ToString( runs ) ];
    // TODO: somehow timeout _XIINVENTORY_REMOTE
    return 1;
}

integer XiInventory$NCOpen( // opens a notecard for XiInventory$NC* operations
    string name
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams("XiInventory$NCOpen", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
    #ifndef XIINVENTORY$ENABLE_NC
        XiLog$(DEBUG, "XIINVENTORY$ENABLE_NC not defined.");
        return;
    #endif
    _XIINVENTORY_NC_N = name;
    _XIINVENTORY_NC_L = -1;
    _XIINVENTORY_NC_T = -1;
    _XIINVENTORY_NC_G = llGetNumberOfNotecardLines(_XIINVENTORY_NC_N);
    key new_NC_K = llGetInventoryKey(_XIINVENTORY_NC_N);
    if (new_NC_K == NULL_KEY) return 0; // notecard doesn't exist
    if (new_NC_K == _XIINVENTORY_NC_K) return 0x1; // notecard opened, no changes since last opened
    _XIINVENTORY_NC_K = new_NC_K;
    return 0x3; // notecard opened, changes since last opened
}

XiInventory$NCRead( // reads a line from the open notecard
    integer i // line number, starting from 0
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams("XiInventory$NCRead", ["i"], [
            i
            ]);
    #endif
    #ifndef XIINVENTORY$ENABLE_NC
        XiLog$(DEBUG, "XIINVENTORY$ENABLE_NC not defined.");
        return;
    #else
        string s = NAK;
        if (llGetFreeMemory() > 4096) s = llGetNotecardLineSync(_XIINVENTORY_NC_N, i); // attempt sync read if at least 2k of memory free
        if (s == NAK) _XIINVENTORY_NC_H = llGetNotecardLine(_XIINVENTORY_NC_N, i); // sync read failed, do dataserver read
        else Xi$nc_line(_XIINVENTORY_NC_N, _XIINVENTORY_NC_L, _XIINVENTORY_NC_T, s);
    #endif
}

integer _XiInventory$NCParse(
    string query,
    string data
    )
{
    if (query == _XIINVENTORY_NC_K)
    {
        Xi$nc_line(_XIINVENTORY_NC_N, _XIINVENTORY_NC_L, _XIINVENTORY_NC_T, data);
        return 1;
    }
    if (query == _XIINVENTORY_NC_G)
    {
        _XIINVENTORY_NC_T = (integer)data;
        return 1;
    }
    return 0;
}

string XiInventory$TypeToString( // converts an INVENTORY_* flag into a string (use "INVENTORY_" + llToUpper(XiInventory$TypeToString(...)) to get actual flag name)
    integer f // INVENTORY_* flag
    )
{
    if (f == -1) return ""; // return empty string for INVENTORY_NONE and INVENTORY_ALL
    integer i = llListFindList([
        INVENTORY_TEXTURE,
        INVENTORY_SOUND,
        INVENTORY_LANDMARK,
        INVENTORY_CLOTHING,
        INVENTORY_OBJECT,
        INVENTORY_NOTECARD,
        INVENTORY_SCRIPT,
        INVENTORY_BODYPART,
        INVENTORY_ANIMATION,
        INVENTORY_GESTURE,
        INVENTORY_SETTING,
        INVENTORY_MATERIAL
        ], [f]);
    if (i == -1) return "Unknown"; // return "Unknown" for a flag that is not known by XiInventory at compile time
    return llList2String([
        "Texture",
        "Sound",
        "Landmark",
        "Clothing",
        "Object",
        "Notecard",
        "Script",
        "BodyPart",
        "Animation",
        "Gesture",
        "Setting",
        "Material"
        ], i);
}

XiInventory$Push( // pushes an inventory item via XiChat
    string prim,
    string domain,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams("XiInventory$Push", ["prim", "domain", "name", "type", "pin", "run", "param"], [
            XiObject$Elem(prim),
            XiString$Elem(domain),
            XiString$Elem(name),
            type,
            pin,
            run,
            param
            ]);
    #endif
    // TODO
}

XiInventory$Pull( // pulls an inventory item via XiChat
    string prim,
    string domain,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef XIINVENTORY$TRACE
        XiLog$TraceParams("XiInventory$Pull", ["prim", "domain", "name", "type", "pin", "run", "param"], [
            XiObject$Elem(prim),
            XiString$Elem(domain),
            XiString$Elem(name),
            type,
            pin,
            run,
            param
            ]);
    #endif
    // TODO
}
