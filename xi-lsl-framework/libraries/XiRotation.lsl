/*
    XiRotation.lsl
    Library
    Xi LSL Framework
    Revision 0
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

    TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XIROTATION_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

rotation XiRotation_Normalize(
    rotation r
    )
{
    float m = 1 / llSqrt( r.x * r.x + r.y * r.y + r.z * r.z + r.s * r.s ); // normalize
    return < r.x * m, r.y * m, r.z * m, r.s * m >;
}

rotation XiRotation_Slerp(
    rotation a,
    rotation b,
    float t
    )
{
    return llAxisAngle2Rot( llRot2Axis( b /= a ), t * llRot2Angle( b ) ) * a;
}

rotation XiRotation_Nlerp(
    rotation a,
    rotation b,
    float t
{
    float ti = 1 - t;
    rotation r = < a.x * ti, a.y * ti, a.z * ti, a.s * ti > + < b.x * t, b.y * t, b.z * t, b.s * t >;
    return XiRotation_Normalize( r );
}
