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
    #include "nbs/en-lsl-framework/event-handlers.lsl"
}

to allow the En framework to handle events.

Make sure the "Script optimizer" setting is enabled in your preprocessor!
*/

// each major revision of En increments this value
#define EN_EVENT_HANDLERS_LOADED 1

// set global event handler trace
#if defined EN_TRACE_EVENT_HANDLERS
    #define EN_AT_ROT_TARGET_TRACE
    #define EN_AT_TARGET_TRACE
    #define EN_ATTACH_TRACE
    #define EN_CHANGED_TRACE
    #define EN_COLLISION_END_TRACE
    #define EN_COLLISION_START_TRACE
    #define EN_COLLISION_TRACE
    #define EN_CONTROL_TRACE
    #define EN_DATASERVER_TRACE
    #define EN_EMAIL_TRACE
    #define EN_EXPERIENCE_PERMISSIONS_DENIED_TRACE
    #define EN_EXPERIENCE_PERMISSIONS_TRACE
    #define EN_FINAL_DAMAGE_TRACE
    #define EN_GAME_CONTROL_TRACE
    #define EN_HTTP_REQUEST_TRACE
    #define EN_HTTP_RESPONSE_TRACE
    #define EN_LAND_COLLISION_END_TRACE
    #define EN_LAND_COLLISION_START_TRACE
    #define EN_LAND_COLLISION_TRACE
    #define EN_LINK_MESSAGE_TRACE
    #define EN_LISTEN_TRACE
    #define EN_MONEY_TRACE
    #define EN_MOVING_END_TRACE
    #define EN_MOVING_START_TRACE
    #define EN_NO_SENSOR_TRACE
    #define EN_NOT_AT_ROT_TARGET_TRACE
    #define EN_NOT_AT_TARGET_TRACE
    #define EN_OBJECT_REZ_TRACE
    #define EN_ON_DAMAGE_TRACE
    #define EN_ON_DEATH_TRACE
    #define EN_ON_REZ_TRACE
    #define EN_PATH_UPDATE_TRACE
    #define EN_REMOTE_DATA_TRACE
    #define EN_RUN_TIME_PERMISSIONS_TRACE
    #define EN_SENSOR_TRACE
    #define EN_STATE_ENTRY_TRACE
    #define EN_STATE_EENT_TRACE
    #define EN_TIMER_TRACE
    #define EN_TOUCH_END_TRACE
    #define EN_TOUCH_START_TRACE
    #define EN_TOUCH_TRACE
    #define EN_TRANSACTION_RESULT_TRACE
#endif

// all known events as of latest revision
#include "nbs/en-lsl-framework/event-handlers/at_rot_target.lsl"
#include "nbs/en-lsl-framework/event-handlers/at_target.lsl"
#include "nbs/en-lsl-framework/event-handlers/attach.lsl"
#include "nbs/en-lsl-framework/event-handlers/changed.lsl"
#include "nbs/en-lsl-framework/event-handlers/collision_end.lsl"
#include "nbs/en-lsl-framework/event-handlers/collision_start.lsl"
#include "nbs/en-lsl-framework/event-handlers/collision.lsl"
#include "nbs/en-lsl-framework/event-handlers/control.lsl"
#include "nbs/en-lsl-framework/event-handlers/dataserver.lsl"
#include "nbs/en-lsl-framework/event-handlers/email.lsl"
#include "nbs/en-lsl-framework/event-handlers/experience_permissions_denied.lsl"
#include "nbs/en-lsl-framework/event-handlers/experience_permissions.lsl"
#include "nbs/en-lsl-framework/event-handlers/final_damage.lsl"
#include "nbs/en-lsl-framework/event-handlers/game_control.lsl"
#include "nbs/en-lsl-framework/event-handlers/http_request.lsl"
#include "nbs/en-lsl-framework/event-handlers/http_response.lsl"
#include "nbs/en-lsl-framework/event-handlers/land_collision_end.lsl"
#include "nbs/en-lsl-framework/event-handlers/land_collision_start.lsl"
#include "nbs/en-lsl-framework/event-handlers/land_collision.lsl"
#include "nbs/en-lsl-framework/event-handlers/link_message.lsl"
#include "nbs/en-lsl-framework/event-handlers/listen.lsl"
#include "nbs/en-lsl-framework/event-handlers/money.lsl"
#include "nbs/en-lsl-framework/event-handlers/moving_end.lsl"
#include "nbs/en-lsl-framework/event-handlers/moving_start.lsl"
#include "nbs/en-lsl-framework/event-handlers/no_sensor.lsl"
#include "nbs/en-lsl-framework/event-handlers/not_at_rot_target.lsl"
#include "nbs/en-lsl-framework/event-handlers/not_at_target.lsl"
#include "nbs/en-lsl-framework/event-handlers/object_rez.lsl"
#include "nbs/en-lsl-framework/event-handlers/on_damage.lsl"
#include "nbs/en-lsl-framework/event-handlers/on_death.lsl"
#include "nbs/en-lsl-framework/event-handlers/on_rez.lsl"
#include "nbs/en-lsl-framework/event-handlers/path_update.lsl"
#include "nbs/en-lsl-framework/event-handlers/remote_data.lsl"
#include "nbs/en-lsl-framework/event-handlers/run_time_permissions.lsl"
#include "nbs/en-lsl-framework/event-handlers/sensor.lsl"
#include "nbs/en-lsl-framework/event-handlers/state_entry.lsl"
#include "nbs/en-lsl-framework/event-handlers/state_exit.lsl"
#include "nbs/en-lsl-framework/event-handlers/timer.lsl"
#include "nbs/en-lsl-framework/event-handlers/touch_end.lsl"
#include "nbs/en-lsl-framework/event-handlers/touch_start.lsl"
#include "nbs/en-lsl-framework/event-handlers/touch.lsl"
#include "nbs/en-lsl-framework/event-handlers/transaction_result.lsl"
