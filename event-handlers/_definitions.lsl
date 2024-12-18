/*
    _definitions.lsl
    Event Handler Definitions
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

    This code provides definitions used by En event handlers.
*/

// ==
// == event handlers
// ==

#define en_at_rot_target(...) _en_at_rot_target( __VA_ARGS__ )
#define en_at_target(...) _en_at_target( __VA_ARGS__ )
#define en_attach(...) _en_attach( __VA_ARGS__ )
#define en_changed(...) _en_changed( __VA_ARGS__ )
#define en_collision_end(...) _en_collision_end( __VA_ARGS__ )
#define en_collision_start(...) _en_collision_start( __VA_ARGS__ )
#define en_collision(...) _en_collision( __VA_ARGS__ )
#define en_control(...) _en_control( __VA_ARGS__ )
#define en_dataserver(...) _en_dataserver( __VA_ARGS__ )
#define en_email(...) _en_email( __VA_ARGS__ )
#define en_experience_permissions_denied(...) _en_experience_permissions_denied( __VA_ARGS__ )
#define en_experience_permissions(...) _en_experience_permissions( __VA_ARGS__ )
#define en_final_damage(...) _en_final_damage( __VA_ARGS__ )
#define en_game_control(...) _en_game_control( __VA_ARGS__ )
#define en_http_request(...) _en_http_request( __VA_ARGS__ )
#define en_http_response(...) _en_http_response( __VA_ARGS__ )
#define en_land_collision_end(...) _en_land_collision_end( __VA_ARGS__ )
#define en_land_collision_start(...) _en_land_collision_start( __VA_ARGS__ )
#define en_land_collision(...) _en_land_collision( __VA_ARGS__ )
#define en_link_message(...) _en_link_message( __VA_ARGS__ )
#define en_linkset_data(...) _en_linkset_data( __VA_ARGS__ )
#define en_listen(...) _en_listen( __VA_ARGS__ )
#define en_money(...) _en_money( __VA_ARGS__ )
#define en_moving_end(...) _en_moving_end( __VA_ARGS__ )
#define en_moving_start(...) _en_moving_start( __VA_ARGS__ )
#define en_no_sensor(...) _en_no_sensor( __VA_ARGS__ )
#define en_not_at_rot_target(...) _en_not_at_rot_target( __VA_ARGS__ )
#define en_not_at_target(...) _en_not_at_target( __VA_ARGS__ )
#define en_object_rez(...) _en_object_rez( __VA_ARGS__ )
#define en_on_damage(...) _en_on_damage( __VA_ARGS__ )
#define en_on_death(...) _en_on_death( __VA_ARGS__ )
#define en_on_rez(...) _en_on_rez( __VA_ARGS__ )
#define en_path_update(...) _en_path_update( __VA_ARGS__ )
#define en_remote_data(...) _en_remote_data( __VA_ARGS__ )
#define en_run_time_permissions(...) _en_run_time_permissions( __VA_ARGS__ )
#define en_sensor(...) _en_sensor( __VA_ARGS__ )
#define en_state_entry(...) _en_state_entry( __VA_ARGS__ )
#define en_state_eent(...) _en_state_eent( __VA_ARGS__ )
#define en_timer(...) _en_timer( __VA_ARGS__ )
#define en_touch_end(...) _en_touch_end( __VA_ARGS__ )
#define en_touch_start(...) _en_touch_start( __VA_ARGS__ )
#define en_touch(...) _en_touch( __VA_ARGS__ )
#define en_transaction_result(...) _en_transaction_result( __VA_ARGS__ )
