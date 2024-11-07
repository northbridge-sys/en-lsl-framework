/*
    XiRotation.lsl
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

    TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XIROTATION_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

#define XiRotation$Elem(...) _XiRotation_Elem( __VA_ARGS__ )
string XiRotation$Elem( rotation r )
{
    return (string)r + " (" + (string)llRot2Euler( r ) + ")";
}

#define XiRotation$Normalize(...) _XiRotation_Normalize( __VA_ARGS__ )
rotation XiRotation$Normalize(
    rotation r
    )
{
    float m = 1 / llSqrt( r.x * r.x + r.y * r.y + r.z * r.z + r.s * r.s ); // normalize
    return < r.x * m, r.y * m, r.z * m, r.s * m >;
}

#define XiRotation$Slerp(...) _XiRotation_Slerp( __VA_ARGS__ )
rotation XiRotation$Slerp(
    rotation a,
    rotation b,
    float t
    )
{
    return llAxisAngle2Rot( llRot2Axis( b /= a ), t * llRot2Angle( b ) ) * a;
}

#define XiRotation$Nlerp(...) _XiRotation_Nlerp( __VA_ARGS__ )
rotation XiRotation$Nlerp(
    rotation a,
    rotation b,
    float t
)
{
    float ti = 1 - t;
    rotation r = < a.x * ti, a.y * ti, a.z * ti, a.s * ti > + < b.x * t, b.y * t, b.z * t, b.s * t >;
    return XiRotation$Normalize( r );
}
