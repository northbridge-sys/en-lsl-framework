/*
    enInventory.lsl
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

    TBD
*/

// ==
// == globals
// ==

string _ENINVENTORY_NC_N; // notecard name
string _ENINVENTORY_NC_K; // notecard key
integer _ENINVENTORY_NC_L = -1; // notecard line being read
integer _ENINVENTORY_NC_T = -1; // notecard total lines
string _ENINVENTORY_NC_H; // notecard read handle
string _ENINVENTORY_NC_G; // llGetNumberOfNotecardLines handle

list _ENINVENTORY_REMOTE; // start_param, script_name, running
#define _ENINVENTORY_REMOTE_STRIDE 3

// ==
// == functions
// ==

list enInventory$List(
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

integer enInventory$Copy( // copies an inventory item to another object
    string prim,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams("enInventory$Copy", ["prim", "name", "type", "pin", "run", "param"], [
            enObject$Elem(prim),
            enString$Elem(name),
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

integer enInventory$OwnedByCreator(
    string name
)
{
    return llGetInventoryCreator( name ) == llGetOwner();
}

integer enInventory$RezRemote( // rezzes a remote object with Remote.lsl
    string name,
    vector pos,
    vector vel,
    rotation rot,
    integer param,
    list scripts,
    list runs
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams( "enInventory$RezRemote", [ "name", "pos", "vel", "rot", "param", "scripts", "runs" ], [
            enString$Elem( name ),
            (string)pos,
            (string)vel,
            (string)rot,
            (string)param,
            enList$Elem( scripts ),
            enList$Elem( runs )
            ] );
    #endif
    enLog$( DEBUG, "Rezzing remote object with loglevel " + enLog$LevelToString( (integer)llLinksetDataRead( "loglevel" ) ) + "." );
    llRezAtRoot( name, pos, vel, rot, (integer)llLinksetDataRead( "loglevel" ) );
    _ENINVENTORY_REMOTE += [ param, enList$ToString( scripts ), enList$ToString( runs ) ];
    // TODO: somehow timeout _ENINVENTORY_REMOTE
    return 1;
}

integer enInventory$NCOpenByPartialName( // opens a notecard for enInventory$NC* operations using a partial name
    string name
)
{
    list ncs = enInventory$List(INVENTORY_NOTECARD);
    integer nc = enList$FindPartial(ncs, name);
    if (nc == -1) return 0;
    else return enInventory$NCOpen(llList2String(ncs, nc));
}

integer enInventory$NCOpen( // opens a notecard for enInventory$NC* operations
    string name
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams("enInventory$NCOpen", ["name"], [
            enString$Elem(name)
            ]);
    #endif
    #ifndef ENINVENTORY$ENABLE_NC
        enLog$(DEBUG, "ENINVENTORY$ENABLE_NC not defined.");
        return;
    #endif
    _ENINVENTORY_NC_N = name;
    _ENINVENTORY_NC_L = -1;
    _ENINVENTORY_NC_T = -1;
    _ENINVENTORY_NC_G = llGetNumberOfNotecardLines(_ENINVENTORY_NC_N);
    key new_NC_K = llGetInventoryKey(_ENINVENTORY_NC_N);
    if (new_NC_K == NULL_KEY) return 0; // notecard doesn't exist
    if (new_NC_K == _ENINVENTORY_NC_K) return 0x1; // notecard opened, no changes since last opened
    _ENINVENTORY_NC_K = new_NC_K;
    return 0x3; // notecard opened, changes since last opened
}

enInventory$NCRead( // reads a line from the open notecard
    integer i // line number, starting from 0
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams("enInventory$NCRead", ["i"], [
            i
            ]);
    #endif
    #ifndef ENINVENTORY$ENABLE_NC
        enLog$(DEBUG, "ENINVENTORY$ENABLE_NC not defined.");
        return;
    #else
        _ENINVENTORY_NC_L = i;
        string s = NAK;
        if (llGetFreeMemory() > 4096 && _ENINVENTORY_NC_T > 0) s = llGetNotecardLineSync(_ENINVENTORY_NC_N, i); // attempt sync read if at least 2k of memory free and the llGetNumberOfNotecardLines dataserver event resolved
        if (s == NAK) _ENINVENTORY_NC_H = llGetNotecardLine(_ENINVENTORY_NC_N, i); // sync read failed, do dataserver read
        else en$nc_line(_ENINVENTORY_NC_N, _ENINVENTORY_NC_L, _ENINVENTORY_NC_T, s);
    #endif
}

integer _enInventory$NCParse(
    string query,
    string data
    )
{
    if (query == _ENINVENTORY_NC_H)
    {
        en$nc_line(_ENINVENTORY_NC_N, _ENINVENTORY_NC_L, _ENINVENTORY_NC_T, data);
        return 1;
    }
    if (query == _ENINVENTORY_NC_G)
    {
        _ENINVENTORY_NC_T = (integer)data;
        return 1;
    }
    return 0;
}

string enInventory$TypeToString( // converts an INVENTORY_* flag into a string (use "INVENTORY_" + llToUpper(enInventory$TypeToString(...)) to get actual flag name)
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
    if (i == -1) return "Unknown"; // return "Unknown" for a flag that is not known by enInventory at compile time
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

enInventory$Push( // pushes an inventory item via enCLEP
    string prim,
    string domain,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams("enInventory$Push", ["prim", "domain", "name", "type", "pin", "run", "param"], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(name),
            type,
            pin,
            run,
            param
            ]);
    #endif
    // TODO
}

enInventory$Pull( // pulls an inventory item via enCLEP
    string prim,
    string domain,
    string name,
    integer type,
    integer pin,
    integer run,
    integer param
    )
{
    #ifdef ENINVENTORY$TRACE
        enLog$TraceParams("enInventory$Pull", ["prim", "domain", "name", "type", "pin", "run", "param"], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(name),
            type,
            pin,
            run,
            param
            ]);
    #endif
    // TODO
}
