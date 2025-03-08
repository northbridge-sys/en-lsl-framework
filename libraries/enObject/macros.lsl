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
*/

list _ENOBJECT_UUIDS_SELF;

#if defined ENOBJECT_ENABLE_LINK_CACHE
    list _ENOBJECT_LINK_CACHE; // prim name, current linknum, max distance
    #define _ENOBJECT_LINK_CACHE_STRIDE 3
#endif

#define enObject_GetLinkColor(link,face) \
    (vector)llList2String(llGetLinkPrimitiveParams(link, [PRIM_COLOR, face]), 0)

//  gets UUID of entity that rezzed the object
#define enObject_Parent() \
    llList2String(llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]), 0)

#define enObject_Root() \
    llList2String([llGetKey(), llGetLinkKey(1)], !(llGetNumberOfPrims() - 1))

//  returns either own object's current UUID or one of its previous UUIDs
#define enObject_Self(i) \
    llList2String(_ENOBJECT_UUIDS_SELF, i)

#define enObject_StopIfOwnerRezzed() \
    if (enObject_Parent() == (string)llGetKey()) enLog_FatalStop("enObject_StopIfOwnerRezzed() triggered.")

#define enObject_StopIfFlagged() \
    if ((integer)llLinksetDataRead("stop")) enLog_FatalStop("enObject_StopIfFlagged() triggered.")
