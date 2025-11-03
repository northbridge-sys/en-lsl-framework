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
    #include "northbridge-sys/en-lsl-framework/event-handlers.lsl"
}

to allow the En framework to handle events.

Make sure the "Script optimizer" setting is enabled in your preprocessor!
*/

// each major revision of En increments this value
#define EN_EVENT_HANDLERS_LOADED 1

// set global event handler trace
#if defined EN_TRACE_EVENT_HANDLERS
    #define TRACE_EVENT_EN_AT_ROT_TARGET
    #define TRACE_EVENT_EN_AT_TARGET
    #define EVENT_EN_ATTACH_TRACE
    #define EN_CHANGED_TRACE
    #define TRACE_EVENT_EVENT_EN_COLLISION_END
    #define TRACE_EVENT_EVENT_EN_COLLISION_START
    #define TRACE_EVENT_EN_COLLISION
    #define TRACE_EVENT_EN_CONTROL
    #define TRACE_EVENT_EN_DATASERVER
    #define TRACE_EVENT_EN_EMAIL
    #define TRACE_EVENT_EVENT_EN_EXPERIENCE_PERMISSIONS_DENIED
    #define TRACE_EVENT_EN_EXPERIENCE_PERMISSIONS
    #define TRACE_EVENT_EN_FINAL_DAMAGE
    #define TRACE_EVENT_EN_GAME_CONTROL
    #define TRACE_EVENT_EN_HTTP_REQUEST
    #define TRACE_EVENT_EN_HTTP_RESPONSE
    #define TRACE_EVENT_EVENT_EN_LAND_COLLISION
    #define TRACE_EVENT_EVENT_EN_LAND_COLLISION_START
    #define TRACE_EVENT_EN_LAND_COLLISION
    #define TRACE_EVENT_EN_LINK_MESSAGE
    #define TRACE_EVENT_EN_LISTEN
    #define TRACE_EVENT_EN_MONEY
    #define TRACE_EVENT_EN_MOVING_END
    #define TRACE_EVENT_EN_MOVING_START
    #define TRACE_EVENT_EN_NO_SENSOR
    #define TRACE_EVENT_EN_NOT_AT_ROT_TARGET
    #define TRACE_EVENT_EN_NOT_AT_TARGET
    #define TRACE_EVENT_EN_OBJECT_REZ
    #define TRACE_EVENT_EN_ON_DAMAGE
    #define TRACE_EVENT_EN_ON_DEATH
    #define TRACE_EVENT_EN_ON_REZ
    #define TRACE_EVENT_EN_PATH_UPDATE
    #define TRACE_EVENT_EN_REMOTE_DATA
    #define TRACE_EVENT_EN_RUN_TIME_PERMISSIONS
    #define TRACE_EVENT_EN_SENSOR
    #define TRACE_EVENT_EN_STATE_ENTRY
    #define EN_STATE_EENT_TRACE
    #define TRACE_EVENT_EN_TIMER
    #define TRACE_EVENT_EN_TOUCH_END
    #define TRACE_EVENT_EN_TOUCH_START
    #define TRACE_EVENT_EN_TOUCH
    #define EN_TRANSACTION_RESULT_TRACE
#endif

// all known events as of latest revision
#include "northbridge-sys/en-lsl-framework/event-handlers/at_rot_target.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/at_target.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/attach.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/changed.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/collision_end.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/collision_start.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/collision.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/control.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/dataserver.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/email.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/experience_permissions_denied.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/experience_permissions.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/final_damage.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/game_control.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/http_request.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/http_response.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/land_collision_end.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/land_collision_start.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/land_collision.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/link_message.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/listen.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/money.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/moving_end.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/moving_start.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/no_sensor.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/not_at_rot_target.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/not_at_target.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/object_rez.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/on_damage.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/on_death.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/on_rez.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/path_update.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/remote_data.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/run_time_permissions.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/sensor.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/state_entry.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/state_exit.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/timer.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/touch_end.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/touch_start.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/touch.lsl"
#include "northbridge-sys/en-lsl-framework/event-handlers/transaction_result.lsl"
