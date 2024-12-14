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

#define ENCLEP$LISTEN_OWNERONLY 0x1
#define ENCLEP$LISTEN_REMOVE 0x80000000

#define ENLEP$TYPE_REQUEST 0x1
#define ENLEP$TYPE_RESPONSE 0x2
#define ENLEP$STATUS_ERROR 0x4

#define ENOBJECT$PROFILE_EENSTS 0x80000000
#define ENOBJECT$PROFILE_PHYSICS 0x1
#define ENOBJECT$PROFILE_PHANTOM 0x2
#define ENOBJECT$PROFILE_TEMP_ON_REZ 0x4
#define ENOBJECT$PROFILE_TEMP_ATTACHED 0x8
#define ENOBJECT$TEXT_SUCCESS 0x10
#define ENOBJECT$TEXT_BUSY 0x20
#define ENOBJECT$TEXT_PROMPT 0x40
#define ENOBJECT$TEXT_ERROR 0x80
#define ENOBJECT$TEXT_TEMP 0x100
#define ENOBJECT$TEXT_PROGRESS_NC 0x200
#define ENOBJECT$TEXT_PROGRESS_THROB 0x400

#define ENSTRING$PAD_ALIGN_LEFT 0
#define ENSTRING$PAD_ALIGN_RIGHT 1
#define ENSTRING$PAD_ALIGN_CENTER 2
#define ENSTRING$ESCAPE_FILTER_REGEX 0x1
#define ENSTRING$ESCAPE_FILTER_JSON 0x2
#define ENSTRING$ESCAPE_REVERSE 0x40000000

#define ENTEST$EQUAL 0
#define ENTEST$NOT_EQUAL 1
#define ENTEST$GREATER 2
#define ENTEST$LESS 3

// ==
// == configurable preprocessor constants
// ==

#ifndef ENCLEP$RESERVE_LISTENS
    #define ENCLEP$RESERVE_LISTENS 0
#endif

#ifndef ENCLEP$PTP_SIZE
    // note that this value is set to the maximum number of UTF-8 characters that can be sent via llRegionSayTo
    // if you are positive you will ALWAYS have ASCII-7 characters, this can be raised to 1024 for better performance and lower memory usage
    #define ENCLEP$PTP_SIZE 512
#endif

#ifndef ENLEP$LINK_MESSAGE_SCOPE
    #define ENLEP$LINK_MESSAGE_SCOPE LINK_THIS
#endif

#ifndef ENINTEGER$CHARSET_16
    #define ENINTEGER$CHARSET_16 "0123456789abcdef"
#endif
#ifndef ENINTEGER$CHARSET_64
    #define ENINTEGER$CHARSET_64 "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-="
#endif
#ifndef ENINTEGER$CHARSET_256
    #define ENINTEGER$CHARSET_256 ""
#endif

#ifndef ENLOG$DEFAULT_LOGLEVEL
    #define ENLOG$DEFAULT_LOGLEVEL 4
#endif

#ifndef ENLSD$HEADER
    #define ENLSD$HEADER ""
#endif

#ifndef ENOBJECT$LIMIT_SELF
    // number of own object UUIDs to store, retrievable via enObject$Self
    #define ENOBJECT$LIMIT_SELF 2
#endif

#ifndef ENTEST$PRECISION_FLOAT
    // default exact precision for floats - adjust this in script if desired
    #define ENTEST$PRECISION_FLOAT 0.0
#endif

#ifndef ENTEST$PRECISION_VECTOR
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST$PRECISION_VECTOR 0.0
#endif

#ifndef ENTEST$PRECISION_ROTATION
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST$PRECISION_ROTATION 0.0
#endif

#ifndef ENTIMER$MINIMUM_INTERVAL
    #define ENTIMER$MINIMUM_INTERVAL 0.1
#endif

#ifdef EN$TRACE_LIBRARIES
    #define ENAVATAR$TRACE
    #define ENCLEP$TRACE
    #define ENDATE$TRACE
    #define ENFLOAT$TRACE
    #define ENHTTP$TRACE
    #define ENLEP$TRACE
    #define ENINTEGER$TRACE
    #define ENINVENTORY$TRACE
    #define ENKEY$TRACE
    #define ENKVP$TRACE
    #define ENLIST$TRACE
    #define ENLOG$TRACE
    #define ENLSD$TRACE
    #define ENOBJECT$TRACE
    #define ENROTATION$TRACE
    #define ENSTRING$TRACE
    #define ENTEST$TRACE
    #define ENTIMER$TRACE
    #define ENVECTOR$TRACE
#endif

#ifdef EN$TRACE_EVENT_HANDLERS
    #define EN$AT_ROT_TARGET_TRACE
    #define EN$AT_TARGET_TRACE
    #define EN$ATTACH_TRACE
    #define EN$CHANGED_TRACE
    #define EN$COLLISION_END_TRACE
    #define EN$COLLISION_START_TRACE
    #define EN$COLLISION_TRACE
    #define EN$CONTROL_TRACE
    #define EN$DATASERVER_TRACE
    #define EN$EMAIL_TRACE
    #define EN$EXPERIENCE_PERMISSIONS_DENIED_TRACE
    #define EN$EXPERIENCE_PERMISSIONS_TRACE
    #define EN$FINAL_DAMAGE_TRACE
    #define EN$GAME_CONTROL_TRACE
    #define EN$HTTP_REQUEST_TRACE
    #define EN$HTTP_RESPONSE_TRACE
    #define EN$LAND_COLLISION_END_TRACE
    #define EN$LAND_COLLISION_START_TRACE
    #define EN$LAND_COLLISION_TRACE
    #define EN$LINK_MESSAGE_TRACE
    #define EN$LISTEN_TRACE
    #define EN$MONEY_TRACE
    #define EN$MOVING_END_TRACE
    #define EN$MOVING_START_TRACE
    #define EN$NO_SENSOR_TRACE
    #define EN$NOT_AT_ROT_TARGET_TRACE
    #define EN$NOT_AT_TARGET_TRACE
    #define EN$OBJECT_REZ_TRACE
    #define EN$ON_DAMAGE_TRACE
    #define EN$ON_DEATH_TRACE
    #define EN$ON_REZ_TRACE
    #define EN$PATH_UPDATE_TRACE
    #define EN$REMOTE_DATA_TRACE
    #define EN$RUN_TIME_PERMISSIONS_TRACE
    #define EN$SENSOR_TRACE
    #define EN$STATE_ENTRY_TRACE
    #define EN$STATE_EENT_TRACE
    #define EN$TIMER_TRACE
    #define EN$TOUCH_END_TRACE
    #define EN$TOUCH_START_TRACE
    #define EN$TOUCH_TRACE
    #define EN$TRANSACTION_RESULT_TRACE
#endif

// ==
// == functions
// ==

#define enAvatar$Elem(...) _enAvatar_Elem( __VA_ARGS__ )
#define enAvatar$GetGroup(...) _enAvatar_GetGroup( __VA_ARGS__ )

#define enCLEP$GetService(...) _enCLEP_GetService( __VA_ARGS__ )
#define enCLEP$SetService(...) _enCLEP_SetService( __VA_ARGS__ )
#define enCLEP$Channel(...) _enCLEP_Channel( __VA_ARGS__ )
#define enCLEP$RegionSayTo(...) _enCLEP_RegionSayTo( __VA_ARGS__ )
#define enCLEP$Listen(...) _enCLEP_Listen( __VA_ARGS__ )
#define enCLEP$Send(...) _enCLEP_Send( __VA_ARGS__ )
#define enCLEP$SendLEP(...) _enCLEP_SendLEP(__VA_ARGS__)
#define enCLEP$SendPTP(...) _enCLEP_SendPTP( __VA_ARGS__ )
#define enCLEP$Process(...) _enCLEP_Process( __VA_ARGS__ )
#define enCLEP$UnListenDomains(...) _enCLEP_UnListenDomains( __VA_ARGS__ )
#define enCLEP$ListenDomains(...) _enCLEP_ListenDomains( __VA_ARGS__ )
#define enCLEP$RefreshLinkset(...) _enCLEP_RefreshLinkset( __VA_ARGS__ )

#define enDate$MS(...) _enDate_MS( __VA_ARGS__ )
#define enDate$MSNow(...) _enDate_MSNow( __VA_ARGS__ )
#define enDate$MSAdd(...) _enDate_MSAdd( __VA_ARGS__ )

#define enFloat$ToString(...) _enFloat_ToString( __VA_ARGS__ )
#define enFloat$Clamp(...) _enFloat_Clamp( __VA_ARGS__ )
#define enFloat$Compress(...) _enFloat_Compress( __VA_ARGS__ )
#define enFloat$Decompress(...) _enFloat_Decompress( __VA_ARGS__ )
#define enFloat$FlipCoin(...) _enFloat_FlipCoin( __VA_ARGS__ )
#define enFloat$RandRange(...) _enFloat_RandRange( __VA_ARGS__ )

#define enHTTP$Request(...) _enHTTP_Request( __VA_ARGS__ )
#define _enHTTP$ProcessResponse(...) _enHTTP_ProcessResponse( __VA_ARGS__ )
#define _enHTTP$Timer(...) _enHTTP_Timer( __VA_ARGS__ )
#define _enHTTP$NextRequest(...) _enHTTP_NextRequest( __VA_ARGS__ )

#define enInteger$ElemBitfield(...) _enInteger_ElemBitfield( __VA_ARGS__ )
#define enInteger$Rand(...) _enInteger_Rand( __VA_ARGS__ )
#define enInteger$ToHex(...) _enInteger_ToHex( __VA_ARGS__ )
#define enInteger$ToNybbles(...) _enInteger_ToNybbles( __VA_ARGS__ )
#define enInteger$ToString64(...) _enInteger_ToString64( __VA_ARGS__ )
#define enInteger$FromStr64(...) _enInteger_FromStr64( __VA_ARGS__ )
#define enInteger$Clamp(...) _enInteger_Clamp( __VA_ARGS__ )
#define enInteger$Reset(...) _enInteger_Reset( __VA_ARGS__ )

#define enInventory$List(...) _enInventory_List( __VA_ARGS__ )
#define enInventory$Copy(...) _enInventory_Copy( __VA_ARGS__ )
#define enInventory$OwnedByCreator(...) _enInventory_OwnedByCreator( __VA_ARGS__ )
#define enInventory$RezRemote(...) _enInventory_RezRemote( __VA_ARGS__ )
#define enInventory$NCOpen(...) _enInventory_NCOpen( __VA_ARGS__ )
#define enInventory$NCOpenByPartialName(...) _enInventory_NCOpenByPartialName( __VA_ARGS__ )
#define _enInventory$NCParse(...) _enInventory_NCParse( __VA_ARGS__ )
#define enInventory$NCRead(...) _enInventory_NCRead( __VA_ARGS__ )
#define enInventory$TypeToString(...) _enInventory_TypeToString( __VA_ARGS__ )
#define enInventory$Push(...) _enInventory_Push( __VA_ARGS__ )
#define enInventory$Pull(...) _enInventory_Pull( __VA_ARGS__ )
#define en$nc_line(...) _enInventory_nc_line( __VA_ARGS__ )

#define enKey$Is(...) _enKey_Is( __VA_ARGS__ )
#define enKey$IsNotNull(...) _enKey_IsNotNull( __VA_ARGS__ )
#define enKey$IsNull(...) _enKey_IsNull( __VA_ARGS__ )
#define enKey$IsInRegion(...) _enKey_IsInRegion( __VA_ARGS__ )
#define enKey$IsAvatarInRegion(...) _enKey_IsAvatarInRegion( __VA_ARGS__ )
#define enKey$IsPrimInRegion(...) _enKey_IsPrimInRegion( __VA_ARGS__ )
#define enKey$Strip(...) _enKey_Strip( __VA_ARGS__ )
#define enKey$Unstrip(...) _enKey_Unstrip( __VA_ARGS__ )
#define enKey$Compress(...) _enKey_Compress( __VA_ARGS__ )
#define enKey$Decompress(...) _enKey_Decompress( __VA_ARGS__ )

#define enKVP$Exists(...) _enKVP_Exists( __VA_ARGS__ )
#define enKVP$Write(...) _enKVP_Write( __VA_ARGS__ )
#define enKVP$Read(...) _enKVP_Read( __VA_ARGS__ )
#define enKVP$Delete(...) _enKVP_Delete( __VA_ARGS__ )
#define enKVP$Reset(...) _enKVP_Reset(__VA_ARGS__)

#define enLEP$Process(...) _enLEP_Process( __VA_ARGS__ )
#define enLEP$Send(...) _enLEP_Send( __VA_ARGS__ )
#define enLEP$SendAs(...) _enLEP_SendAs(__VA_ARGS__)

#define enList$Collate(...) _enList_Collate( __VA_ARGS__ )
#define enList$Concatenate(...) _enList_Concatenate( __VA_ARGS__ )
#define enList$DeleteStrideByMatch(...) _enList_DeleteStrideByMatch( __VA_ARGS__ )
#define enList$Elem(...) _enList_Elem( __VA_ARGS__ )
#define enList$Empty(...) _enList_Empty( __VA_ARGS__ )
#define enList$FromString(...) _enList_FromStr( __VA_ARGS__ )
#define enList$FindPartial(...) _enList_FindPartial( __VA_ARGS__ )
#define enList$ReplaceExact(...) _enList_ReplaceExact(__VA_ARGS__)
#define enList$Reverse(...) _enList_Reverse( __VA_ARGS__ )
#define enList$ToJson(...) _enList_ToJson( __VA_ARGS__ )
#define enList$ToString(...) _enList_ToString( __VA_ARGS__ )

#define enLog$(...) _enLog_( __VA_ARGS__ )
#define enLog$Die(...) _enLog_Die( __VA_ARGS__ )
#define enLog$Delete(...) _enLog_Delete( __VA_ARGS__ )
#define enLog$FatalStop(...) _enLog_FatalStop( __VA_ARGS__ )
#define enLog$FatalDelete(...) _enLog_FatalDelete( __VA_ARGS__ )
#define enLog$FatalDie(...) _enLog_FatalDie_( __VA_ARGS__ )
#define enLog$LevelToString(...) _enLog_LevelToString( __VA_ARGS__ )
#define enLog$StringToLevel(...) _enLog_StringToLevel( __VA_ARGS__ )
#define enLog$TraceParams(...) _enLog_TraceParams( __VA_ARGS__ )
#define enLog$TraceVars(...) _enLog_TraceVars( __VA_ARGS__ )
#define enLog$GetLoglevel(...) _enLog_GetLoglevel( __VA_ARGS__ )
#define enLog$SetLoglevel(...) _enLog_SetLoglevel( __VA_ARGS__ )
#define enLog$GetLogtarget(...) _enLog_GetLogtarget( __VA_ARGS__ )
#define enLog$SetLogtarget(...) _enLog_SetLogtarget( __VA_ARGS__ )
#define enLog$To(...) _enLog_To( __VA_ARGS__ )

#define enLSD$Reset(...) _enLSD_Reset( __VA_ARGS__ )
#define enLSD$Write(...) _enLSD_Write( __VA_ARGS__ )
#define enLSD$Read(...) _enLSD_Read( __VA_ARGS__ )
#define enLSD$Delete(...) _enLSD_Delete( __VA_ARGS__ )
#define enLSD$Exists(...) _enLSD_Exists( __VA_ARGS__ )
#define enLSD$Find(...) _enLSD_Find( __VA_ARGS__ )
#define enLSD$BuildHead(...) _enLSD_BuildHead( __VA_ARGS__ )
#define enLSD$Pull(...) _enLSD_Pull( __VA_ARGS__ )
#define enLSD$Push(...) _enLSD_Push( __VA_ARGS__ )
#define enLSD$Process(...) _enLSD_Process( __VA_ARGS__ )
#define enLSD$CheckUUID(...) _enLSD_CheckUUID( __VA_ARGS__ )
#define enLSD$CheckScriptName(...) _enLSD_CheckScriptName(__VA_ARGS__)
#define enLSD$MoveAllPairs(...) _enLSD_MoveAllPairs(__VA_ARGS__)
#define enLSD$GetPairHead(...) _enLSD_GetPairHead(__VA_ARGS__)

#define enObject$CacheClosestLink(...) _enObject_CacheClosestLink( __VA_ARGS__ )
#define enObject$ClosestLink(...) _enObject_ClosestLink( __VA_ARGS__ )
#define enObject$ClosestLinkDesc(...) _enObject_ClosestLinkDesc( __VA_ARGS__ )
#define enObject$Elem(...) _enObject_Elem( __VA_ARGS__ )
#define _enObject$FindLink(...) _enObject_FindLink( __VA_ARGS__ )
#define enObject$GetAttachedString(...) _enObject_GetAttachedString( __VA_ARGS__ )
#define _enObject$LinkCacheUpdate(...) _enObject_LinkCacheUpdate( __VA_ARGS__ )
#define enObject$Self(...) _enObject_Self( __VA_ARGS__ )
#define enObject$Parent(...) _enObject_Parent( __VA_ARGS__ )
#define enObject$StopIfOwnerRezzed(...) _enObject_StopIfOwnerRezzed( __VA_ARGS__ )
#define enObject$Profile(...) _enObject_Profile( __VA_ARGS__ )
#define enObject$Text(...) _enObject_Text( __VA_ARGS__ )
#define _enObject$TextTemp(...) _enObject_TextTemp( __VA_ARGS__ )
#define _enObject$UpdateUUIDs(...) _enObject_UpdateUUIDs( __VA_ARGS__ )

#define enRotation$Compress(...) _enRotation_Compress( __VA_ARGS__ )
#define enRotation$Decompress(...) _enRotation_Decompress( __VA_ARGS__ )
#define enRotation$Elem(...) _enRotation_Elem( __VA_ARGS__ )
#define enRotation$FromString(...) _enRotation_FromString( __VA_ARGS__ )
#define enRotation$Normalize(...) _enRotation_Normalize( __VA_ARGS__ )
#define enRotation$Slerp(...) _enRotation_Slerp( __VA_ARGS__ )
#define enRotation$Nlerp(...) _enRotation_Nlerp( __VA_ARGS__ )

#define enString$Elem(...) _enString_Elem( __VA_ARGS__ )
#define enString$Plural(...) _enString_Plural( __VA_ARGS__ )
#define enString$If(...) _enString_If( __VA_ARGS__ )
#define enString$JsonAttempt(...) _enString_JsonAttempt( __VA_ARGS__ )
#define enString$Pad(...) _enString_Pad( __VA_ARGS__ )
#define enString$MultiByteUnit(...) _enString_MultiByteUnit( __VA_ARGS__ )
#define enString$Escape(...) _enString_Escape( __VA_ARGS__ )
#define enString$ParseCfgLine(...) _enString_ParseCfgLine( __VA_ARGS__ )
#define enString$ParseVersion(...) _enString_ParseVersion( __VA_ARGS__ )
#define enString$FindChars(...) _enString_FindChars( __VA_ARGS__ )

#define enTest$Assert(...) _enTest_Assert( __VA_ARGS__ )
#define enTest$Type(...) _enTest_Type( __VA_ARGS__ )
#define enTest$Method(...) _enTest_Method( __VA_ARGS__ )
#define _enTest$Check(...) _enTest_Check( __VA_ARGS__ )
#define enTest$StopOnFail(...) _enTest_StopOnFail( __VA_ARGS__ )

#define enTimer$Start(...) _enTimer_Start( __VA_ARGS__ )
#define enTimer$Cancel(...) _enTimer_Cancel( __VA_ARGS__ )
#define enTimer$Find(...) _enTimer_Find( __VA_ARGS__ )
#define _enTimer$Check(...) _enTimer_Check( __VA_ARGS__ )
#define _enTimer$InternalLoopback(...) _enTimer_InternalLoopback( __VA_ARGS__ )
#define en$entimer(...) _enTimer_entimer( __VA_ARGS__ )

#define enVector$Compress(...) _enVector_Compress( __VA_ARGS__ )
#define enVector$Decompress(...) _enVector_Decompress( __VA_ARGS__ )
#define enVector$FromString(...) _enVector_FromString( __VA_ARGS__ )
#define enVector$RegionCornerToWorld(...) _enVector_RegionCornerToWorld( __VA_ARGS__ )
#define enVector$RegionToWorld(...) _enVector_RegionToWorld( __VA_ARGS__ )
#define enVector$Scale(...) _enVector_Scale( __VA_ARGS__ )
#define enVector$ScaleInverse(...) _enVector_Scale( __VA_ARGS__ )
#define enVector$ToString(...) _enVector_ToString( __VA_ARGS__ )
#define enVector$WorldToCorner(...) _enVector_WorldToCorner( __VA_ARGS__ )
#define enVector$WorldToRegion(...) _enVector_WorldToRegion( __VA_ARGS__ )

// ==
// == macros
// ==

#define en$imp_message(...) _en_imp_message( __VA_ARGS__ )

#define enLog$Print(...) _enLog_( 0, __LINE__, __VA_ARGS__ )
#define enLog$Fatal(...) _enLog_( 1, __LINE__, __VA_ARGS__ )
#define enLog$Error(...) _enLog_( 2, __LINE__, __VA_ARGS__ )
#define enLog$Warn(...) _enLog_( 3, __LINE__, __VA_ARGS__ )
#define enLog$Info(...) _enLog_( 4, __LINE__, __VA_ARGS__ )
#define enLog$Debug(...) _enLog_( 5, __LINE__, __VA_ARGS__ )
#define enLog$Trace(...) _enLog_( 6, __LINE__, __VA_ARGS__ )
