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

integer XiObject$ClosestLink(string name)
{ // finds the linknum of the closest prim in the linkset with the specified name
    #ifdef XIOBJECT$TRACE
        XiLog$TraceParams("XiObject$ClosestLink", ["name"], [
            XiString$Elem(name)
            ]);
    #endif
    integer i;
    integer cl_i;
    float cl_dist = -1.0;
    list candidates = [];
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
