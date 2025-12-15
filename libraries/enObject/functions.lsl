/*
enObject.lsl
Library Functions
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

string enObject_Elem( string id )
{
    list details = llGetObjectDetails( id, [ OBJECT_NAME, OBJECT_POS ] );
    if ( details == [] ) return "\"" + id + "\" (not in region)";
    return "\"" + id + "\" (\"" + llList2String( details, 0 ) + "\" at " + enVector_ToString( (vector)llList2String( details, 1 ), 3 ) + ")";
}

//  returns the linknum of a specified UUID if it is part of the same linkset, or -1 if it is not
string enObject_RelativeLinknum(
    string prim
)
{
    list l = llGetObjectDetails(prim, [OBJECT_LINK_NUMBER]); // first, attempt to get the linknum of the prim within its linkset
    if (l == []) return -1; // prim doesn't exist
    if (llGetLinkKey((integer)llList2String(l, 0)) == prim) return (integer)llList2String(l, 0); // if the UUID of the linknum within our OWN linkset matches the one passed in, it is part of our linkset
    return -1; // otherwise, it is not part of our linkset
}

integer enObject_ClosestLinkDesc(
    string desc
)
{
    #if defined TRACE_ENOBJECT
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

//  finds the linknum of the closest prim in the linkset with the specified name
integer enObject_ClosestLink(string name)
{
    #if defined TRACE_ENOBJECT
        enLog_TraceParams("enObject_ClosestLink", ["name"], [
            enString_Elem(name)
            ]);
    #endif
    #if defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE
        integer i = llListFindList(llList2ListSlice(_ENOBJECT_LINK_CACHE, 0, -1, _ENOBJECT_LINK_CACHE_STRIDE, 0), [name]);
        if (~i) return (integer)llList2String(_ENOBJECT_LINK_CACHE, i * _ENOBJECT_LINK_CACHE_STRIDE + 1);  // != -1; return cached linknum
    #endif
    return enObject_FindLink(-1.0, name);
}

integer enObject_FindLink(float max_dist, string name)
{
    integer i;
    integer cl_i;
    float cl_dist = -1.0;
    for (i = 1; i <= llGetNumberOfPrims(); i++)
    { // iterate through each prim
        if (llGetLinkName(i) == name)
        { // name match
			float dist = llVecDist(llGetPos(), llList2Vector(llGetLinkPrimitiveParams(i, [PRIM_POSITION]), 0));
			if ((cl_dist < 0.0 || dist < cl_dist) && (max_dist <= 0.0 || dist <= max_dist))
			{ // closet so far, and within max distance
				cl_i = i;
				cl_dist = dist;
			}
        }
    }
    if (cl_i) return cl_i; // match
    return 0; // no match
}

integer enObject_CacheClosestLink(
    float max_dist,
    string name
)
{
    #ifndef FEATURE_ENOBJECT_ENABLE_LINK_CACHE
        enLog_Error("enObject_CacheClosestLink called but FEATURE_ENOBJECT_ENABLE_LINK_CACHE not defined");
        return 0;
    #else
        integer i = llListFindList(llList2ListSlice(_ENOBJECT_LINK_CACHE, 0, -1, _ENOBJECT_LINK_CACHE_STRIDE, 0), [name]);
        if (~i) return (integer)llList2String(_ENOBJECT_LINK_CACHE, i * _ENOBJECT_LINK_CACHE_STRIDE + 1);  // != -1; already caching
        _ENOBJECT_LINK_CACHE += [name, enObject_FindLink(max_dist, name), max_dist];
        return (integer)llList2String(_ENOBJECT_LINK_CACHE, -2); // return last element, since it is always ours
    #endif
}

enObject_LinkCacheUpdate()
{
    integer i;
    integer l = llGetListLength(_ENOBJECT_LINK_CACHE);
    for (i = 0; i < l; i += _ENOBJECT_LINK_CACHE_STRIDE)
    {
        _ENOBJECT_LINK_CACHE = llListReplaceList(_ENOBJECT_LINK_CACHE, [enObject_FindLink((float)llList2String(_ENOBJECT_LINK_CACHE, i + 2), llList2String(_ENOBJECT_LINK_CACHE, i))], i + 1, i + 1);
    }
}

enObject_Text(
    integer flags,
    list lines
)
{
    vector color = CONST_VECTOR_WHITE;
    string icon = "";
    if (flags & FLAG_ENOBJECT_TEXT_PROMPT)
    {
        color = CONST_VECTOR_YELLOW;
        icon = "🚩";
    }
    else if (flags & FLAG_ENOBJECT_TEXT_ERROR)
    {
        color = CONST_VECTOR_RED;
        icon = "❌";
    }
    else if (flags & FLAG_ENOBJECT_TEXT_BUSY)
    {
        color = CONST_VECTOR_BLUE;
        integer ind = (enDate_NowToMillisec() / 83) % 12; // approenmately +1 ind every 1/12th of a second
        icon = llList2String(["🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"], ind);
    }
    else if (flags & FLAG_ENOBJECT_TEXT_SUCCESS)
    {
        color = CONST_VECTOR_GREEN;
        icon = "✅";
    }
    if (flags & 0x7)
    { // a enLog level was passed in as a flag as well, so use its icon
        icon = llList2String(["", "🛑", "❌", "🚩", "💬", "🪲", "🚦"], flags & 0x7);
    }
    string progress = "▼";
    if (flags & FLAG_ENOBJECT_TEXT_PROGRESS_NC)
    {
        integer ind = llRound(((float)_ENINVENTORY_NC_L / _ENINVENTORY_NC_T) * 16);
        if (_ENINVENTORY_NC_T > 0) progress = llGetSubString("████████████████▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁", 16 - ind, 31 - ind); // such a lazy hack!! who cares
    }
    if (flags & FLAG_ENOBJECT_TEXT_PROGRESS_THROB)
    {
        integer ind = (enDate_NowToMillisec() / 62) % 16; // approenmately +1 ind every 1/16th of a second
        progress = llGetSubString("▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▂▃▄▅▆▇█▇▆▅▄▃▂▁", ind, ind + 15);
    }
                                                                                           // this is a nbsp
    llSetText(llDumpList2String([icon] + enList_Reverse(enList_ReplaceExact(lines, [""], [" "])) + [progress], "\n"), color, 1.0);
    #if defined EVENT_ENTIMER_TIMER
        if (flags & FLAG_ENOBJECT_TEXT_TEMP) enTimer_Start(2.0, 0, "enObject_TextClear");
        else enTimer_Cancel(enTimer_Find("enObject_TextClear"));
    #endif
}

enObject_TextClear()
{
    llSetText("", CONST_VECTOR_BLACK, 0.0);
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

// returns various bitwise flags for the state of an object
integer enObject_Profile(
    string k
    )
{
    list l = llGetObjectDetails(k, [OBJECT_PHYSICS, OBJECT_PHANTOM, OBJECT_TEMP_ON_REZ, OBJECT_TEMP_ATTACHED]);
    if (l == []) return 0;
    integer f = FLAG_ENOBJECT_PROFILE_EXISTS;
    if ((integer)llList2String(l, 0)) f += FLAG_ENOBJECT_PROFILE_PHYSICS;
    if ((integer)llList2String(l, 1)) f += FLAG_ENOBJECT_PROFILE_PHANTOM;
    if ((integer)llList2String(l, 2)) f += FLAG_ENOBJECT_PROFILE_TEMP_ON_REZ;
    if ((integer)llList2String(l, 3)) f += FLAG_ENOBJECT_PROFILE_TEMP_ATTACHED;
    return f;
}

enObject_UpdateUUIDs()
{
    #if defined TRACE_ENOBJECT
        enLog_TraceParams("enObject_UpdateUUIDs", [], []);
    #endif
	if (OVERRIDE_ENOBJECT_LIMIT_SELF)
	{ // check own UUID
		if ((string)llGetKey() != llList2String(_ENOBJECT_UUIDS_SELF, 0))
		{ // key change
			_ENOBJECT_UUIDS_SELF = llList2List([(string)llGetKey()] + _ENOBJECT_UUIDS_SELF, 0, OVERRIDE_ENOBJECT_LIMIT_SELF - 1);
		}
	}
}

/*
    runs on certain events when FEATURE_ENOBJECT_ALWAYS_PHANTOM is defined
    used for building components that should always be phantom
    can also be called independently without FEATURE_ENOBJECT_ALWAYS_PHANTOM if you only want to do this as a runtime option
*/
enObject_AlwaysPhantom()
{
    if (llGetLinkNumber() > 1) llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);
    else if (llGetLinkNumber()) enLog_Debug("FEATURE_ENOBJECT_ALWAYS_PHANTOM cannot be used in root prim of linkset");
    else llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHANTOM, TRUE]);
}

/*
detects the VM
courtesy of Pedro Oval via the LSL Portal
*/
enObject_VM()
{
    return ("" != "x");
}
