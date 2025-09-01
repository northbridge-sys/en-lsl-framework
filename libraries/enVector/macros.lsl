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

#define RED <1.0, 0.25, 0.0>
#define ORANGE <1.0, 0.5, 0.0>
#define YELLOW <1.0, 0.8, 0.0>
#define GREEN <0.5, 1.0, 0.0>
#define BLUE <0.2, 0.8, 1.0>
#define PURPLE <0.5, 0.0, 1.0>
#define PINK <1.0, 0.0, 0.5>
#define WHITE <1.0, 1.0, 1.0>
#define BLACK <0.0, 0.0, 0.0>

#if defined EN_TRACE_LIBRARIES
    #define ENVECTOR_TRACE
#endif

// converts a world-scope position to a region-scope position, as in a position within a region
#define enVector_WorldToRegion(world_position) \
    (world_position - enVector_WorldToCorner(world_position))

// converts the current region-scope position to world-scope position
#define enVector_RegionToWorld(region_position) \
    enVector_RegionCornerToWorld(region_position, llGetRegionCorner())

// converts a region CORNER and POSITION to a world-scope position
#define enVector_RegionCornerToWorld(region_position, region_corner) \
    (region_position + region_corner)
