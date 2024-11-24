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

    This library provides helper functions for manipulation of vectors.
*/

// ==
// == globals
// ==

// ==
// == functions
// ==

// typecasting

string XiVector$ToString( // removes the < & > from a vector and rounds each element, good for displaying positions
    vector pos,
    integer digits
    )
{
    return XiFloat$ToString(pos.x, digits) + ", " + XiFloat$ToString(pos.y, digits) + ", " + XiFloat$ToString(pos.z, digits);
}

// position scope translation

vector XiVector$WorldToCorner( // converts a world pos to a region CORNER
    vector world
    )
{
    // TODO
}

vector XiVector$WorldToRegion( // converts a world pos to a region POSITION, as in a position within a region
    vector world
    )
{
    // TODO
}

vector XiVector$RegionToWorld( // converts the current region position to world position
    vector region
    )
{
    return XiVector$RegionCornerToWorld( region, llGetRegionCorner() );
}

vector XiVector$RegionCornerToWorld( // converts a region CORNER and POSITION to a world pos
    vector region,
    vector corner
    )
{
    // TODO
}

// TODO: local pos conversion stuff, pos from root with rot, all sorts of stuff

// manipulation

string XiVector$Scale( // scales a vector by multiplying with each element of another vector
    vector a,
    vector b
)
{
    return <a.x * b.x, a.y * b.y, a.z * b.z>;
}

string XiVector$ScaleInverse( // scales a vector by dividing by each element of another vector
    vector a,
    vector b
)
{
    return <a.x / b.x, a.y / b.y, a.z / b.z>;
}
