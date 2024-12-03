/*
    enRotation.lsl
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

// ==
// == functions
// ==

string enRotation$Elem( rotation r )
{
    return (string)r + " (" + (string)llRot2Euler( r ) + ")";
}

rotation enRotation$Normalize(
    rotation r
    )
{
    float m = 1 / llSqrt( r.x * r.x + r.y * r.y + r.z * r.z + r.s * r.s ); // normalize
    return < r.x * m, r.y * m, r.z * m, r.s * m >;
}

rotation enRotation$Slerp(
    rotation a,
    rotation b,
    float t
    )
{
    return llAxisAngle2Rot( llRot2Axis( b /= a ), t * llRot2Angle( b ) ) * a;
}

rotation enRotation$Nlerp(
    rotation a,
    rotation b,
    float t
)
{
    float ti = 1 - t;
    rotation r = < a.x * ti, a.y * ti, a.z * ti, a.s * ti > + < b.x * t, b.y * t, b.z * t, b.s * t >;
    return enRotation$Normalize( r );
}

string enRotation$Compress( // converts a rotation to a Base64 string, can be converted back with enRotation$Decompress
    rotation r
)
{
    return enFloat$Compress(r.x) + enFloat$Compress(r.y) + enFloat$Compress(r.z) + enFloat$Compress(r.s);
}

rotation enRotation$Decompress( // converts the string result from enRotation$Compress back to a rotation
    string s
)
{
    return <enFloat$Decompress(llGetSubString(s, 0, 5)), enFloat$Decompress(llGetSubString(s, 6, 11)), enFloat$Decompress(llGetSubString(s, 12, 17)), enFloat$Decompress(llGetSubString(s, 18, 23))>;
}

vector enRotation$FromString( // converts a string to a rotation while being a little loose with what counts as a rotation (all spaces removed, brackets optional, automatic translation from vector)
    string s,
    integer use_degrees // set TRUE if you want llEuler2Rot translation to presume a vector in degrees instead of radians
)
{
    s = llStringTrim(llReplaceSubString(s, " ", "", 0), STRING_TRIM); // remove all spaces, then trim to clean off any stray newlines
    if (llGetSubString(s, 0, 0) == "<") s = llDeleteSubString(s, 0, 0);
    if (llGetSubString(s, -1, -1) == ">") s = llDeleteSubString(s, -1, -1);
    list l = llParseStringKeepNulls(s, [","], []);
    if (llGetListLength(l) == 3) return llEuler2Rot(<(float)llList2String(l, 0), (float)llList2String(l, 1), (float)llList2String(l, 2)> * (1.0 + use_degrees * (DEG_TO_RAD - 1)));
    if (llGetListLength(l) != 4) return ZERO_ROTATION;
    return <(float)llList2String(l, 0), (float)llList2String(l, 1), (float)llList2String(l, 2), (float)llList2String(l, 3)>;
}
