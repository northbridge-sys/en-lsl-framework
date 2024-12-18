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

#ifndef ENLSD_HEADER
    #define ENLSD_HEADER ""
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
    #define ENKVP_TRACE
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
// == functions
// ==

#define enAvatar_Elem(...) _enAvatar_Elem( __VA_ARGS__ )
#define enAvatar_GetGroup(...) _enAvatar_GetGroup( __VA_ARGS__ )

#define enCLEP_GetService(...) _enCLEP_GetService( __VA_ARGS__ )
#define enCLEP_SetService(...) _enCLEP_SetService( __VA_ARGS__ )
#define enCLEP_Channel(...) _enCLEP_Channel( __VA_ARGS__ )
#define enCLEP_RegionSayTo(...) _enCLEP_RegionSayTo( __VA_ARGS__ )
#define enCLEP_Listen(...) _enCLEP_Listen( __VA_ARGS__ )
#define enCLEP_Send(...) _enCLEP_Send( __VA_ARGS__ )
#define enCLEP_SendLEP(...) _enCLEP_SendLEP(__VA_ARGS__)
#define enCLEP_SendPTP(...) _enCLEP_SendPTP( __VA_ARGS__ )
#define enCLEP_Process(...) _enCLEP_Process( __VA_ARGS__ )
#define enCLEP_UnListenDomains(...) _enCLEP_UnListenDomains( __VA_ARGS__ )
#define enCLEP_ListenDomains(...) _enCLEP_ListenDomains( __VA_ARGS__ )
#define enCLEP_RefreshLinkset(...) _enCLEP_RefreshLinkset( __VA_ARGS__ )

#define enDate_MS(...) _enDate_MS( __VA_ARGS__ )
#define enDate_MSNow(...) _enDate_MSNow( __VA_ARGS__ )
#define enDate_MSAdd(...) _enDate_MSAdd( __VA_ARGS__ )

#define enFloat_ToString(...) _enFloat_ToString( __VA_ARGS__ )
#define enFloat_Clamp(...) _enFloat_Clamp( __VA_ARGS__ )
#define enFloat_Compress(...) _enFloat_Compress( __VA_ARGS__ )
#define enFloat_Decompress(...) _enFloat_Decompress( __VA_ARGS__ )
#define enFloat_FlipCoin(...) _enFloat_FlipCoin( __VA_ARGS__ )
#define enFloat_RandRange(...) _enFloat_RandRange( __VA_ARGS__ )

#define enHTTP_Request(...) _enHTTP_Request( __VA_ARGS__ )
#define _enHTTP_ProcessResponse(...) _enHTTP_ProcessResponse( __VA_ARGS__ )
#define _enHTTP_Timer(...) _enHTTP_Timer( __VA_ARGS__ )
#define _enHTTP_NextRequest(...) _enHTTP_NextRequest( __VA_ARGS__ )

#define enInteger_ElemBitfield(...) _enInteger_ElemBitfield( __VA_ARGS__ )
#define enInteger_Rand(...) _enInteger_Rand( __VA_ARGS__ )
#define enInteger_ToHex(...) _enInteger_ToHex( __VA_ARGS__ )
#define enInteger_ToNybbles(...) _enInteger_ToNybbles( __VA_ARGS__ )
#define enInteger_ToString64(...) _enInteger_ToString64( __VA_ARGS__ )
#define enInteger_FromStr64(...) _enInteger_FromStr64( __VA_ARGS__ )
#define enInteger_Clamp(...) _enInteger_Clamp( __VA_ARGS__ )
#define enInteger_Reset(...) _enInteger_Reset( __VA_ARGS__ )

#define enInventory_List(...) _enInventory_List( __VA_ARGS__ )
#define enInventory_Copy(...) _enInventory_Copy( __VA_ARGS__ )
#define enInventory_OwnedByCreator(...) _enInventory_OwnedByCreator( __VA_ARGS__ )
#define enInventory_RezRemote(...) _enInventory_RezRemote( __VA_ARGS__ )
#define enInventory_NCOpen(...) _enInventory_NCOpen( __VA_ARGS__ )
#define enInventory_NCOpenByPartialName(...) _enInventory_NCOpenByPartialName( __VA_ARGS__ )
#define _enInventory_NCParse(...) _enInventory_NCParse( __VA_ARGS__ )
#define enInventory_NCRead(...) _enInventory_NCRead( __VA_ARGS__ )
#define enInventory_TypeToString(...) _enInventory_TypeToString( __VA_ARGS__ )
#define enInventory_Push(...) _enInventory_Push( __VA_ARGS__ )
#define enInventory_Pull(...) _enInventory_Pull( __VA_ARGS__ )
#define en_nc_line(...) _enInventory_nc_line( __VA_ARGS__ )

#define enKey_Is(...) _enKey_Is( __VA_ARGS__ )
#define enKey_IsNotNull(...) _enKey_IsNotNull( __VA_ARGS__ )
#define enKey_IsNull(...) _enKey_IsNull( __VA_ARGS__ )
#define enKey_IsInRegion(...) _enKey_IsInRegion( __VA_ARGS__ )
#define enKey_IsAvatarInRegion(...) _enKey_IsAvatarInRegion( __VA_ARGS__ )
#define enKey_IsPrimInRegion(...) _enKey_IsPrimInRegion( __VA_ARGS__ )
#define enKey_Strip(...) _enKey_Strip( __VA_ARGS__ )
#define enKey_Unstrip(...) _enKey_Unstrip( __VA_ARGS__ )
#define enKey_Compress(...) _enKey_Compress( __VA_ARGS__ )
#define enKey_Decompress(...) _enKey_Decompress( __VA_ARGS__ )

#define enKVP_Exists(...) _enKVP_Exists( __VA_ARGS__ )
#define enKVP_Write(...) _enKVP_Write( __VA_ARGS__ )
#define enKVP_Read(...) _enKVP_Read( __VA_ARGS__ )
#define enKVP_Delete(...) _enKVP_Delete( __VA_ARGS__ )
#define enKVP_Reset(...) _enKVP_Reset(__VA_ARGS__)

#define enLEP_Process(...) _enLEP_Process( __VA_ARGS__ )
#define enLEP_Send(...) _enLEP_Send( __VA_ARGS__ )
#define enLEP_SendAs(...) _enLEP_SendAs(__VA_ARGS__)

#define enList_Collate(...) _enList_Collate( __VA_ARGS__ )
#define enList_Concatenate(...) _enList_Concatenate( __VA_ARGS__ )
#define enList_DeleteStrideByMatch(...) _enList_DeleteStrideByMatch( __VA_ARGS__ )
#define enList_Elem(...) _enList_Elem( __VA_ARGS__ )
#define enList_Empty(...) _enList_Empty( __VA_ARGS__ )
#define enList_FromString(...) _enList_FromStr( __VA_ARGS__ )
#define enList_FindPartial(...) _enList_FindPartial( __VA_ARGS__ )
#define enList_ReplaceExact(...) _enList_ReplaceExact(__VA_ARGS__)
#define enList_Reverse(...) _enList_Reverse( __VA_ARGS__ )
#define enList_ToJson(...) _enList_ToJson( __VA_ARGS__ )
#define enList_ToString(...) _enList_ToString( __VA_ARGS__ )

#define enLog_(...) _enLog_( __VA_ARGS__ )
#define enLog_Die(...) _enLog_Die( __VA_ARGS__ )
#define enLog_Delete(...) _enLog_Delete( __VA_ARGS__ )
#define enLog_FatalStop(...) _enLog_FatalStop( __VA_ARGS__ )
#define enLog_FatalDelete(...) _enLog_FatalDelete( __VA_ARGS__ )
#define enLog_FatalDie(...) _enLog_FatalDie_( __VA_ARGS__ )
#define enLog_LevelToString(...) _enLog_LevelToString( __VA_ARGS__ )
#define enLog_StringToLevel(...) _enLog_StringToLevel( __VA_ARGS__ )
#define enLog_TraceParams(...) _enLog_TraceParams( __VA_ARGS__ )
#define enLog_TraceVars(...) _enLog_TraceVars( __VA_ARGS__ )
#define enLog_GetLoglevel(...) _enLog_GetLoglevel( __VA_ARGS__ )
#define enLog_SetLoglevel(...) _enLog_SetLoglevel( __VA_ARGS__ )
#define enLog_GetLogtarget(...) _enLog_GetLogtarget( __VA_ARGS__ )
#define enLog_SetLogtarget(...) _enLog_SetLogtarget( __VA_ARGS__ )
#define enLog_To(...) _enLog_To( __VA_ARGS__ )

#define enLSD_Reset(...) _enLSD_Reset( __VA_ARGS__ )
#define enLSD_Write(...) _enLSD_Write( __VA_ARGS__ )
#define enLSD_Read(...) _enLSD_Read( __VA_ARGS__ )
#define enLSD_Delete(...) _enLSD_Delete( __VA_ARGS__ )
#define enLSD_Exists(...) _enLSD_Exists( __VA_ARGS__ )
#define enLSD_Find(...) _enLSD_Find( __VA_ARGS__ )
#define enLSD_BuildHead(...) _enLSD_BuildHead( __VA_ARGS__ )
#define enLSD_Pull(...) _enLSD_Pull( __VA_ARGS__ )
#define enLSD_Push(...) _enLSD_Push( __VA_ARGS__ )
#define enLSD_Process(...) _enLSD_Process( __VA_ARGS__ )
#define enLSD_CheckUUID(...) _enLSD_CheckUUID( __VA_ARGS__ )
#define enLSD_CheckScriptName(...) _enLSD_CheckScriptName(__VA_ARGS__)
#define enLSD_MoveAllPairs(...) _enLSD_MoveAllPairs(__VA_ARGS__)
#define enLSD_GetPairHead(...) _enLSD_GetPairHead(__VA_ARGS__)

#define enObject_CacheClosestLink(...) _enObject_CacheClosestLink( __VA_ARGS__ )
#define enObject_ClosestLink(...) _enObject_ClosestLink( __VA_ARGS__ )
#define enObject_ClosestLinkDesc(...) _enObject_ClosestLinkDesc( __VA_ARGS__ )
#define enObject_Elem(...) _enObject_Elem( __VA_ARGS__ )
#define _enObject_FindLink(...) _enObject_FindLink( __VA_ARGS__ )
#define enObject_GetAttachedString(...) _enObject_GetAttachedString( __VA_ARGS__ )
#define _enObject_LinkCacheUpdate(...) _enObject_LinkCacheUpdate( __VA_ARGS__ )
#define enObject_Self(...) _enObject_Self( __VA_ARGS__ )
#define enObject_Parent(...) _enObject_Parent( __VA_ARGS__ )
#define enObject_StopIfOwnerRezzed(...) _enObject_StopIfOwnerRezzed( __VA_ARGS__ )
#define enObject_Profile(...) _enObject_Profile( __VA_ARGS__ )
#define enObject_Text(...) _enObject_Text( __VA_ARGS__ )
#define _enObject_TextTemp(...) _enObject_TextTemp( __VA_ARGS__ )
#define _enObject_UpdateUUIDs(...) _enObject_UpdateUUIDs( __VA_ARGS__ )

#define enRotation_Compress(...) _enRotation_Compress( __VA_ARGS__ )
#define enRotation_Decompress(...) _enRotation_Decompress( __VA_ARGS__ )
#define enRotation_Elem(...) _enRotation_Elem( __VA_ARGS__ )
#define enRotation_FromString(...) _enRotation_FromString( __VA_ARGS__ )
#define enRotation_Normalize(...) _enRotation_Normalize( __VA_ARGS__ )
#define enRotation_Slerp(...) _enRotation_Slerp( __VA_ARGS__ )
#define enRotation_Nlerp(...) _enRotation_Nlerp( __VA_ARGS__ )

#define enString_Elem(...) _enString_Elem( __VA_ARGS__ )
#define enString_Plural(...) _enString_Plural( __VA_ARGS__ )
#define enString_If(...) _enString_If( __VA_ARGS__ )
#define enString_JsonAttempt(...) _enString_JsonAttempt( __VA_ARGS__ )
#define enString_Pad(...) _enString_Pad( __VA_ARGS__ )
#define enString_MultiByteUnit(...) _enString_MultiByteUnit( __VA_ARGS__ )
#define enString_Escape(...) _enString_Escape( __VA_ARGS__ )
#define enString_ParseCfgLine(...) _enString_ParseCfgLine( __VA_ARGS__ )
#define enString_ParseVersion(...) _enString_ParseVersion( __VA_ARGS__ )
#define enString_FindChars(...) _enString_FindChars( __VA_ARGS__ )

#define enTest_Assert(...) _enTest_Assert( __VA_ARGS__ )
#define enTest_Type(...) _enTest_Type( __VA_ARGS__ )
#define enTest_Method(...) _enTest_Method( __VA_ARGS__ )
#define _enTest_Check(...) _enTest_Check( __VA_ARGS__ )
#define enTest_StopOnFail(...) _enTest_StopOnFail( __VA_ARGS__ )

#define enTimer_Start(...) _enTimer_Start( __VA_ARGS__ )
#define enTimer_Cancel(...) _enTimer_Cancel( __VA_ARGS__ )
#define enTimer_Find(...) _enTimer_Find( __VA_ARGS__ )
#define _enTimer_Check(...) _enTimer_Check( __VA_ARGS__ )
#define _enTimer_InternalLoopback(...) _enTimer_InternalLoopback( __VA_ARGS__ )
#define en_entimer(...) _enTimer_entimer( __VA_ARGS__ )

#define enVector_Compress(...) _enVector_Compress( __VA_ARGS__ )
#define enVector_Decompress(...) _enVector_Decompress( __VA_ARGS__ )
#define enVector_FromString(...) _enVector_FromString( __VA_ARGS__ )
#define enVector_RegionCornerToWorld(...) _enVector_RegionCornerToWorld( __VA_ARGS__ )
#define enVector_RegionToWorld(...) _enVector_RegionToWorld( __VA_ARGS__ )
#define enVector_Scale(...) _enVector_Scale( __VA_ARGS__ )
#define enVector_ScaleInverse(...) _enVector_Scale( __VA_ARGS__ )
#define enVector_ToString(...) _enVector_ToString( __VA_ARGS__ )
#define enVector_WorldToCorner(...) _enVector_WorldToCorner( __VA_ARGS__ )
#define enVector_WorldToRegion(...) _enVector_WorldToRegion( __VA_ARGS__ )

// ==
// == macros
// ==

#define en_imp_message(...) _en_imp_message( __VA_ARGS__ )

#define enLog_Print(...) _enLog_( 0, __LINE__, __VA_ARGS__ )
#define enLog_Fatal(...) _enLog_( 1, __LINE__, __VA_ARGS__ )
#define enLog_Error(...) _enLog_( 2, __LINE__, __VA_ARGS__ )
#define enLog_Warn(...) _enLog_( 3, __LINE__, __VA_ARGS__ )
#define enLog_Info(...) _enLog_( 4, __LINE__, __VA_ARGS__ )
#define enLog_Debug(...) _enLog_( 5, __LINE__, __VA_ARGS__ )
#define enLog_Trace(...) _enLog_( 6, __LINE__, __VA_ARGS__ )
