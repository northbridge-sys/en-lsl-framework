/*
    main.lsl
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

    This file #includes all eXisting Xi library scripts. Type the following:
		#include "xi-lsl-framework/main.lsl"
    into the top of an LSL script with the LSL preprocessor enabled to be able to
    call Xi library functions.

    Make sure to #define any desired preprocessor flags BEFORE #include-ing this
    script, or the libraries may be loaded incorrectly.

    Make sure the "Script optimizer" setting is enabled in your preprocessor,
    otherwise the entire contents of the Xi library will be added to your script!
*/

// each major revision of XI increments this value
#define XI_LOADED 1

// libraries

// XiLog - logging/output interface via llOwnerSay
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiLog.lsl"

// XiInteger - integer variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiInteger.lsl"

// XiFloat - float variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiFloat.lsl"

// XiVector - vector variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiVector.lsl"

// XiRotation - rotation variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiRotation.lsl"

// XiString - string variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiString.lsl"

// XiKey - key variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiKey.lsl"

// XiList - list variable manipulation functions
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiList.lsl"

// XiObject - utilities that expose information about linksets (self or others)
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiObject.lsl"

// XiInventory - inventory & notecard management libraries
// must be defined early due to preprocessor flags being used in other libraries
#include "xi-lsl-framework/libraries/XiInventory.lsl"

// XiChat - libraries for safely communicating with other scripts via chat
#include "xi-lsl-framework/libraries/XiChat.lsl"

// XiCrypt - """cryptographic""" libraries, or at least as far as is possible in LSL
#include "xi-lsl-framework/libraries/XiCrypt.lsl"

// XiHTTP - outgoing HTTP request library with queueing and throttling protection
#include "xi-lsl-framework/libraries/XiHTTP.lsl"

// XiIMP - implementation of the structured Interface Message Protocol via link messages and XiChat
#include "xi-lsl-framework/libraries/XiIMP.lsl"

// XiKVP - simple in-memory key-value storage, helpful as a backup to XiLSD
#include "xi-lsl-framework/libraries/XiKVP.lsl"

// XiLSD - method to store values in linkset data with a preset header, optionally separated by prim UUID
#include "xi-lsl-framework/libraries/XiLSD.lsl"

// XiTimer - multiple timers in one script with callbacks
#include "xi-lsl-framework/libraries/XiTimer.lsl"

// XiTest - runtime testing utilities, such as unit tests
#include "xi-lsl-framework/libraries/XiTest.lsl"
