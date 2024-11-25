 /*
    XiObject.lsl
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

    This script exposes the XiObject$* functions and XIOBJECT$* globals, which allows code
    to monitor metadata about the prim and linkset that the script is in, and get
    information about other prims.
*/

// ==
// == globals
// ==

list _XIOBJECT_UUIDS_SELF;

#ifdef XIOBJECT$ENABLE_LINK_CACHE
    list _XIOBJECT_LINK_CACHE; // prim name, current linknum
    #define _XIOBJECT_LINK_CACHE_STRIDE 2
#endif

// ==
// == functions
// ==

string XiObject$Elem( string id )
{
    list details = llGetObjectDetails( id, [ OBJECT_NAME, OBJECT_POS ] );
    if ( details == [] ) return "\"" + id + "\" (not in region)";
    return "\"" + id + "\" (\"" + llList2String( details, 0 ) + "\" at " + XiVector$ToString( (vector)llList2String( details, 1 ), 3 ) + ")";
}

string XiObject$Self( // returns either own object's current UUID or one of its previous UUIDs
    integer last
    )
{
    return llList2String( _XIOBJECT_UUIDS_SELF, last );
}

string XiObject$Parent() // gets UUID of entity that rezzed the object
{
    return llList2String( llGetObjectDetails( llGetKey(), [ OBJECT_REZZER_KEY ] ), 0);
}

XiObject$StopIfOwnerRezzed()
{ // TODO: move this to a definition macro that runs automatically on_rez
    if ( XiObject$Parent() == (string)llGetKey() ) XiLog$Fatal( "XiObject$StopIfOwnerRezzed()" );
}

integer XiObject$ClosestLinkDesc(
    string desc
)
{
    #ifdef XIOBJECT$TRACE
        XiLog$TraceParams("XiObject$ClosestLinkDesc", ["desc"], [
            XiString$Elem(desc)
            ]);
    #endif
    integer i;
    integer cl_i;
    float cl_dist = -1.0;
    for (i = 1; i <= llGetNumberOfPrims(); i++)
    { // iterate through each prim
        if (llGetSubString(llList2String(llGetObjectDetails(llGetLinkKey(i), [OBJECT_DESC]), 0), -llStringLength(desc), -1) == desc)
        { // start of desc match
			float dist = llVecDist(llGetPos(), llList2Vector(llGetLinkPrimitiveParams(i, [PRIM_POSITION]), 0));
			if (cl_dist < 0.0 || dist < cl_dist)
			{ // closet so far
				cl_i = i;
				cl_dist = dist;
			}
        }
    }
    if (cl_i) return cl_i; // match
    return 0; // no match
}

integer XiObject$ClosestLink(string name)
{ // finds the linknum of the closest prim in the linkset with the specified name
    #ifdef XIOBJECT$TRACE
        XiLog$TraceParams("XiObject$ClosestLink", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
    integer i = llListFindList(llList2ListSlice(_XIOBJECT_LINK_CACHE, 0, -1, _XIOBJECT_LINK_CACHE_STRIDE, 0), [name]);
    if (i != -1) return (integer)llList2String(_XIOBJECT_LINK_CACHE, i + 1); // return cached linknum
    return _XiObject$FindLink(name);
}

integer _XiObject$FindLink(string name)
{
    integer i;
    integer cl_i;
    float cl_dist = -1.0;
    for (i = 1; i <= llGetNumberOfPrims(); i++)
    { // iterate through each prim
        if (llGetLinkName(i) == name)
        { // name match
			float dist = llVecDist(llGetPos(), llList2Vector(llGetLinkPrimitiveParams(i, [PRIM_POSITION]), 0));
			if (cl_dist < 0.0 || dist < cl_dist)
			{ // closet so far
				cl_i = i;
				cl_dist = dist;
			}
        }
    }
    if (cl_i) return cl_i; // match
    return 0; // no match
}

XiObject$CacheClosestLink(
    string name
)
{
    #ifndef XIOBJECT$ENABLE_LINK_CACHE
        XiLog$Error("XiObject$CacheClosestLink called but XIOBJECT$ENABLE_LINK_CACHE not defined.");
    #else
        if (llListFindList(llList2ListSlice(_XIOBJECT_LINK_CACHE, 0, -1, _XIOBJECT_LINK_CACHE_STRIDE, 0), [name]) != -1) return; // already caching
        _XIOBJECT_LINK_CACHE += [name, _XiObject$FindLink(name)];
    #endif
}

_XiObject$LinkCacheUpdate()
{
    integer i;
    integer l = llGetListLength(_XIOBJECT_LINK_CACHE);
    for (i = 0; i < l; i+=2)
    {
        _XIOBJECT_LINK_CACHE = llListReplaceList(_XIOBJECT_LINK_CACHE, [_XiObject$FindLink(llList2String(_XIOBJECT_LINK_CACHE, i))], i + 1, i + 1);
    }
}

XiObject$Text(
    integer flags,
    list lines
)
{
    vector color = WHITE;
    string icon = "";
    if (flags & XIOBJECT$TEXT_PROMPT)
    {
        color = YELLOW;
        icon = "🚩";
    }
    else if (flags & XIOBJECT$TEXT_ERROR)
    {
        color = RED;
        icon = "❌";
    }
    else if (flags & XIOBJECT$TEXT_BUSY)
    {
        color = BLUE;
        integer ind = (XiDate$MSNow() / 83) % 12; // approximately +1 ind every 1/12th of a second
        icon = llList2String(["🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"], ind);
    }
    else if (flags & XIOBJECT$TEXT_SUCCESS)
    {
        color = GREEN;
        icon = "✅";
    }
    if (flags & 0x7)
    { // a XiLog level was passed in as a flag as well, so use its icon
        icon = llList2String(["", "🛑", "❌", "🚩", "💬", "🪲", "🚦"], flags & 0x7);
    }
    string progress = "▼";
    if (flags & XIOBJECT$TEXT_PROGRESS_NC)
    {
        integer ind = llRound(((float)_XIINVENTORY_NC_L / _XIINVENTORY_NC_T) * 16);
        if (_XIINVENTORY_NC_T > 0) progress = llGetSubString("████████████████▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁", 16 - ind, 31 - ind); // such a lazy hack!! who cares
    }
    if (flags & XIOBJECT$TEXT_PROGRESS_THROB)
    {
        integer ind = (XiDate$MSNow() / 62) % 16; // approximately +1 ind every 1/16th of a second
        progress = llGetSubString("▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▂▃▄▅▆▇█▇▆▅▄▃▂▁", ind, ind + 15);
    }
    llSetText(llDumpList2String(XiList$Reverse(lines) + [progress, "❘", icon, "❘"], "\n"), color, 1.0);
    if (flags & XIOBJECT$TEXT_TEMP) XiTimer$Start(2.0, 0, "_XiObject$TextTemp");
    else XiTimer$Cancel(XiTimer$Find("_XiObject$TextTemp"));
}

_XiObject$TextTemp()
{
    llSetText("", BLACK, 0.0);
}

integer XiObject$Profile( // returns various bitwise flags for the state of an object
    string k
    )
{
    list l = llGetObjectDetails(k, [OBJECT_PHYSICS, OBJECT_PHANTOM, OBJECT_TEMP_ON_REZ, OBJECT_TEMP_ATTACHED]);
    if (l == []) return 0;
    integer f = XIOBJECT$PROFILE_EXISTS;
    if ((integer)llList2String(l, 0)) f += XIOBJECT$PROFILE_PHYSICS;
    if ((integer)llList2String(l, 1)) f += XIOBJECT$PROFILE_PHANTOM;
    if ((integer)llList2String(l, 2)) f += XIOBJECT$PROFILE_TEMP_ON_REZ;
    if ((integer)llList2String(l, 3)) f += XIOBJECT$PROFILE_TEMP_ATTACHED;
    return f;
}

_XiObject$UpdateUUIDs()
{
    #ifdef XIOBJECT$TRACE
        XiLog$TraceParams("_XiObject$UpdateUUIDs", [], []);
    #endif
	if (XIOBJECT$LIMIT_SELF)
	{ // check own UUID
		if ((string)llGetKey() != llList2String(_XIOBJECT_UUIDS_SELF, 0))
		{ // key change
			_XIOBJECT_UUIDS_SELF = llList2List([(string)llGetKey()] + _XIOBJECT_UUIDS_SELF, 0, XIOBJECT$LIMIT_SELF - 1);
		}
	}
}
