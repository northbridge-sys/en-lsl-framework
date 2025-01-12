 /*
    enObject.lsl
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

    This script exposes the enObject_* functions and ENOBJECT_* globals, which allows code
    to monitor metadata about the prim and linkset that the script is in, and get
    information about other prims.
*/

// ==
// == macros
// ==

#define enObject_StopIfOwnerRezzed() \
    if (enObject_Parent() == (string)llGetKey()) enLog_(FATAL, __LINE__, "enObject_StopIfOwnerRezzed()")

#define enObject_StopIfFlagged() \
    if ((integer)llLinksetDataRead("stop")) enLog_(FATAL, __LINE__, "enObject_StopIfFlagged()")

// ==
// == globals
// ==

list _ENOBJECT_UUIDS_SELF;

#ifdef ENOBJECT_ENABLE_LINK_CACHE
    list _ENOBJECT_LINK_CACHE; // prim name, current linknum
    #define _ENOBJECT_LINK_CACHE_STRIDE 2
#endif

// ==
// == macros
// ==

#define enObject_GetLinkColor(link,face) \
    (vector)llList2String(llGetLinkPrimitiveParams(link, [PRIM_COLOR, face]), 0)

// ==
// == functions
// ==

string enObject_Elem( string id )
{
    list details = llGetObjectDetails( id, [ OBJECT_NAME, OBJECT_POS ] );
    if ( details == [] ) return "\"" + id + "\" (not in region)";
    return "\"" + id + "\" (\"" + llList2String( details, 0 ) + "\" at " + enVector_ToString( (vector)llList2String( details, 1 ), 3 ) + ")";
}

string enObject_Self( // returns either own object's current UUID or one of its previous UUIDs
    integer last
    )
{
    return llList2String( _ENOBJECT_UUIDS_SELF, last );
}

string enObject_Parent() // gets UUID of entity that rezzed the object
{
    return llList2String( llGetObjectDetails( llGetKey(), [ OBJECT_REZZER_KEY ] ), 0);
}

integer enObject_ClosestLinkDesc(
    string desc
)
{
    #ifdef ENOBJECT_TRACE
        enLog_TraceParams("enObject_ClosestLinkDesc", ["desc"], [
            enString_Elem(desc)
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

integer enObject_ClosestLink(string name)
{ // finds the linknum of the closest prim in the linkset with the specified name
    #ifdef ENOBJECT_TRACE
        enLog_TraceParams("enObject_ClosestLink", ["name"], [
            enString_Elem(name)
            ]);
    #endif
    #ifdef ENOBJECT_ENABLE_LINK_CACHE
        integer i = llListFindList(llList2ListSlice(_ENOBJECT_LINK_CACHE, 0, -1, _ENOBJECT_LINK_CACHE_STRIDE, 0), [name]);
        if (i != -1) return (integer)llList2String(_ENOBJECT_LINK_CACHE, i * _ENOBJECT_LINK_CACHE_STRIDE + 1); // return cached linknum
    #endif
    return enObject_FindLink(name);
}

integer enObject_FindLink(string name)
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

integer enObject_CacheClosestLink(
    string name
)
{
    #ifndef ENOBJECT_ENABLE_LINK_CACHE
        enLog_Error("enObject_CacheClosestLink called but ENOBJECT_ENABLE_LINK_CACHE not defined.");
        return 0;
    #else
        integer i = llListFindList(llList2ListSlice(_ENOBJECT_LINK_CACHE, 0, -1, _ENOBJECT_LINK_CACHE_STRIDE, 0), [name]);
        if (i != -1) return (integer)llList2String(_ENOBJECT_LINK_CACHE, i * _ENOBJECT_LINK_CACHE_STRIDE + 1); // already caching
        _ENOBJECT_LINK_CACHE += [name, enObject_FindLink(name)];
        return (integer)llList2String(_ENOBJECT_LINK_CACHE, -1); // return last element, since it is always ours
    #endif
}

enObject_LinkCacheUpdate()
{
    integer i;
    integer l = llGetListLength(_ENOBJECT_LINK_CACHE);
    for (i = 0; i < l; i+=2)
    {
        _ENOBJECT_LINK_CACHE = llListReplaceList(_ENOBJECT_LINK_CACHE, [enObject_FindLink(llList2String(_ENOBJECT_LINK_CACHE, i))], i + 1, i + 1);
    }
}

enObject_Text(
    integer flags,
    list lines
)
{
    vector color = WHITE;
    string icon = "";
    if (flags & ENOBJECT_TEXT_PROMPT)
    {
        color = YELLOW;
        icon = "🚩";
    }
    else if (flags & ENOBJECT_TEXT_ERROR)
    {
        color = RED;
        icon = "❌";
    }
    else if (flags & ENOBJECT_TEXT_BUSY)
    {
        color = BLUE;
        integer ind = (enDate_MSNow() / 83) % 12; // approenmately +1 ind every 1/12th of a second
        icon = llList2String(["🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"], ind);
    }
    else if (flags & ENOBJECT_TEXT_SUCCESS)
    {
        color = GREEN;
        icon = "✅";
    }
    if (flags & 0x7)
    { // a enLog level was passed in as a flag as well, so use its icon
        icon = llList2String(["", "🛑", "❌", "🚩", "💬", "🪲", "🚦"], flags & 0x7);
    }
    string progress = "▼";
    if (flags & ENOBJECT_TEXT_PROGRESS_NC)
    {
        integer ind = llRound(((float)_ENINVENTORY_NC_L / _ENINVENTORY_NC_T) * 16);
        if (_ENINVENTORY_NC_T > 0) progress = llGetSubString("████████████████▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁", 16 - ind, 31 - ind); // such a lazy hack!! who cares
    }
    if (flags & ENOBJECT_TEXT_PROGRESS_THROB)
    {
        integer ind = (enDate_MSNow() / 62) % 16; // approenmately +1 ind every 1/16th of a second
        progress = llGetSubString("▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▂▃▄▅▆▇█▇▆▅▄▃▂▁", ind, ind + 15);
    }
                                                                                           // this is a nbsp
    llSetText(llDumpList2String([icon] + enList_Reverse(enList_ReplaceExact(lines, [""], [" "])) + [progress], "\n"), color, 1.0);
    #ifdef ENTIMER_ENABLE
        if (flags & ENOBJECT_TEXT_TEMP) enTimer_Start(2.0, 0, "enObject_TextTemp");
        else enTimer_Cancel(enTimer_Find("enObject_TextTemp"));
    #endif
}

enObject_TextTemp()
{
    llSetText("", BLACK, 0.0);
}

string enObject_GetAttachedString(
    integer i
    )
{
    return llList2String([
        "(not attached)",
        "Chest",
        "Skull",
        "Left Shoulder",
        "Right Shoulder",
        "Left Hand",
        "Right Hand",
        "Left Foot",
        "Right Foot",
        "Spine",
        "Pelvis",
        "Mouth",
        "Chin",
        "Left Ear",
        "Right Ear",
        "Left Eye",
        "Right Eye",
        "Nose",
        "R Upper Arm",
        "R Lower Arm",
        "L Upper Arm",
        "L Lower Arm",
        "Right Hip",
        "R Upper Leg",
        "R Lower Leg",
        "Left Hip",
        "L Upper Leg",
        "L LOwer Leg",
        "Stomach",
        "Left Pec",
        "Right Pec",
        "HUD Center 2",
        "HUD Top Right",
        "HUD Top",
        "HUD Top Left",
        "HUD Center",
        "HUD Bottom Left",
        "HUD Bottom",
        "HUD Bottom Right",
        "Neck",
        "Avatar Center",
        "Left Ring Finger",
        "Right Ring Finger",
        "Tail Base",
        "Tail Tip",
        "Left Wing",
        "Right Wing",
        "Jaw",
        "Alt Left Ear",
        "Alt Right Ear",
        "Alt Left Eye",
        "Alt Right Eye",
        "Tongue",
        "Groin",
        "Left Hind Foot",
        "Right Hind Foot"
        ], i);
}

integer enObject_Profile( // returns various bitwise flags for the state of an object
    string k
    )
{
    list l = llGetObjectDetails(k, [OBJECT_PHYSICS, OBJECT_PHANTOM, OBJECT_TEMP_ON_REZ, OBJECT_TEMP_ATTACHED]);
    if (l == []) return 0;
    integer f = ENOBJECT_PROFILE_EXISTS;
    if ((integer)llList2String(l, 0)) f += ENOBJECT_PROFILE_PHYSICS;
    if ((integer)llList2String(l, 1)) f += ENOBJECT_PROFILE_PHANTOM;
    if ((integer)llList2String(l, 2)) f += ENOBJECT_PROFILE_TEMP_ON_REZ;
    if ((integer)llList2String(l, 3)) f += ENOBJECT_PROFILE_TEMP_ATTACHED;
    return f;
}

enObject_UpdateUUIDs()
{
    #ifdef ENOBJECT_TRACE
        enLog_TraceParams("enObject_UpdateUUIDs", [], []);
    #endif
	if (ENOBJECT_LIMIT_SELF)
	{ // check own UUID
		if ((string)llGetKey() != llList2String(_ENOBJECT_UUIDS_SELF, 0))
		{ // key change
			_ENOBJECT_UUIDS_SELF = llList2List([(string)llGetKey()] + _ENOBJECT_UUIDS_SELF, 0, ENOBJECT_LIMIT_SELF - 1);
		}
	}
}
