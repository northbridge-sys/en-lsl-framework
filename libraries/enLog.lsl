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
    optionally, via enChat to a specified UUID and service.
*/

// ==
// == functions
// ==

enLog$( // custom logging function
    integer level,
    string message
    )
{
    enLog$To("", level, message);
    #ifndef ENLOG$DISABLE_LOGTARGET
        string t = enLog$GetLogtarget();
        string prim = llGetSubString( t, 0, 35 );
        if ( enKey$IsPrimInRegion( prim ) )
        { // log via enChat to logtarget
            string domain = llDeleteSubString( t, 0, 35 );
            enChat$RegionSayTo( prim, enChat$Channel( domain ), enList$ToString([ "enChat", enChat$GetService(), prim, domain, "$enLog", message ] ) );
        }
    #endif
}

enLog$To(
    string target,
    integer level,
    string message
    )
{
    // can use level 0 to always send, or a level constant for loglevel support
    integer lsd_level = enLog$GetLoglevel();
    list debug_header;
    if (lsd_level >= 5)
    { // use debug header
        list script_name = llParseStringKeepNulls(llGetScriptName(), [" "], []);
        while (llListFindList(["(", "["], [llGetSubString(llList2String(script_name, 0), 0, 0)]) != -1)
        { // remove any elements at start of script_name that start with "(" or "[" (such as "[Northbridge Business Systems]")
            script_name = llDeleteSubList(script_name, 0, 0);
        }
        while (llListFindList(["r", "v"], [llGetSubString(llList2String(script_name, -1), 0, 0)]) != -1)
        { // remove any elements at end of script_name that start with "r" or "v" (hides revision/version number)
            script_name = llDeleteSubList(script_name, -1, -1);
        }
        debug_header = ["🔽 [", llGetSubString(llGetTimestamp(), 11, 21), "] (", llGetSubString(llGetKey(), 0, 3), " ", (string)((integer)((100.0 * llGetUsedMemory()) / llGetMemoryLimit())), "%) ", llDumpList2String(script_name, " "), "\n"];
    }
    if ( lsd_level >= level )
    {
        message = llDumpList2String(debug_header, "") + llList2String([ // loglevel header, usually an icon but can be anything
            "", // no level
            "🛑 FATAL ERROR: ", // FATAL
            "❌ ERROR: ", // ERROR
            "🚩 WARNING: ", // WARN
            "💬 ", // INFO
            "🪲 ", // DEBUG
            "🚦 " // TRACE
            ], level) + message;
        if (target == "") llOwnerSay(message);
        else llRegionSayTo(target, 0, message);
    }
}

enLog$FatalStop( // logs a fatal error and stops the script
    string m // message
    )
{
    if ( m != "" ) m += " ";
    enLog$( FATAL, m + "Script stopped." );
    llSetScriptState( llGetScriptName(), FALSE );
    llSleep( 1.0 ); // give the simulator time to stop the script to be safe
}

enLog$FatalDelete( // logs a fatal error and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
    string m // message
)
{
    if ( m != "" ) m += " ";
    enLog$( FATAL, m + "Script deleted." );
    llSetScriptState( llGetScriptName(), FALSE );
    // remove inventory if ENLOG$ENABLE_FATALDELETE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef ENLOG$ENABLE_FATALDELETE_OWNEDBYCREATOR
        if ( enInventory$OwnedByCreator( llGetScriptName() ) ) enLog$ERROR("Script deletion failed because ENLOG$ENABLE_FATALDELETE_OWNEDBYCREATOR is not defined.");
        else
    #endif
    // only remove inventory if ENLOG$DISABLE_FATALDELETE is NOT defined
    #ifdef ENLOG$DISABLE_FATALDELETE
        enLog$ERROR("Script deletion failed because ENLOG$DISABLE_FATALDELETE is defined.");
    #else
        llRemoveInventory( llGetScriptName() );
    #endif
    llSleep( 1.0 ); // give the simulator time to stop and delete the script to be safe
}

enLog$FatalDie( // logs a fatal error and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
    string m // message
)
{
    if ( m != "" ) m += " ";
    enLog$Fatal( m + "Object " + llList2String(["deleted", "detached from " + enObject$GetAttachedString(llGetAttached())], !!llGetAttached()) + "." );
    llSetScriptState( llGetScriptName(), FALSE );
    // delete object if ENLOG$ENABLE_FATALDELETE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef ENLOG$ENABLE_FATALDIE_OWNEDBYCREATOR
        if ( enInventory$OwnedByCreator( llGetScriptName() ) ) enLog$ERROR("Object delete/detach failed because ENLOG$ENABLE_FATALDIE_OWNEDBYCREATOR is not defined.");
        else
    #endif
    // only delete object if ENLOG$DISABLE_FATALDELETE is NOT defined
    #ifdef ENLOG$DISABLE_FATALDIE
        enLog$ERROR("Object delete/detach failed because ENLOG$DISABLE_FATALDIE is defined.");
    #else
        {
            if (llGetAttached()) llDetachFromAvatar();
            else llDie();
        }
    #endif
    llSleep( 1.0 ); // give the simulator time
}

string enLog$LevelToString( // converts integer level number into string representation
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

integer enLog$StringToLevel( // converts integer level number into string representation
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

enLog$TraceParams( string function_name, list param_names, list param_values )
{
    string params;
    if ( param_values != [] ) params = "\n        " + llDumpList2String( enList$Concatenate( "", param_names, " = ", param_values, "" ), ",\n        " ) + "\n    ";
    enLog$Trace( function_name + "(" + params + ")" );
}

enLog$TraceVars( list var_names, list var_values )
{
    enLog$TraceParams( "enLog$TraceVars", var_names, var_values );
}

integer enLog$GetLoglevel()
{
    string lsd = llLinksetDataRead( "loglevel" ); // any valid log level number, 0 (uses default), or negative (suppresses all output)
    if ( (integer)lsd ) return (integer)lsd;
    else return ENLOG$DEFAULT_LOGLEVEL;
}

enLog$SetLoglevel(
    integer level
)
{
    if ( level < FATAL || level > TRACE ) return;
    llLinksetDataWrite( "loglevel", (string)level );
}

string enLog$GetLogtarget(
)
{
    return llLinksetDataRead("logtarget");
}

enLog$SetLogtarget(
    string target
)
{
    llLinksetDataWrite( "logtarget", target );
}
