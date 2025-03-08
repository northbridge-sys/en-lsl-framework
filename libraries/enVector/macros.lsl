/*
enVector.lsl
Library Macros
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

// converts a world-scope position to a region-scope position, as in a position within a region
#define enVector_WorldToRegion(world_position) \
    (world - enVector_WorldToCorner(world_position))

// converts the current region-scope position to world-scope position
#define enVector_RegionToWorld(region_position) \
    enVector_RegionCornerToWorld(region_position, llGetRegionCorner())

// converts a region CORNER and POSITION to a world-scope position
#define enVector_RegionCornerToWorld(region_position, region_corner) \
    (region_position + region_corner)
