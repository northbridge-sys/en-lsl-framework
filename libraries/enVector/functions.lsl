/*
enVector.lsl
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

//  ==  TYPECASTING

//  removes the < & > from a vector and rounds each element, good for displaying positions
string enVector_ToString(
    vector pos,
    integer digits
    )
{
    return enFloat_ToString(pos.x, digits) + ", " + enFloat_ToString(pos.y, digits) + ", " + enFloat_ToString(pos.z, digits);
}

//  converts a string to a vector while being a little loose with what counts as a vector (all spaces removed, brackets optional)
vector enVector_FromString(
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

//  converts a vector to a Base64 string, can be converted back with enVector_Decompress
string enVector_Compress(
    vector v
)
{
    return enFloat_Compress(v.x) + enFloat_Compress(v.y) + enFloat_Compress(v.z);
}

//  converts the string result from enVector_Compress back to a vector
vector enVector_Decompress(
    string s
)
{
    return <enFloat_Decompress(llGetSubString(s, 0, 5)), enFloat_Decompress(llGetSubString(s, 6, 11)), enFloat_Decompress(llGetSubString(s, 12, 17))>;
}

//  ==  POSITION SCOPE TRANSLATION

//  converts a world pos to a region CORNER
//  can't be done as a macro because vector components can't be safely accessed on a macro parameter
vector enVector_WorldToCorner(
    vector world
    )
{
    return <(integer)(world.x / 256.0) * 256, (integer)(world.y / 256.0) * 256, 0.0>;
}

//  ==  MANIPULATION

//  scales a vector by multiplying with each element of another vector
vector enVector_Scale(
    vector a,
    vector b
)
{
    return <a.x * b.x, a.y * b.y, a.z * b.z>;
}

//  scales a vector by dividing by each element of another vector
vector enVector_ScaleInverse(
    vector a,
    vector b
)
{
    return <a.x / b.x, a.y / b.y, a.z / b.z>;
}

//  used to normalize offsets used primarily for speculars/normals, which don't gracefully handle negative offsets
vector enVector_NormalizeOffset(vector v)
{
    while (v.x < 0.0) v.x += 1.0;
    while (v.y < 0.0) v.y += 1.0;
    return v;
}
