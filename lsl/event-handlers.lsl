/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-framework

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

// each major revision of En increments this value
#define EN_EVENT_HANDLERS_LOADED 1

// all known events as of latest revision
#include "northbridge-sys/en-framework/lsl/event-handlers/at_rot_target.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/at_target.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/attach.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/changed.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/collision_end.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/collision_start.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/collision.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/control.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/dataserver.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/email.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/experience_permissions_denied.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/experience_permissions.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/final_damage.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/game_control.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/http_request.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/http_response.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/land_collision_end.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/land_collision_start.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/land_collision.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/link_message.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/listen.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/money.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/moving_end.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/moving_start.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/no_sensor.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/not_at_rot_target.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/not_at_target.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/object_rez.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/on_damage.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/on_death.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/on_rez.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/path_update.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/remote_data.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/run_time_permissions.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/sensor.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/state_entry.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/state_exit.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/timer.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/touch_end.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/touch_start.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/touch.lsl"
#include "northbridge-sys/en-framework/lsl/event-handlers/transaction_result.lsl"
