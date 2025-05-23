/*
enLog.lsl
Library Functions
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
*/

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
            enCLEP_Send(
                "enLog",
                prim,
                domain,
                "",
                0,
                [level, line, llGetTimestamp(), llGetUsedMemory(), llGetMemoryLimit(), llGetKey(), llGetScriptName()],
                message
            );
        }
    #endif
}

// logs a success and stops the script
enLog_SuccessStop(
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Script stopped:" + m);
    llSetScriptState(llGetScriptName(), FALSE);
    llSleep(1.0); // give the simulator time to stop the script to be safe
}

// logs a success and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
enLog_SuccessDelete(
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Script deleted:" + m);
    enLog_Delete();
}

// logs a success and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
enLog_SuccessDie(
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Print("✅ SUCCESS: Object " + llList2String(["deleted", "detached from " + enObject_GetAttachedString(llGetAttached())], !!llGetAttached()) + ":" + m);
    enLog_Die();
}

// logs a fatal error and stops the script
enLog_FatalStop(
    string m // message
    )
{
    if (m != "") m = " " + m;
    enLog_Fatal("Script stopped:" + m);
    llSetScriptState(llGetScriptName(), FALSE);
    llSleep(1.0); // give the simulator time to stop the script to be safe
}

// logs a fatal error and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
enLog_FatalDelete(
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Fatal("Script deleted:" + m);
    enLog_Delete();
}

// logs a fatal error and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
enLog_FatalDie(
    string m // message
)
{
    if (m != "") m = " " + m;
    enLog_Fatal("Object " + llList2String(["deleted", "detached from " + enObject_GetAttachedString(llGetAttached())], !!llGetAttached()) + ":" + m);
    enLog_Die();
}

// deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
enLog_Delete()
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

// deletes the OBJECT (or, if it is attached, detaches it) (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
enLog_Die()
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

// converts integer level number into string representation
string enLog_LevelToString(
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

// converts integer level number into string representation
integer enLog_StringToLevel(
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

// can't do this as a macro because of lists
enLog_Vars(
    integer level,
    list var_names,
    list var_values
    )
{
    enLog_Params(level, "", var_names, var_values);
}

enLog_TraceVars(
    list var_names,
    list var_values
    )
{
    enLog_Vars(TRACE, var_names, var_values);
}

enLog_Params(
    integer level,
    string function_name,
    list param_names,
    list param_values
    )
{
    string params;
    if (param_values != []) params = "\n        " + llDumpList2String(enList_Concatenate("", param_names, " = ", param_values, ""), ",\n        ") + "\n    ";
    enLog_To(level, __LINE__, "", function_name + enString_If(function_name == "", "[", "(") + params + enString_If(function_name == "", "]", ")"));
}

enLog_TraceParams(
    string function_name,
    list param_names,
    list param_values
    )
{
    enLog_Params(TRACE, function_name, param_names, param_values);
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
