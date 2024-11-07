/*
    XiVector.lsl
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
#define XIVECTOR_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

#define XiVector$ToString(...) _XiVector_ToString( __VA_ARGS__ )
string XiVector$ToString( // removes the < & > from a vector and rounds each element, good for displaying positions
    vector pos,
    integer digits
    )
{
    return XiFloat$ToString(pos.x, digits) + ", " + XiFloat$ToString(pos.y, digits) + ", " + XiFloat$ToString(pos.z, digits);
}

#define XiVector$WorldToCorner(...) _XiVector_WorldToCorner( __VA_ARGS__ )
vector XiVector$WorldToCorner( // converts a world pos to a region CORNER
    vector world
    )
{
    // TODO
}

#define XiVector$WorldToRegion(...) _XiVector_WorldToRegion( __VA_ARGS__ )
vector XiVector$WorldToRegion( // converts a world pos to a region POSITION, as in a position within a region
    vector world
    )
{
    // TODO
}

#define XiVector$RegionToWorld(...) _XiVector_RegionToWorld( __VA_ARGS__ )
vector XiVector$RegionToWorld( // converts the current region position to world position
    vector region
    )
{
    return XiVector$RegionCornerToWorld( region, llGetRegionCorner() );
}

#define XiVector$RegionCornerToWorld(...) _XiVector_RegionCornerToWorld( __VA_ARGS__ )
vector XiVector$RegionCornerToWorld( // converts a region CORNER and POSITION to a world pos
    vector region,
    vector corner
    )
{
    // TODO
}

// TODO: local pos conversion stuff, pos from root with rot, all sorts of stuff
