/*
    event-handlers.lsl
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

    This file #includes all possible event handlers. Only event handlers that are
    necessary for the script to run will be included in the compiled script.

    At the bottom of the script, add:

    default
    {
		    #include "en-lsl-framework/event-handlers.lsl"
    }

    to allow the En framework to handle events.

    Make sure the "Script optimizer" setting is enabled in your preprocessor!
*/

// each major revision of En increments this value
#define EN$EVENT_HANDLERS_LOADED 1

// include event handlers that En actually uses
#include "en-lsl-framework/event-handlers/at_rot_target.lsl"
#include "en-lsl-framework/event-handlers/at_target.lsl"
#include "en-lsl-framework/event-handlers/attach.lsl"
#include "en-lsl-framework/event-handlers/changed.lsl"
#include "en-lsl-framework/event-handlers/collision_end.lsl"
#include "en-lsl-framework/event-handlers/collision_start.lsl"
#include "en-lsl-framework/event-handlers/collision.lsl"
#include "en-lsl-framework/event-handlers/control.lsl"
#include "en-lsl-framework/event-handlers/dataserver.lsl"
#include "en-lsl-framework/event-handlers/email.lsl"
#include "en-lsl-framework/event-handlers/experience_permissions_denied.lsl"
#include "en-lsl-framework/event-handlers/experience_permissions.lsl"
#include "en-lsl-framework/event-handlers/final_damage.lsl"
#include "en-lsl-framework/event-handlers/game_control.lsl"
#include "en-lsl-framework/event-handlers/http_request.lsl"
#include "en-lsl-framework/event-handlers/http_response.lsl"
#include "en-lsl-framework/event-handlers/land_collision_end.lsl"
#include "en-lsl-framework/event-handlers/land_collision_start.lsl"
#include "en-lsl-framework/event-handlers/land_collision.lsl"
#include "en-lsl-framework/event-handlers/link_message.lsl"
#include "en-lsl-framework/event-handlers/listen.lsl"
#include "en-lsl-framework/event-handlers/money.lsl"
#include "en-lsl-framework/event-handlers/moving_end.lsl"
#include "en-lsl-framework/event-handlers/moving_start.lsl"
#include "en-lsl-framework/event-handlers/no_sensor.lsl"
#include "en-lsl-framework/event-handlers/not_at_rot_target.lsl"
#include "en-lsl-framework/event-handlers/not_at_target.lsl"
#include "en-lsl-framework/event-handlers/object_rez.lsl"
#include "en-lsl-framework/event-handlers/on_damage.lsl"
#include "en-lsl-framework/event-handlers/on_death.lsl"
#include "en-lsl-framework/event-handlers/on_rez.lsl"
#include "en-lsl-framework/event-handlers/path_update.lsl"
#include "en-lsl-framework/event-handlers/remote_data.lsl"
#include "en-lsl-framework/event-handlers/run_time_permissions.lsl"
#include "en-lsl-framework/event-handlers/sensor.lsl"
#include "en-lsl-framework/event-handlers/state_entry.lsl"
#include "en-lsl-framework/event-handlers/state_eent.lsl"
#include "en-lsl-framework/event-handlers/timer.lsl"
#include "en-lsl-framework/event-handlers/touch_end.lsl"
#include "en-lsl-framework/event-handlers/touch_start.lsl"
#include "en-lsl-framework/event-handlers/touch.lsl"
#include "en-lsl-framework/event-handlers/transaction_result.lsl"
