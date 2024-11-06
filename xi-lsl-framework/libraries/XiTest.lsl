/*
    XiTest.lsl
    Library
    Xi LSL Framework
    Revision 0
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

    TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XITEST_ENABLE_XILOG_TRACE
#endif

#ifndef XITEST_PRECISION_FLOAT
// default exact precision for floats - adjust this in script if desired
#define XITEST_PRECISION_FLOAT 0.0
#endif

#ifndef XITEST_PRECISION_VECTOR
// default exact precision for vectors - adjust this in script if desired
#define XITEST_PRECISION_VECTOR 0.0
#endif

#ifndef XITEST_PRECISION_ROTATION
// default exact precision for vectors - adjust this in script if desired
#define XITEST_PRECISION_ROTATION 0.0
#endif

// ==
// == preprocessor flags
// ==



// ==
// == preprocessor constants
// ==

#define INTEGER 0
#define FLOAT 1
#define VECTOR 2
#define ROTATION 3
#define STRING 4
#define KEY 5
#define LIST 6

#define XITEST_EQUAL 0
#define XITEST_NOT_EQUAL 1
#define XITEST_GREATER 2
#define XITEST_LESS 3

// ==
// == functions
// ==

list XiTest_Assert( // unit test
    integer l, // loglevel (FATAL stops script, all others get logged, 0 to not log)
    integer n, // line
    integer at, // value A type
    string av, // value A value
    integer m, // method
    integer bt, // value B type
    string bv // value B value
    )
{
    #ifndef XITEST_ENABLE
        return []; // XiTest not enabled
    #else
        list r = _XiTest_Check( at, av, m, bt, bv );
        if ( r == [] ) return []; // tested ok
        string e = llList2String( r, -1 ); // error type
        string f = "XiTest_Assert( " + XiLog_Level( l ) + ", " + (string)n + ", " + _XiTest_Type( at ) + ", \"" + av + "\", XITEST_" + _XiTest_Method( m ) + ", " + _XiTest_Type( bt ) + ", \"" + bv + "\" ) failed"; // failure reason
        // generate extended failure reason if error type is not "!"
        if ( e == "!Match") f = " due to input parameter type mismatch";
        else if ( e == "!Type" ) f = " due to incompatible input types for this method";
        else if ( e == "!Method" ) f = " due to an unknown method";
        else if ( llGetSubString( e, -1, -1 ) == "A" || llGetSubString( e, -1, -1 ) == "B" ) f = " due to input parameter " + llGetSubString( e, -1, -1 ) + " being an invalid " + llGetSubString( e, 1, -2 );
        // terminate failure reason
        f += " at line " + (string)n + ".";
        // log error
        if ( l == FATAL ) XiLog_Fatal( f );
        else XiLog( l, f );
    #endif
}

string XiTest_Type( // converts integer type number into string representation
    integer t
    )
{
    return llList2String([
        "INTEGER",
        "FLOAT",
        "VECTOR",
        "ROTATION",
        "STRING",
        "KEY",
        "LIST",
        "UNKNOWN_TYPE_" + (string)t
        ], t);
}

string XiTest_Method( // converts integer method number into string representation
    integer m
    )
{
    return llList2String([
        "EQUAL",
        "NOT_EQUAL",
        "GREATER",
        "LESS",
        "UNKNOWN_METHOD_" + (string)m
        ], m);
}

list _XiTest_Check( // internal function called for each test
    integer at, // value A type
    string av, // value A value
    integer m, // method
    integer bt, // value B type
    string bv // value B value
    )
{
    string f;
    if ( at != bt ) f = "!Match";
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    if ( at == INTEGER )
    { // validate integers
        // TODO
    }
    if ( at == FLOAT )
    { // validate floats
        // TODO
    }
    if ( at == VECTOR )
    { // validate vectors
        // TODO
    }
    if ( at == ROTATION )
    { // validate rotations
        // TODO
    }
    if ( at == KEY )
    { // validate key
        if ( !XiKey_Is( av ) ) f = "!KeyA"; // av is not a valid key or NULL_KEY
        if ( !XiKey_Is( bv ) ) f = "!KeyB"; // bv is not a valid key or NULL_KEY
    }
    if ( at == LIST )
    { // validate lists
        // TODO
    }
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    if ( m == XITEST_EQUAL || m == XITEST_NOT_EQUAL )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av != (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( llFabs( (float)av - (float)bv ) <= XITEST_PRECISION_FLOAT ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecDist( (vector)av, (vector)bv ) <= XITEST_PRECISION_VECTOR ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecDist( llRot2Euler( (rotation)av ), llRot2Euler( (rotation)bv ) ) <= XITEST_PRECISION_ROTATION ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST )
        {
            if ( av != bv ) f = "!";
        }
        if ( m == XITEST_NOT_EQUAL ) f = XiString_Bool( (f == ""), "!" ); // invert result
    }
    else if ( m == XITEST_GREATER )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av <= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + XITEST_PRECISION_FLOAT <= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) + XITEST_PRECISION_VECTOR <= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) + XITEST_PRECISION_ROTATION <= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else if ( m == XITEST_LESS )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av >= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + XITEST_PRECISION_FLOAT >= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) - XITEST_PRECISION_VECTOR >= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) - XITEST_PRECISION_ROTATION >= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else f = "!Method";
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    return []; // ok
}

XiTest_StopOnFail(
    list a // results of XiTest_Assert
    )
{
    if ( a = [] ) return; // no need to crash
    XiLog_TraceParams( "XiTest_Crash", [ "XiTest_Assert(...)" ], [ XiList_Elem( a ) ); // log crash
    llSetScriptState( llGetScriptName(), FALSE ); // stop script
}
