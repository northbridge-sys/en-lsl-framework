/*
    event-handlers.lsl
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

    This file #includes all eXisting Xi library scripts. Type the following:
		#include "xi-lsl-framework/libraries.lsl"
    into the top of an LSL script with the LSL preprocessor enabled to be able to
    call Xi library functions.

    Make sure to #define any desired preprocessor flags BEFORE #include-ing this
    script, or the libraries may be loaded incorrectly.

    Make sure the "Script optimizer" setting is enabled in your preprocessor,
    otherwise the entire contents of the Xi library will be added to your script!
*/

// each major revision of XI increments this value
#define XI$EVENT_HANDLERS_LOADED 1

// include event handlers that Xi actually uses
#include "xi-lsl-framework/event-handlers/attach.lsl"
#include "xi-lsl-framework/event-handlers/changed.lsl"
#include "xi-lsl-framework/event-handlers/dataserver.lsl"
#include "xi-lsl-framework/event-handlers/link_message.lsl"
#include "xi-lsl-framework/event-handlers/listen.lsl"
#include "xi-lsl-framework/event-handlers/on_rez.lsl"
#include "xi-lsl-framework/event-handlers/state_entry.lsl"
#include "xi-lsl-framework/event-handlers/timer.lsl"
