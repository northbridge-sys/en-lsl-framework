/*
libraries.lsl
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

This file #includes all existing En library scripts. Type the following:
#include "nbs/en-lsl-framework/libraries.lsl"
into the top of an LSL script with the LSL preprocessor enabled to be able to
call En library functions.

Make sure to #define any desired preprocessor flags BEFORE #include-ing this
script, or the libraries may be loaded incorrectly.

Make sure the "Script optimizer" setting is enabled in your preprocessor!
*/

// each major revision of En increments this value
#define EN_LIBRARIES_LOADED 1

// macros
#include "nbs/en-lsl-framework/libraries/enAvatar/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enCLEP/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enDate/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enEnvironment/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enFloat/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enHTTP/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enInteger/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enInventory/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enKey/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enKVS/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enLEP/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enList/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enLog/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enLSD/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enObject/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enRotation/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enString/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enTimer/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enTest/macros.lsl"
#include "nbs/en-lsl-framework/libraries/enVector/macros.lsl"

// functions
#include "nbs/en-lsl-framework/libraries/enAvatar/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enCLEP/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enDate/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enEnvironment/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enFloat/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enHTTP/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enInteger/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enInventory/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enKey/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enKVS/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enLEP/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enList/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enLog/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enLSD/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enObject/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enRotation/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enString/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enTimer/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enTest/functions.lsl"
#include "nbs/en-lsl-framework/libraries/enVector/functions.lsl"
