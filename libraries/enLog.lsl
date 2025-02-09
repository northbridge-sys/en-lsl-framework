/*
    enLog.lsl
    Library
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

    This is an LSL preprocessor include file that implements a set of fleenble
    logging functions that can output different loglevels via llOwnerSay and,
    optionally, via enCLEP to a specified UUID and service.
*/

// ==
// == macros
// ==

#define enLog_TraceVars(var_names, var_values) \
    enLog_TraceParams("enLog_TraceVars", var_names, var_values)

#define enLog_GetLogtarget() \
    llLinksetDataRead("logtarget")

#define enLog_SetLogtarget(target) \
    llLinksetDataWrite("logtarget", target)

// ==
// == functions
// ==

enLog_To(
    integer level,
    integer line,
    string target, // note - this is NOT related to the "logtarget" check
    string message
    )
{
    // can use level 0 to always send, or a level constant for loglevel support
    integer lsd_level = enLog_GetLoglevel();
    string debug_header;
    if (lsd_level >= 5) debug_header = "🔽 [" + llGetSubString(llGetTimestamp(), 11, 21) + "] (" + (string)((integer)((100.0 * llGetUsedMemory()) / llGetMemoryLimit())) + "% " + llGetSubString(llGetKey(), 0, 3) + " @" + (string)line + ") " + llGetScriptName() + "\n";
    if ( lsd_level >= level )
    {
        message = debug_header + llList2String([ // loglevel header, usually an icon but can be anything
            "", // no level
            "🛑 FATAL ERROR: ", // FATAL
            "❌ ERROR: ", // ERROR
            "🚩 WARNING: ", // WARN
            "💬 ", // INFO
            "🪲 ", // DEBUG
            "🚦 " // TRACE
            ], level) + message;
        if ((integer)llLinksetDataRead("logsay")) llSay((integer)llLinksetDataRead("logchannel"), message); // always check logsay for last-resort llSay logging
        if (target == "") llOwnerSay(message); // target to owner
        else llRegionSayTo(target, 0, message); // log to specific user
    }
    #ifndef ENLOG_DISABLE_LOGTARGET
        string t = enLog_GetLogtarget();
        string prim = llGetSubString( t, 0, 35 );
        if ( enKey_IsPrimInRegion( prim ) )
        { // log via enCLEP to logtarget
            string domain = llDeleteSubString( t, 0, 35 );
            enCLEP_MultiSayTo( prim, enCLEP_Channel( domain ), enList_ToString([ "enCLEP", enCLEP_GetService(), prim, domain, "enLog", enList_ToString([llGetTimestamp(), llGetUsedMemory(), llGetMemoryLimit(), llGetKey(), llGetScriptName(), level, line, message]) ] ) );
        }
    #endif
}

enLog_SuccessStop( // logs a success and stops the script
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Script stopped:" + m);
    llSetScriptState(llGetScriptName(), FALSE);
    llSleep(1.0); // give the simulator time to stop the script to be safe
}

enLog_SuccessDelete( // logs a success and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Script deleted:" + m);
    enLog_Delete();
}

enLog_SuccessDie( // logs a success and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Object " + llList2String(["deleted", "detached from " + enObject_GetAttachedString(llGetAttached())], !!llGetAttached()) + ":" + m);
    enLog_Die();
}

enLog_FatalStop( // logs a fatal error and stops the script
    string m // message
    )
{
    if (m != "") m = " " + m;
    enLog_Fatal("Script stopped:" + m);
    llSetScriptState(llGetScriptName(), FALSE);
    llSleep(1.0); // give the simulator time to stop the script to be safe
}

enLog_FatalDelete( // logs a fatal error and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Fatal("Script deleted:" + m);
    enLog_Delete();
}

enLog_FatalDie( // logs a fatal error and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Fatal("Object " + llList2String(["deleted", "detached from " + enObject_GetAttachedString(llGetAttached())], !!llGetAttached()) + ":" + m);
    enLog_Die();
}

enLog_Delete() // deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
{
    // remove inventory if ENLOG_ENABLE_DELETE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef ENLOG_ENABLE_DELETE_OWNEDBYCREATOR
        if ( enInventory_OwnedByCreator( llGetScriptName() ) ) enLog_Error("Script deletion failed because ENLOG_ENABLE_DELETE_OWNEDBYCREATOR is not defined.");
        else
    #endif
    // only remove inventory if ENLOG_DISABLE_DELETE is NOT defined
    #if defined ENLOG_DISABLE_DELETE
        enLog_Error("Script deletion failed because ENLOG_DISABLE_DELETE is defined.");
    #else
        llRemoveInventory(llGetScriptName());
    #endif
    llSetScriptState(llGetScriptName(), FALSE);
    llSleep(1.0); // give the simulator time to stop and delete the script to be safe
}

enLog_Die() // deletes the OBJECT (or, if it is attached, detaches it) (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
{
    // delete object if ENLOG_ENABLE_DIE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef ENLOG_ENABLE_DIE_OWNEDBYCREATOR
        if ( enInventory_OwnedByCreator( llGetScriptName() ) ) enLog_Error("Object delete/detach failed because ENLOG_ENABLE_DIE_OWNEDBYCREATOR is not defined.");
        else
    #endif
    // only delete object if ENLOG_DISABLE_DIE is NOT defined
    #if defined ENLOG_DISABLE_DIE
        enLog_Error("Object delete/detach failed because ENLOG_DISABLE_DIE is defined.");
    #else
        {
            if (llGetAttached()) llDetachFromAvatar();
            else llDie();
        }
    #endif
    llSetScriptState( llGetScriptName(), FALSE );
    llSleep( 1.0 ); // give the simulator time to remove the object to be safe
}

string enLog_LevelToString( // converts integer level number into string representation
    integer l
    )
{
    return llList2String( [
        "0",
        "FATAL",
        "ERROR",
        "WARN",
        "INFO",
        "DEBUG",
        "TRACE",
        "UNKNOWN_LEVEL_" + (string)l
        ], l );
}

integer enLog_StringToLevel( // converts integer level number into string representation
    string s
    )
{
    return llListFindList( [
        "FATAL",
        "ERROR",
        "WARN",
        "INFO",
        "DEBUG",
        "TRACE"
        ], [ llToUpper( llStringTrim( s, STRING_TRIM ) ) ] ) + 1;
}

enLog_TraceParams( string function_name, list param_names, list param_values )
{
    string params;
    if ( param_values != [] ) params = "\n        " + llDumpList2String( enList_Concatenate( "", param_names, " = ", param_values, "" ), ",\n        " ) + "\n    ";
    enLog_Trace( function_name + "(" + params + ")" );
}

integer enLog_GetLoglevel()
{
    string lsd = llLinksetDataRead( "loglevel" ); // any valid log level number, 0 (uses default), or negative (suppresses all output)
    if ( (integer)lsd ) return (integer)lsd;
    else return ENLOG_DEFAULT_LOGLEVEL;
}

enLog_SetLoglevel(
    integer level
)
{
    if ( level < FATAL || level > TRACE ) return;
    llLinksetDataWrite( "loglevel", (string)level );
}
