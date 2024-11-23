/*
    _definitions.lsl
    Library Definitions
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

    This code provides definitions used when calling Xi libraries.

    Since libraries within the Xi framework call functions from other libraries,
    these definitions need to be loaded into the preprocessor before the libraries
    themselves, or the compiler will throw errors.
*/

// ==
// == static preprocessor constants
// ==

// XiTest
#define INTEGER 0
#define FLOAT 1
#define VECTOR 2
#define ROTATION 3
#define STRING 4
#define KEY 5
#define LIST 6

// XiLog
#define PRINT 0
#define FATAL 1
#define ERROR 2
#define WARN 3
#define INFO 4
#define DEBUG 5
#define TRACE 6

#define XICHAT$LISTEN_OWNERONLY 0x1
#define XICHAT$LISTEN_REMOVE 0x80000000

#define XIOBJECT$PROFILE_EXISTS 0x80000000
#define XIOBJECT$PROFILE_PHYSICS 0x1
#define XIOBJECT$PROFILE_PHANTOM 0x2
#define XIOBJECT$PROFILE_TEMP_ON_REZ 0x4
#define XIOBJECT$PROFILE_TEMP_ATTACHED 0x8

#define XISTRING$PAD_ALIGN_LEFT 0
#define XISTRING$PAD_ALIGN_RIGHT 1
#define XISTRING$PAD_ALIGN_CENTER 2
#define XISTRING$ESCAPE_FILTER_REGEX 0x1
#define XISTRING$ESCAPE_REVERSE 0x40000000

#define XITEST$EQUAL 0
#define XITEST$NOT_EQUAL 1
#define XITEST$GREATER 2
#define XITEST$LESS 3

// ==
// == configurable preprocessor constants
// ==

#ifndef XICHAT$RESERVE_LISTENS
    #define XICHAT$RESERVE_LISTENS 0
#endif

#ifndef XICHAT$PTP_SIZE
    // note that this value is set to the maximum number of UTF-8 characters that can be sent via llRegionSayTo
    // if you are positive you will ALWAYS have ASCII-7 characters, this can be raised to 1024 for better performance and lower memory usage
    #define XICHAT$PTP_SIZE 512
#endif

#ifndef XIIMP$LINK_MESSAGE_SCOPE
    #define XIIMP$LINK_MESSAGE_SCOPE LINK_THIS
#endif

#ifndef XIINTEGER$CHARSET_16
    #define XIINTEGER$CHARSET_16 "0123456789abcdef"
#endif
#ifndef XIINTEGER$CHARSET_64
    #define XIINTEGER$CHARSET_64 "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-="
#endif
#ifndef XIINTEGER$CHARSET_256
    #define XIINTEGER$CHARSET_256 ""
#endif

#ifndef XILOG$DEFAULT_LOGLEVEL
    #define XILOG$DEFAULT_LOGLEVEL 4
#endif

#ifndef XILSD$HEADER
    #define XILSD$HEADER ""
#endif

#ifndef XIOBJECT$LIMIT_SELF
    // number of own object UUIDs to store, retrievable via XiObject$Self
    #define XIOBJECT$LIMIT_SELF 1
#endif

#ifndef XITEST$PRECISION_FLOAT
    // default exact precision for floats - adjust this in script if desired
    #define XITEST$PRECISION_FLOAT 0.0
#endif

#ifndef XITEST$PRECISION_VECTOR
    // default exact precision for vectors - adjust this in script if desired
    #define XITEST$PRECISION_VECTOR 0.0
#endif

#ifndef XITEST$PRECISION_ROTATION
    // default exact precision for vectors - adjust this in script if desired
    #define XITEST$PRECISION_ROTATION 0.0
#endif

#ifndef XITIMER$MINIMUM_INTERVAL
    #define XITIMER$MINIMUM_INTERVAL 0.1
#endif

#ifdef XI$TRACE_LIBRARIES
    #define XIAVATAR$TRACE
    #define XICHAT$TRACE
    #define XIDATE$TRACE
    #define XIFLOAT$TRACE
    #define XIHTTP$TRACE
    #define XIIMP$TRACE
    #define XIINTEGER$TRACE
    #define XIINVENTORY$TRACE
    #define XIKEY$TRACE
    #define XIKVP$TRACE
    #define XILIST$TRACE
    #define XILOG$TRACE
    #define XILSD$TRACE
    #define XIOBJECT$TRACE
    #define XIROTATION$TRACE
    #define XISTRING$TRACE
    #define XITEST$TRACE
    #define XITIMER$TRACE
    #define XIVECTOR$TRACE
#endif

#ifdef XI$TRACE_EVENT_HANDLERS
    #define XI$AT_ROT_TARGET_TRACE
    #define XI$AT_TARGET_TRACE
    #define XI$ATTACH_TRACE
    #define XI$CHANGED_TRACE
    #define XI$COLLISION_END_TRACE
    #define XI$COLLISION_START_TRACE
    #define XI$COLLISION_TRACE
    #define XI$CONTROL_TRACE
    #define XI$DATASERVER_TRACE
    #define XI$EMAIL_TRACE
    #define XI$EXPERIENCE_PERMISSIONS_DENIED_TRACE
    #define XI$EXPERIENCE_PERMISSIONS_TRACE
    #define XI$FINAL_DAMAGE_TRACE
    #define XI$GAME_CONTROL_TRACE
    #define XI$HTTP_REQUEST_TRACE
    #define XI$HTTP_RESPONSE_TRACE
    #define XI$LAND_COLLISION_END_TRACE
    #define XI$LAND_COLLISION_START_TRACE
    #define XI$LAND_COLLISION_TRACE
    #define XI$LINK_MESSAGE_TRACE
    #define XI$LISTEN_TRACE
    #define XI$MONEY_TRACE
    #define XI$MOVING_END_TRACE
    #define XI$MOVING_START_TRACE
    #define XI$NO_SENSOR_TRACE
    #define XI$NOT_AT_ROT_TARGET_TRACE
    #define XI$NOT_AT_TARGET_TRACE
    #define XI$OBJECT_REZ_TRACE
    #define XI$ON_DAMAGE_TRACE
    #define XI$ON_DEATH_TRACE
    #define XI$ON_REZ_TRACE
    #define XI$PATH_UPDATE_TRACE
    #define XI$REMOTE_DATA_TRACE
    #define XI$RUN_TIME_PERMISSIONS_TRACE
    #define XI$SENSOR_TRACE
    #define XI$STATE_ENTRY_TRACE
    #define XI$STATE_EXIT_TRACE
    #define XI$TIMER_TRACE
    #define XI$TOUCH_END_TRACE
    #define XI$TOUCH_START_TRACE
    #define XI$TOUCH_TRACE
    #define XI$TRANSACTION_RESULT_TRACE
#endif

// ==
// == functions
// ==

#define XiAvatar$Elem(...) _XiAvatar_Elem( __VA_ARGS__ )

#define XiChat$GetService(...) _XiChat_GetService( __VA_ARGS__ )
#define XiChat$SetService(...) _XiChat_SetService( __VA_ARGS__ )
#define XiChat$Channel(...) _XiChat_Channel( __VA_ARGS__ )
#define XiChat$RegionSayTo(...) _XiChat_RegionSayTo( __VA_ARGS__ )
#define XiChat$Listen(...) _XiChat_Listen( __VA_ARGS__ )
#define XiChat$Send(...) _XiChat_Send( __VA_ARGS__ )
#define XiChat$SendPTP(...) _XiChat_SendPTP( __VA_ARGS__ )
#define _XiChat$Process(...) _XiChat_Process( __VA_ARGS__ )
#define _XiChat$UnListenDomains(...) _XiChat_UnListenDomains( __VA_ARGS__ )
#define _XiChat$ListenDomains(...) _XiChat_ListenDomains( __VA_ARGS__ )
#define _XiChat$RefreshLinkset(...) _XiChat_RefreshLinkset( __VA_ARGS__ )

#define XiDate$MS(...) _XiDate_MS( __VA_ARGS__ )
#define XiDate$MSNow(...) _XiDate_MSNow( __VA_ARGS__ )
#define XiDate$MSAdd(...) _XiDate_MSAdd( __VA_ARGS__ )

#define XiFloat$ToString(...) _XiFloat_ToString( __VA_ARGS__ )
#define XiFloat$Clamp(...) _XiFloat_Clamp( __VA_ARGS__ )
#define XiFloat$FlipCoin(...) _XiFloat_FlipCoin( __VA_ARGS__ )
#define XiFloat$RandRange(...) _XiFloat_RandRange( __VA_ARGS__ )

#define XiHTTP$Request(...) _XiHTTP_Request( __VA_ARGS__ )
#define _XiHTTP$ProcessResponse(...) _XiHTTP_ProcessResponse( __VA_ARGS__ )
#define _XiHTTP$Timer(...) _XiHTTP_Timer( __VA_ARGS__ )
#define _XiHTTP$NextRequest(...) _XiHTTP_NextRequest( __VA_ARGS__ )

#define XiIMP$Send(...) _XiIMP_Send( __VA_ARGS__ )
#define _XiIMP$Process(...) _XiIMP_Process( __VA_ARGS__ )

#define XiInteger$ElemBitfield(...) _XiInteger_ElemBitfield( __VA_ARGS__ )
#define XiInteger$Rand(...) _XiInteger_Rand( __VA_ARGS__ )
#define XiInteger$ToHex(...) _XiInteger_ToHex( __VA_ARGS__ )
#define XiInteger$ToNybbles(...) _XiInteger_ToNybbles( __VA_ARGS__ )
#define XiInteger$ToString64(...) _XiInteger_ToString64( __VA_ARGS__ )
#define XiInteger$FromStr64(...) _XiInteger_FromStr64( __VA_ARGS__ )
#define XiInteger$Clamp(...) _XiInteger_Clamp( __VA_ARGS__ )
#define XiInteger$Reset(...) _XiInteger_Reset( __VA_ARGS__ )

#define XiInventory$List(...) _XiInventory_List( __VA_ARGS__ )
#define XiInventory$Copy(...) _XiInventory_Copy( __VA_ARGS__ )
#define XiInventory$OwnedByCreator(...) _XiInventory_OwnedByCreator( __VA_ARGS__ )
#define XiInventory$RezRemote(...) _XiInventory_RezRemote( __VA_ARGS__ )
#define XiInventory$NCOpen(...) _XiInventory_NCOpen( __VA_ARGS__ )
#define XiInventory$NCRead(...) _XiInventory_NCRead( __VA_ARGS__ )
#define XiInventory$TypeToString(...) _XiInventory_TypeToString( __VA_ARGS__ )
#define XiInventory$Push(...) _XiInventory_Push( __VA_ARGS__ )
#define XiInventory$Pull(...) _XiInventory_Pull( __VA_ARGS__ )

#define XiKey$Is(...) _XiKey_Is( __VA_ARGS__ )
#define XiKey$IsNotNull(...) _XiKey_IsNotNull( __VA_ARGS__ )
#define XiKey$IsNull(...) _XiKey_IsNull( __VA_ARGS__ )
#define XiKey$IsInRegion(...) _XiKey_IsInRegion( __VA_ARGS__ )
#define XiKey$IsAvatarInRegion(...) _XiKey_IsAvatarInRegion( __VA_ARGS__ )
#define XiKey$IsPrimInRegion(...) _XiKey_IsPrimInRegion( __VA_ARGS__ )
#define XiKey$Strip(...) _XiKey_Strip( __VA_ARGS__ )
#define XiKey$Unstrip(...) _XiKey_Unstrip( __VA_ARGS__ )
#define XiKey$Compress(...) _XiKey_Compress( __VA_ARGS__ )
#define XiKey$Decompress(...) _XiKey_Decompress( __VA_ARGS__ )

#define XiKVP$Exists(...) _XiKVP_Exists( __VA_ARGS__ )
#define XiKVP$Write(...) _XiKVP_Write( __VA_ARGS__ )
#define XiKVP$Read(...) _XiKVP_Read( __VA_ARGS__ )
#define XiKVP$Delete(...) _XiKVP_Delete( __VA_ARGS__ )

#define XiList$DeleteStrideByMatch(...) _XiList_DeleteStrideByMatch( __VA_ARGS__ )
#define XiList$Elem(...) _XiList_Elem( __VA_ARGS__ )
#define XiList$Empty(...) _XiList_Empty( __VA_ARGS__ )
#define XiList$Collate(...) _XiList_Collate( __VA_ARGS__ )
#define XiList$Concatenate(...) _XiList_Concatenate( __VA_ARGS__ )
#define XiList$ToString(...) _XiList_ToString( __VA_ARGS__ )
#define XiList$FromStr(...) _XiList_FromStr( __VA_ARGS__ )
#define XiList$FindPartial(...) _XiList_FindPartial( __VA_ARGS__ )

#define XiLog$(...) _XiLog_( __VA_ARGS__ )
#define XiLog$FatalStop(...) _XiLog_FatalStop( __VA_ARGS__ )
#define XiLog$FatalDelete(...) _XiLog_FatalDelete( __VA_ARGS__ )
#define XiLog$FatalDie(...) _XiLog_FatalDie_( __VA_ARGS__ )
#define XiLog$LevelToString(...) _XiLog_LevelToString( __VA_ARGS__ )
#define XiLog$StringToLevel(...) _XiLog_StringToLevel( __VA_ARGS__ )
#define XiLog$TraceParams(...) _XiLog_TraceParams( __VA_ARGS__ )
#define XiLog$TraceVars(...) _XiLog_TraceVars( __VA_ARGS__ )
#define XiLog$GetLoglevel(...) _XiLog_GetLoglevel( __VA_ARGS__ )
#define XiLog$SetLoglevel(...) _XiLog_SetLoglevel( __VA_ARGS__ )
#define XiLog$GetLogtarget(...) _XiLog_GetLogtarget( __VA_ARGS__ )
#define XiLog$SetLogtarget(...) _XiLog_SetLogtarget( __VA_ARGS__ )

#define XiLSD$Reset(...) _XiLSD_Reset( __VA_ARGS__ )
#define XiLSD$Write(...) _XiLSD_Write( __VA_ARGS__ )
#define XiLSD$Read(...) _XiLSD_Read( __VA_ARGS__ )
#define XiLSD$Delete(...) _XiLSD_Delete( __VA_ARGS__ )
#define XiLSD$Find(...) _XiLSD_Find( __VA_ARGS__ )
#define XiLSD$Head(...) _XiLSD_Head( __VA_ARGS__ )
#define XiLSD$Pull(...) _XiLSD_Pull( __VA_ARGS__ )
#define XiLSD$Push(...) _XiLSD_Push( __VA_ARGS__ )
#define _XiLSD$Process(...) _XiLSD_Process( __VA_ARGS__ )
#define _XiLSD$CheckUUID(...) _XiLSD_CheckUUID( __VA_ARGS__ )

#define XiObject$Elem(...) _XiObject_Elem( __VA_ARGS__ )
#define XiObject$Self(...) _XiObject_Self( __VA_ARGS__ )
#define XiObject$Parent(...) _XiObject_Parent( __VA_ARGS__ )
#define XiObject$StopIfOwnerRezzed(...) _XiObject_StopIfOwnerRezzed( __VA_ARGS__ )
#define XiObject$ClosestLink(...) _XiObject_ClosestLink( __VA_ARGS__ )
#define XiObject$Profile(...) _XiObject_Profile( __VA_ARGS__ )
#define _XiObject$UpdateUUIDs(...) _XiObject_UpdateUUIDs( __VA_ARGS__ )

#define XiRotation$Elem(...) _XiRotation_Elem( __VA_ARGS__ )
#define XiRotation$Normalize(...) _XiRotation_Normalize( __VA_ARGS__ )
#define XiRotation$Slerp(...) _XiRotation_Slerp( __VA_ARGS__ )
#define XiRotation$Nlerp(...) _XiRotation_Nlerp( __VA_ARGS__ )

#define XiString$Elem(...) _XiString_Elem( __VA_ARGS__ )
#define XiString$Plural(...) _XiString_Plural( __VA_ARGS__ )
#define XiString$If(...) _XiString_If( __VA_ARGS__ )
#define XiString$Pad(...) _XiString_Pad( __VA_ARGS__ )
#define XiString$MultiByteUnit(...) _XiString_MultiByteUnit( __VA_ARGS__ )
#define XiString$Escape(...) _XiString_Escape( __VA_ARGS__ )
#define XiString$ParseCfgLine(...) _XiString_ParseCfgLine( __VA_ARGS__ )
#define XiString$FindChars(...) _XiString_FindChars( __VA_ARGS__ )

#define XiTest$Assert(...) _XiTest_Assert( __VA_ARGS__ )
#define XiTest$Type(...) _XiTest_Type( __VA_ARGS__ )
#define XiTest$Method(...) _XiTest_Method( __VA_ARGS__ )
#define _XiTest$Check(...) _XiTest_Check( __VA_ARGS__ )
#define XiTest$StopOnFail(...) _XiTest_StopOnFail( __VA_ARGS__ )

#define XiTimer$Start(...) _XiTimer_Start( __VA_ARGS__ )
#define XiTimer$Cancel(...) _XiTimer_Cancel( __VA_ARGS__ )
#define XiTimer$Find(...) _XiTimer_Find( __VA_ARGS__ )
#define _XiTimer$Check(...) _XiTimer_Check( __VA_ARGS__ )

#define XiVector$RegionCornerToWorld(...) _XiVector_RegionCornerToWorld( __VA_ARGS__ )
#define XiVector$RegionToWorld(...) _XiVector_RegionToWorld( __VA_ARGS__ )
#define XiVector$ToString(...) _XiVector_ToString( __VA_ARGS__ )
#define XiVector$WorldToCorner(...) _XiVector_WorldToCorner( __VA_ARGS__ )
#define XiVector$WorldToRegion(...) _XiVector_WorldToRegion( __VA_ARGS__ )

// ==
// == macros
// ==

#define Xi$imp_message(...) _Xi_imp_message( __VA_ARGS__ )

#define XiLog$Print(...) _XiLog_( 0, __VA_ARGS__ )
#define XiLog$Fatal(...) _XiLog_( 1, __VA_ARGS__ )
#define XiLog$Error(...) _XiLog_( 2, __VA_ARGS__ )
#define XiLog$Warn(...) _XiLog_( 3, __VA_ARGS__ )
#define XiLog$Info(...) _XiLog_( 4, __VA_ARGS__ )
#define XiLog$Debug(...) _XiLog_( 5, __VA_ARGS__ )
#define XiLog$Trace(...) _XiLog_( 6, __VA_ARGS__ )
