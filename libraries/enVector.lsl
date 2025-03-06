/*
    enVector.lsl
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

    This library provides helper functions for manipulation of vectors.
*/

// ==
// == macros
// ==

// converts a world pos to a region POSITION, as in a position within a region
#define enVector_WorldToRegion(world_position) \
    (world - enVector_WorldToCorner(world_position))

// converts the current region position to world position
#define enVector_RegionToWorld(region_position) \
    enVector_RegionCornerToWorld(region_position, llGetRegionCorner())

// converts a region CORNER and POSITION to a world pos
#define enVector_RegionCornerToWorld(region_position, region_corner) \
    (region_position + region_corner)

// ==
// == functions
// ==

// typecasting

string enVector_ToString( // removes the < & > from a vector and rounds each element, good for displaying positions
    vector pos,
    integer digits
    )
{
    return enFloat_ToString(pos.x, digits) + ", " + enFloat_ToString(pos.y, digits) + ", " + enFloat_ToString(pos.z, digits);
}

vector enVector_FromString( // converts a string to a vector while being a little loose with what counts as a vector (all spaces removed, brackets optional)
    string s
)
{
    s = llStringTrim(llReplaceSubString(s, " ", "", 0), STRING_TRIM); // remove all spaces, then trim to clean off any stray newlines
    if (llGetSubString(s, 0, 0) == "<") s = llDeleteSubString(s, 0, 0);
    if (llGetSubString(s, -1, -1) == ">") s = llDeleteSubString(s, -1, -1);
    list l = llParseStringKeepNulls(s, [","], []);
    if (llGetListLength(l) != 3) return ZERO_VECTOR;
    return <(float)llList2String(l, 0), (float)llList2String(l, 1), (float)llList2String(l, 2)>;
}

string enVector_Compress( // converts a vector to a Base64 string, can be converted back with enVector_Decompress
    vector v
)
{
    return enFloat_Compress(v.x) + enFloat_Compress(v.y) + enFloat_Compress(v.z);
}

vector enVector_Decompress( // converts the string result from enVector_Compress back to a vector
    string s
)
{
    return <enFloat_Decompress(llGetSubString(s, 0, 5)), enFloat_Decompress(llGetSubString(s, 6, 11)), enFloat_Decompress(llGetSubString(s, 12, 17))>;
}

// position scope translation
// NOTE: these are mostly just here for reference, it is more efficient to hardcode these calculations than waste memory on "add two vectors"

vector enVector_WorldToCorner( // converts a world pos to a region CORNER
    vector world
    )
{
    return <(integer)(world.x / 256.0) * 256, (integer)(world.y / 256.0) * 256, 0.0>;
}

// TODO: local pos conversion stuff, pos from root with rot, all sorts of stuff

// manipulation

vector enVector_Scale( // scales a vector by multiplying with each element of another vector
    vector a,
    vector b
)
{
    return <a.x * b.x, a.y * b.y, a.z * b.z>;
}

vector enVector_ScaleInverse( // scales a vector by dividing by each element of another vector
    vector a,
    vector b
)
{
    return <a.x / b.x, a.y / b.y, a.z / b.z>;
}

/*
    used to normalize offsets used primarily for speculars/normals, which don't gracefully handle negative offsets
*/
vector enVector_NormalizeOffset(vector v)
{
    while (v.x < 0.0) v.x += 1.0;
    while (v.y < 0.0) v.y += 1.0;
    return v;
}
