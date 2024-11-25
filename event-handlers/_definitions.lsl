/*
    _definitions.lsl
    Event Handler Definitions
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

    This code provides definitions used by Xi event handlers.
*/

// ==
// == event handlers
// ==

#define Xi$at_rot_target(...) _Xi_at_rot_target( __VA_ARGS__ )
#define Xi$at_target(...) _Xi_at_target( __VA_ARGS__ )
#define Xi$attach(...) _Xi_attach( __VA_ARGS__ )
#define Xi$changed(...) _Xi_changed( __VA_ARGS__ )
#define Xi$collision_end(...) _Xi_collision_end( __VA_ARGS__ )
#define Xi$collision_start(...) _Xi_collision_start( __VA_ARGS__ )
#define Xi$collision(...) _Xi_collision( __VA_ARGS__ )
#define Xi$control(...) _Xi_control( __VA_ARGS__ )
#define Xi$dataserver(...) _Xi_dataserver( __VA_ARGS__ )
#define Xi$email(...) _Xi_email( __VA_ARGS__ )
#define Xi$experience_permissions_denied(...) _Xi_experience_permissions_denied( __VA_ARGS__ )
#define Xi$experience_permissions(...) _Xi_experience_permissions( __VA_ARGS__ )
#define Xi$final_damage(...) _Xi_final_damage( __VA_ARGS__ )
#define Xi$game_control(...) _Xi_game_control( __VA_ARGS__ )
#define Xi$http_request(...) _Xi_http_request( __VA_ARGS__ )
#define Xi$http_response(...) _Xi_http_response( __VA_ARGS__ )
#define Xi$land_collision_end(...) _Xi_land_collision_end( __VA_ARGS__ )
#define Xi$land_collision_start(...) _Xi_land_collision_start( __VA_ARGS__ )
#define Xi$land_collision(...) _Xi_land_collision( __VA_ARGS__ )
#define Xi$link_message(...) _Xi_link_message( __VA_ARGS__ )
#define Xi$linkset_data(...) _Xi_linkset_data( __VA_ARGS__ )
#define Xi$listen(...) _Xi_listen( __VA_ARGS__ )
#define Xi$money(...) _Xi_money( __VA_ARGS__ )
#define Xi$moving_end(...) _Xi_moving_end( __VA_ARGS__ )
#define Xi$moving_start(...) _Xi_moving_start( __VA_ARGS__ )
#define Xi$no_sensor(...) _Xi_no_sensor( __VA_ARGS__ )
#define Xi$not_at_rot_target(...) _Xi_not_at_rot_target( __VA_ARGS__ )
#define Xi$not_at_target(...) _Xi_not_at_target( __VA_ARGS__ )
#define Xi$object_rez(...) _Xi_object_rez( __VA_ARGS__ )
#define Xi$on_damage(...) _Xi_on_damage( __VA_ARGS__ )
#define Xi$on_death(...) _Xi_on_death( __VA_ARGS__ )
#define Xi$on_rez(...) _Xi_on_rez( __VA_ARGS__ )
#define Xi$path_update(...) _Xi_path_update( __VA_ARGS__ )
#define Xi$remote_data(...) _Xi_remote_data( __VA_ARGS__ )
#define Xi$run_time_permissions(...) _Xi_run_time_permissions( __VA_ARGS__ )
#define Xi$sensor(...) _Xi_sensor( __VA_ARGS__ )
#define Xi$state_entry(...) _Xi_state_entry( __VA_ARGS__ )
#define Xi$state_exit(...) _Xi_state_exit( __VA_ARGS__ )
#define Xi$timer(...) _Xi_timer( __VA_ARGS__ )
#define Xi$touch_end(...) _Xi_touch_end( __VA_ARGS__ )
#define Xi$touch_start(...) _Xi_touch_start( __VA_ARGS__ )
#define Xi$touch(...) _Xi_touch( __VA_ARGS__ )
#define Xi$transaction_result(...) _Xi_transaction_result( __VA_ARGS__ )
