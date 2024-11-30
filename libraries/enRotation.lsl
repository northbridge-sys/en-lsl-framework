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
    return llAensAngle2Rot( llRot2Aens( b /= a ), t * llRot2Angle( b ) ) * a;
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
