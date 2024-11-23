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

    This file #includes all existing Xi library scripts. Type the following:
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
#include "xi-lsl-framework/event-handlers/at_rot_target.lsl"
#include "xi-lsl-framework/event-handlers/at_target.lsl"
#include "xi-lsl-framework/event-handlers/attach.lsl"
#include "xi-lsl-framework/event-handlers/changed.lsl"
#include "xi-lsl-framework/event-handlers/collision_end.lsl"
#include "xi-lsl-framework/event-handlers/collision_start.lsl"
#include "xi-lsl-framework/event-handlers/collision.lsl"
#include "xi-lsl-framework/event-handlers/control.lsl"
#include "xi-lsl-framework/event-handlers/dataserver.lsl"
#include "xi-lsl-framework/event-handlers/email.lsl"
#include "xi-lsl-framework/event-handlers/experience_permissions_denied.lsl"
#include "xi-lsl-framework/event-handlers/experience_permissions.lsl"
#include "xi-lsl-framework/event-handlers/final_damage.lsl"
#include "xi-lsl-framework/event-handlers/game_control.lsl"
#include "xi-lsl-framework/event-handlers/http_request.lsl"
#include "xi-lsl-framework/event-handlers/http_response.lsl"
#include "xi-lsl-framework/event-handlers/land_collision_end.lsl"
#include "xi-lsl-framework/event-handlers/land_collision_start.lsl"
#include "xi-lsl-framework/event-handlers/land_collision.lsl"
#include "xi-lsl-framework/event-handlers/link_message.lsl"
#include "xi-lsl-framework/event-handlers/listen.lsl"
#include "xi-lsl-framework/event-handlers/money.lsl"
#include "xi-lsl-framework/event-handlers/moving_end.lsl"
#include "xi-lsl-framework/event-handlers/moving_start.lsl"
#include "xi-lsl-framework/event-handlers/no_sensor.lsl"
#include "xi-lsl-framework/event-handlers/not_at_rot_target.lsl"
#include "xi-lsl-framework/event-handlers/not_at_target.lsl"
#include "xi-lsl-framework/event-handlers/object_rez.lsl"
#include "xi-lsl-framework/event-handlers/on_damage.lsl"
#include "xi-lsl-framework/event-handlers/on_death.lsl"
#include "xi-lsl-framework/event-handlers/on_rez.lsl"
#include "xi-lsl-framework/event-handlers/path_update.lsl"
#include "xi-lsl-framework/event-handlers/remote_data.lsl"
#include "xi-lsl-framework/event-handlers/run_time_permissions.lsl"
#include "xi-lsl-framework/event-handlers/sensor.lsl"
#include "xi-lsl-framework/event-handlers/state_entry.lsl"
#include "xi-lsl-framework/event-handlers/state_exit.lsl"
#include "xi-lsl-framework/event-handlers/timer.lsl"
#include "xi-lsl-framework/event-handlers/touch_end.lsl"
#include "xi-lsl-framework/event-handlers/touch_start.lsl"
#include "xi-lsl-framework/event-handlers/touch.lsl"
#include "xi-lsl-framework/event-handlers/transaction_result.lsl"
