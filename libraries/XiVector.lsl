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

string XiVector_ToString( // removes the < & > from a vector and rounds each element, good for displaying positions
    vector pos,
    integer digits
    )
{
    return XiFloat_ToString(pos.x, digits) + ", " + XiFloat_ToString(pos.y, digits) + ", " + XiFloat_ToString(pos.z, digits);
}

vector XiVector_WorldToCorner( // converts a world pos to a region CORNER
    vector world
    )
{
    // TODO
}

vector XiVector_WorldToRegion( // converts a world pos to a region POSITION, as in a position within a region
    vector world
    )
{
    // TODO
}

vector XiVector_RegionToWorld( // converts the current region position to world position
    vector region
    )
{
    return XiVector_RegionCornerToWorld( region, llGetRegionCorner() );
}

vector XiVector_RegionCornerToWorld( // converts a region CORNER and POSITION to a world pos
    vector region,
    vector corner
    )
{
    // TODO
}

// TODO: local pos conversion stuff, pos from root with rot, all sorts of stuff
