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
// == preprocessor options
// ==

#ifndef XILOG_DEFAULT_LOGLEVEL
#define XILOG_DEFAULT_LOGLEVEL 4
#endif

// ==
// == preprocessor flags
// ==

#define FATAL 1
#define ERROR 2
#define WARN 3
#define INFO 4
#define DEBUG 5
#define TRACE 6

// ==
// == functions
// ==

XiLog( // custom logging function
    integer level,
    string message
    )
{
    // can use level 0 to always send, or a level constant for loglevel support
    string lsd_text = llLinksetDataRead("loglevel"); // any valid log level number, 0 (uses default), or negative (suppresses all output)
    integer lsd_level = XILOG_DEFAULT_LOGLEVEL;
    if ((integer)lsd_text) lsd_level = (integer)lsd_text;
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
    #ifndef XILOG_DISABLE_LOGTARGET
        string t = llLinksetDataRead("logtarget");
        string prim = llGetSubString( t, 0, 35 );
        if ( XiKey_IsPrim( prim ) )
        { // log via XiChat to logtarget
            string domain = llDeleteSubString( t, 0, 35 );
            XiChat_RegionSayTo( prim, XiChat_Channel( domain ), XiList_ToString([ "XiChat", XICHAT_SERVICE, prim, domain, "_XiLog", message ] ) );
        }
    #endif
}

XiLog_Fatal( // logs a fatal error and stops the script
    string m // message
    )
{
    XiLog( FATAL, m );
    llSetScriptState( llGetScriptName(), FALSE );
    llSleep( 1.0 ); // give the simulator time to stop the script to be safe
}

string XiLog_LevelToString( // converts integer level number into string representation
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

integer XiLog_StrToLevel( // converts integer level number into string representation
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

XiLog_TraceParams(string function_name, list param_names, list param_values)
{
    string params;
    if (param_values != []) params = "\n        " + llDumpList2String(XiList_Concatenate("", param_names, "=", param_values, ""), ",\n        ") + "\n    ";
    XiLog(TRACE, function_name + "(" + params + ")");
}

XiLog_TraceVars(list var_names, list var_values)
{
    XiLog(TRACE, llList2CSV(XiList_Concatenate("", var_names, "=", var_values, "")));
}
