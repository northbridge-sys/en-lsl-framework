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

#define FLAG_ENOBJECT_PROFILE_EXISTS 0x80000000
#define FLAG_ENOBJECT_PROFILE_PHYSICS 0x1
#define FLAG_ENOBJECT_PROFILE_PHANTOM 0x2
#define FLAG_ENOBJECT_PROFILE_TEMP_ON_REZ 0x4
#define FLAG_ENOBJECT_PROFILE_TEMP_ATTACHED 0x8

#define FLAG_ENOBJECT_TEXT_SUCCESS 0x10
#define FLAG_ENOBJECT_TEXT_BUSY 0x20
#define FLAG_ENOBJECT_TEXT_PROMPT 0x40
#define FLAG_ENOBJECT_TEXT_ERROR 0x80
#define FLAG_ENOBJECT_TEXT_TEMP 0x100
#define FLAG_ENOBJECT_TEXT_PROGRESS_NC 0x200
#define FLAG_ENOBJECT_TEXT_PROGRESS_THROB 0x400

#define FLAG_ENOBJECT_VM_LSO -1
#define FLAG_ENOBJECT_VM_MONO 1

#ifndef OVERRIDE_ENOBJECT_LIMIT_SELF
    // number of own object UUIDs to store, retrievable via enObject_Self
    #define OVERRIDE_ENOBJECT_LIMIT_SELF 2
#endif

#if defined TRACE_EN
    #define TRACE_ENOBJECT
#endif

#if defined FEATURE_ENOBJECT_ENABLE_SELF
    list _ENOBJECT_UUIDS_SELF;
#endif

#if defined FEATURE_ENOBJECT_ENABLE_LINK_CACHE
    list _ENOBJECT_LINK_CACHE; // prim name, current linknum, max distance
    #define _ENOBJECT_LINK_CACHE_STRIDE 3
#endif

#define enObject_GetLinkColor(link,face) \
    (vector)llList2String(llGetLinkPrimitiveParams(link, [PRIM_COLOR, face]), 0)

#define enObject_GetLinkAlpha(link,face) \
    (float)llList2String(llGetLinkPrimitiveParams(link, [PRIM_COLOR, face]), 1)

//  gets UUID of entity that rezzed the object
#define enObject_Parent() \
    llList2String(llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]), 0)

// gets UUID of root prim in linkset
// if llGetNumberOfPrims() is...
//  1 (unlinked object): index is !(1-1)=!!(0)=0, return llGetLinkKey(0)
//  2+ (linked object): index is !(2-1)=!!(1)=1, reutrn llGetLinkKey(1)
// this is required because llGetLinkKey requires 0 for root in unlinked objects and 1 in linked objects
#define enObject_Root() \
    llGetLinkKey(!!(llGetNumberOfPrims() - 1))

//  returns either own object's current UUID or one of its previous UUIDs
#define enObject_Self(i) \
    llList2String(_ENOBJECT_UUIDS_SELF, i)

#define enObject_StopIfOwnerRezzed() \
    if (enObject_Parent() == (string)llGetKey()) enLog_FatalStop("enObject_StopIfOwnerRezzed() triggered.")

#define enObject_StopIfFlagged() \
    if ((integer)llLinksetDataRead("stop")) enLog_FatalStop("enObject_StopIfFlagged() triggered.")

// gets the current object's world position
#define enObject_MyWorldPos() \
    enVector_RegionToWorld(llGetPos())

// gets the root prim's world position
#define enObject_RootWorldPos() \
    enVector_RegionToWorld(llGetRootPosition())

// gets another object's world position (same region only), or avatar within the avatar detection range of llGetObjectDetails
// for objects outside that range with known positions, you'll have to do this yourself using enVector_RegionCornerToWorld
// you'll want to first add some sort of validation that the key is in the region, otherwise this just returns the region corner (maybe check for that and hope for the best?)
#define enObject_WorldPos(object_or_avatar_uuid) \
    enVector_RegionToWorld(llList2Vector(llGetObjectDetails(object_or_avatar_uuid, [OBJECT_POS]), 0))
