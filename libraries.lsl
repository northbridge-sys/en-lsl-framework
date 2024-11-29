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
		#include "en-lsl-framework/libraries.lsl"
    into the top of an LSL script with the LSL preprocessor enabled to be able to
    call En library functions.

    Make sure to #define any desired preprocessor flags BEFORE #include-ing this
    script, or the libraries may be loaded incorrectly.

    Make sure the "Script optimizer" setting is enabled in your preprocessor!
*/

// each major revision of En increments this value
#define EN$LIBRARIES_LOADED 1

// definition files, since we are at the top of the script
#include "en-lsl-framework/event-handlers/_definitions.lsl"
#include "en-lsl-framework/libraries/_definitions.lsl"

// libraries
#include "en-lsl-framework/libraries/enAvatar.lsl"
#include "en-lsl-framework/libraries/enChat.lsl"
#include "en-lsl-framework/libraries/enDate.lsl"
#include "en-lsl-framework/libraries/enFloat.lsl"
#include "en-lsl-framework/libraries/enHTTP.lsl"
#include "en-lsl-framework/libraries/enIMP.lsl"
#include "en-lsl-framework/libraries/enInteger.lsl"
#include "en-lsl-framework/libraries/enInventory.lsl"
#include "en-lsl-framework/libraries/enKey.lsl"
#include "en-lsl-framework/libraries/enKVP.lsl"
#include "en-lsl-framework/libraries/enList.lsl"
#include "en-lsl-framework/libraries/enLog.lsl"
#include "en-lsl-framework/libraries/enLSD.lsl"
#include "en-lsl-framework/libraries/enObject.lsl"
#include "en-lsl-framework/libraries/enRotation.lsl"
#include "en-lsl-framework/libraries/enString.lsl"
#include "en-lsl-framework/libraries/enTimer.lsl"
#include "en-lsl-framework/libraries/enTest.lsl"
#include "en-lsl-framework/libraries/enVector.lsl"
