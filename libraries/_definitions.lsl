/*
    _definitions.lsl
    Library Definitions
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

    This code provides definitions used when calling En libraries.

    Since libraries within the En framework call functions from other libraries,
    these definitions need to be loaded into the preprocessor before the libraries
    themselves, or the compiler will throw errors.
*/

// ==
// == static preprocessor constants
// ==

// enFloat
#define FLOAT_MAX 1.175494351E-38
#define FLOAT_MIN 3.402823466E+38
#define PI_BY_FOUR 0.78539816339

// enInteger
#define INTEGER_MAX 0x7FFFFFFF
#define INTEGER_MIN 0x80000000
#define INTEGER_NEGATIVE 0x80000000

// enTest
#define INTEGER 0
#define FLOAT 1
#define VECTOR 2
#define ROTATION 3
#define STRING 4
#define KEY 5
#define LIST 6

// enLog
#define PRINT 0
#define FATAL 1
#define ERROR 2
#define WARN 3
#define INFO 4
#define DEBUG 5
#define TRACE 6

// enObject
#define RED <1.0, 0.25, 0.0>
#define ORANGE <1.0, 0.5, 0.0>
#define YELLOW <1.0, 0.8, 0.0>
#define GREEN <0.5, 1.0, 0.0>
#define BLUE <0.2, 0.8, 1.0>
#define PURPLE <0.5, 0.0, 1.0>
#define PINK <1.0, 0.0, 0.5>
#define WHITE <1.0, 1.0, 1.0>
#define BLACK <0.0, 0.0, 0.0>

#define ENCLEP_LISTEN_OWNERONLY 0x1
#define ENCLEP_LISTEN_REMOVE 0x80000000

#define ENDATE_12_HOUR 0x1
#define ENDATE_PAD_ZEROES 0x2

#define ENLEP_TYPE_REQUEST 0x1
#define ENLEP_TYPE_RESPONSE 0x2
#define ENLEP_STATUS_ERROR 0x4

#define ENOBJECT_PROFILE_EXISTS 0x80000000
#define ENOBJECT_PROFILE_PHYSICS 0x1
#define ENOBJECT_PROFILE_PHANTOM 0x2
#define ENOBJECT_PROFILE_TEMP_ON_REZ 0x4
#define ENOBJECT_PROFILE_TEMP_ATTACHED 0x8
#define ENOBJECT_TEXT_SUCCESS 0x10
#define ENOBJECT_TEXT_BUSY 0x20
#define ENOBJECT_TEXT_PROMPT 0x40
#define ENOBJECT_TEXT_ERROR 0x80
#define ENOBJECT_TEXT_TEMP 0x100
#define ENOBJECT_TEXT_PROGRESS_NC 0x200
#define ENOBJECT_TEXT_PROGRESS_THROB 0x400

#define ENSTRING_PAD_ALIGN_LEFT 0
#define ENSTRING_PAD_ALIGN_RIGHT 1
#define ENSTRING_PAD_ALIGN_CENTER 2
#define ENSTRING_ESCAPE_FILTER_REGEX 0x1
#define ENSTRING_ESCAPE_FILTER_JSON 0x2
#define ENSTRING_ESCAPE_REVERSE 0x40000000

#define ENTEST_EQUAL 0
#define ENTEST_NOT_EQUAL 1
#define ENTEST_GREATER 2
#define ENTEST_LESS 3

// 0xFFFFFFFF is 1 byte and 1 operation more efficient than -1
#define ENTEST_VM_LSO 0xFFFFFFFF
#define ENTEST_VM_MONO 1

// ==
// == configurable preprocessor constants
// ==

#ifndef ENCLEP_RESERVE_LISTENS
    #define ENCLEP_RESERVE_LISTENS 0
#endif

#ifndef ENCLEP_PTP_SIZE
    // note that this value is set to the maximum number of UTF-8 characters that can be sent via llRegionSayTo
    // if you are positive you will ALWAYS have ASCII-7 characters, this can be raised to 1024 for better performance and lower memory usage
    #define ENCLEP_PTP_SIZE 512
#endif

#ifndef ENLEP_LINK_MESSAGE_SCOPE
    #define ENLEP_LINK_MESSAGE_SCOPE LINK_THIS
#endif

#ifndef ENLSD_PASS
    #define ENLSD_PASS ""
#endif

#ifndef ENINTEGER_CHARSET_16
    #define ENINTEGER_CHARSET_16 "0123456789abcdef"
#endif
#ifndef ENINTEGER_CHARSET_64
    #define ENINTEGER_CHARSET_64 "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-="
#endif
#ifndef ENINTEGER_CHARSET_256
    #define ENINTEGER_CHARSET_256 ""
#endif

#ifndef ENLOG_DEFAULT_LOGLEVEL
    #define ENLOG_DEFAULT_LOGLEVEL 4
#endif

#ifndef ENOBJECT_LIMIT_SELF
    // number of own object UUIDs to store, retrievable via enObject_Self
    #define ENOBJECT_LIMIT_SELF 2
#endif

#ifndef ENTEST_PRECISION_FLOAT
    // default exact precision for floats - adjust this in script if desired
    #define ENTEST_PRECISION_FLOAT 0.0
#endif

#ifndef ENTEST_PRECISION_VECTOR
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST_PRECISION_VECTOR 0.0
#endif

#ifndef ENTEST_PRECISION_ROTATION
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST_PRECISION_ROTATION 0.0
#endif

#ifndef ENTIMER_MINIMUM_INTERVAL
    #define ENTIMER_MINIMUM_INTERVAL 0.1
#endif

#ifdef EN_TRACE_LIBRARIES
    #define ENAVATAR_TRACE
    #define ENCLEP_TRACE
    #define ENDATE_TRACE
    #define ENFLOAT_TRACE
    #define ENHTTP_TRACE
    #define ENLEP_TRACE
    #define ENINTEGER_TRACE
    #define ENINVENTORY_TRACE
    #define ENKEY_TRACE
    #define ENKVS_TRACE
    #define ENLIST_TRACE
    #define ENLOG_TRACE
    #define ENLSD_TRACE
    #define ENOBJECT_TRACE
    #define ENROTATION_TRACE
    #define ENSTRING_TRACE
    #define ENTEST_TRACE
    #define ENTIMER_TRACE
    #define ENVECTOR_TRACE
#endif

#ifdef EN_TRACE_EVENT_HANDLERS
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

// ==
// == macros required by all libraries
// ==

#define enLog_Print(...) enLog_To( 0, __LINE__, "", __VA_ARGS__ )
#define enLog_Fatal(...) enLog_To( 1, __LINE__, "", __VA_ARGS__ )
#define enLog_Error(...) enLog_To( 2, __LINE__, "", __VA_ARGS__ )
#define enLog_Warn(...) enLog_To( 3, __LINE__, "", __VA_ARGS__ )
#define enLog_Info(...) enLog_To( 4, __LINE__, "", __VA_ARGS__ )
#define enLog_Debug(...) enLog_To( 5, __LINE__, "", __VA_ARGS__ )
#define enLog_Trace(...) enLog_To( 6, __LINE__, "", __VA_ARGS__ )

#define enLog_PrintTo(...) enLog_To( 0, __LINE__, __VA_ARGS__ )
#define enLog_FatalTo(...) enLog_To( 1, __LINE__, __VA_ARGS__ )
#define enLog_ErrorTo(...) enLog_To( 2, __LINE__, __VA_ARGS__ )
#define enLog_WarnTo(...) enLog_To( 3, __LINE__, __VA_ARGS__ )
#define enLog_InfoTo(...) enLog_To( 4, __LINE__, __VA_ARGS__ )
#define enLog_DebugTo(...) enLog_To( 5, __LINE__, __VA_ARGS__ )
#define enLog_TraceTo(...) enLog_To( 6, __LINE__, __VA_ARGS__ )
