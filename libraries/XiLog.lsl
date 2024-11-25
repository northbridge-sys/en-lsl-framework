/*
    XiLog.lsl
    Library
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

    This is an LSL preprocessor include file that implements a set of fleXible
    logging functions that can output different loglevels via llOwnerSay and,
    optionally, via XiChat to a specified UUID and service.
*/

// ==
// == functions
// ==

XiLog$( // custom logging function
    integer level,
    string message
    )
{
    // can use level 0 to always send, or a level constant for loglevel support
    integer lsd_level = XiLog$GetLoglevel();
    list debug_header;
    if (lsd_level >= 5)
    { // use debug header
        list script_name = llParseStringKeepNulls(llGetScriptName(), [" "], []);
        while (llListFindList(["(", "["], [llGetSubString(llList2String(script_name, 0), 0, 0)]) != -1)
        { // remove any elements at start of script_name that start with "(" or "[" (such as "[BuildTronics]")
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
        llOwnerSay(
            llDumpList2String(debug_header, "")
            + llList2String([ // loglevel header, usually an icon but can be anything
                "", // no level
                "🛑 FATAL ERROR: ", // FATAL
                "❌ ERROR: ", // ERROR
                "🚩 WARNING: ", // WARN
                "💬 ", // INFO
                "🪲 ", // DEBUG
                "🚦 " // TRACE
                ], level)
            + message);
    }
    #ifndef XILOG$DISABLE_LOGTARGET
        string t = XiLog$GetLogtarget();
        string prim = llGetSubString( t, 0, 35 );
        if ( XiKey$IsPrimInRegion( prim ) )
        { // log via XiChat to logtarget
            string domain = llDeleteSubString( t, 0, 35 );
            XiChat$RegionSayTo( prim, XiChat$Channel( domain ), XiList$ToString([ "XiChat", XiChat$GetService(), prim, domain, "$XiLog", message ] ) );
        }
    #endif
}

XiLog$FatalStop( // logs a fatal error and stops the script
    string m // message
    )
{
    if ( m != "" ) m += " ";
    XiLog$( FATAL, m + "Script stopped." );
    llSetScriptState( llGetScriptName(), FALSE );
    llSleep( 1.0 ); // give the simulator time to stop the script to be safe
}

XiLog$FatalDelete( // logs a fatal error and deletes the script (WARNING: SCRIPT IS IRRETRIEVABLE)
    string m // message
)
{
    if ( m != "" ) m += " ";
    XiLog$( FATAL, m + "Script deleted." );
    llSetScriptState( llGetScriptName(), FALSE );
    // remove inventory if XILOG$ENABLE_FATALDELETE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef XILOG$ENABLE_FATALDELETE_OWNEDBYCREATOR
        if ( !XiInventory$OwnedByCreator( llGetScriptName() ) )
    #endif
    // only remove inventory if XILOG$DISABLE_FATALDELETE is NOT defined
    #ifdef XILOG$DISABLE_FATALDELETE
        1;
    #else
        llRemoveInventory( llGetScriptName() );
    #endif
    llSleep( 1.0 ); // give the simulator time to stop and delete the script to be safe
}

XiLog$FatalDie( // logs a fatal error and deletes the OBJECT (WARNING: OBJECT IS IRRETRIEVABLE IF NOT ATTACHED)
    string m // message
)
{
    if ( m != "" ) m += " ";
    XiLog$Fatal( m + "Object " + llList2String(["deleted", "detached from " + XiObject$GetAttachedString(llGetAttached())], !!llGetAttached()) + "." );
    llSetScriptState( llGetScriptName(), FALSE );
    // delete object if XILOG$ENABLE_FATALDELETE_OWNEDBYCREATOR is defined, OR script is not owned by creator
    #ifndef XILOG$ENABLE_FATALDIE_OWNEDBYCREATOR
        if ( !XiInventory$OwnedByCreator( llGetScriptName() ) )
    #endif
    // only delete object if XILOG$DISABLE_FATALDELETE is NOT defined
    #ifdef XILOG$DISABLE_FATALDIE
        1;
    #else
        {
            if (llGetAttached()) llDetachFromAvatar();
            else llDie();
        }
    #endif
    llSleep( 1.0 ); // give the simulator time
}

string XiLog$LevelToString( // converts integer level number into string representation
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

integer XiLog$StringToLevel( // converts integer level number into string representation
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

XiLog$TraceParams( string function_name, list param_names, list param_values )
{
    string params;
    if ( param_values != [] ) params = "\n        " + llDumpList2String( XiList$Concatenate( "", param_names, " = ", param_values, "" ), ",\n        " ) + "\n    ";
    XiLog$Trace( function_name + "(" + params + ")" );
}

XiLog$TraceVars( list var_names, list var_values )
{
    XiLog$TraceParams( "XiLog$TraceVars", var_names, var_values );
}

integer XiLog$GetLoglevel()
{
    string lsd = llLinksetDataRead( "loglevel" ); // any valid log level number, 0 (uses default), or negative (suppresses all output)
    if ( (integer)lsd ) return (integer)lsd;
    else return XILOG$DEFAULT_LOGLEVEL;
}

XiLog$SetLoglevel(
    integer level
)
{
    if ( level < FATAL || level > TRACE ) return;
    llLinksetDataWrite( "loglevel", (string)level );
}

string XiLog$GetLogtarget(
)
{
    return llLinksetDataRead("logtarget");
}

XiLog$SetLogtarget(
    string target
)
{
    llLinksetDataWrite( "logtarget", target );
}
