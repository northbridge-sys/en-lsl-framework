/*
enInventory.lsl
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

#define ENINVENTORY_NC_OPENED 0x1
#define ENINVENTORY_NC_MODIFIED 0x2

#if defined EN_TRACE_LIBRARIES
    #define ENINVENTORY_TRACE
#endif

// buffer for free memory available when using llGetNotecardLineSync vs. llGetNotecardLine
// if less than ENINVENTORY_NC_MEMORY_BUFFER is available, use llGetNotecardLine
// this allows garbage collection to trigger before the dataserver event is called
#if !defined ENINVENTORY_NC_MEMORY_BUFFER
    #define ENINVENTORY_NC_MEMORY_BUFFER 8192
#endif

string _ENINVENTORY_NC_N; // notecard name
string _ENINVENTORY_NC_K; // notecard key
integer _ENINVENTORY_NC_L = -1; // notecard line being read
integer _ENINVENTORY_NC_T = -1; // notecard total lines
string _ENINVENTORY_NC_H; // notecard read handle
string _ENINVENTORY_NC_G; // llGetNumberOfNotecardLines handle

#define enInventory_NCOpenedName() _ENINVENTORY_NC_N
#define enInventory_NCOpenedKey() _ENINVENTORY_NC_K
