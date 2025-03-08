/*
enTest.lsl
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
*/

//  ==
//  ==  MACROS
//  ==

//  returns 1 for Mono (ENTEST_VM_MONO), -1 for LSO (ENTEST_VM_LSO)
//  relies on LSO returning strcmp instead of a boolean result
//  written before Luau was available to test; if you're here to rewrite this under Luau, good job living that long
//  2025-03-05: wtf it's already on beta grid??? TODO: figure out how to do this on Luau
#define enTest_GetVM() \
    ("" != "x")

//  
#define enTest_AssertFatal(at, av, m, bt, bv) enTest_AssertAt(FATAL, __LINE__, at, av, m, bt, bv)
#define enTest_AssertError(at, av, m, bt, bv) enTest_AssertAt(ERROR, __LINE__, at, av, m, bt, bv)
#define enTest_AssertWarn(at, av, m, bt, bv) enTest_AssertAt(WARN, __LINE__, at, av, m, bt, bv)
#define enTest_AssertInfo(at, av, m, bt, bv) enTest_AssertAt(INFO, __LINE__, at, av, m, bt, bv)
#define enTest_AssertDebug(at, av, m, bt, bv) enTest_AssertAt(DEBUG, __LINE__, at, av, m, bt, bv)
#define enTest_AssertTrace(at, av, m, bt, bv) enTest_AssertAt(TRACE, __LINE__, at, av, m, bt, bv)

//  ==
//  ==  FUNCTIONS
//  ==

/*
The enTest_AssertAt function can be called to validate a value as being a specific type and testing true as to a provided conditional.
Typically you should call one of the enTest_Assert* macros instead of this function directly.
This function mainly converts the return list from enTest_Test into a human-readable log entry.
*/
list enTest_AssertAt(
    integer l, // loglevel (FATAL stops script, all others get logged, 0 to not log)
    integer n, // line (use __LINE__ here)
    integer at, // value A type (should be the type of the function being tested)
    string av, // value A value (should be a function call that returns a value)
    integer m, // method (ENTEST_*)
    integer bt, // value B type (should be the type of the result expected, equivalent to bt)
    string bv // value B value (should be the value to test against, depending on which ENTEST_* method is used)
    )
{
    #ifndef ENTEST_ENABLE
        return []; // enTest not enabled
    #else
        list r = enTest_Test( at, av, m, bt, bv );
        if ( r == [] ) return []; // tested ok
        string e = llList2String( r, -1 ); // error type
        string f = "enTest_Assert( " + enLog_Level( l ) + ", " + (string)n + ", " + enTest_Type( at ) + ", \"" + av + "\", ENTEST_" + enTest_Method( m ) + ", " + enTest_Type( bt ) + ", \"" + bv + "\" ) failed"; // failure reason
        // generate extended failure reason if error type is not "!"
        if ( e == "!Match") f = " due to input parameter type mismatch";
        else if ( e == "!Type" ) f = " due to incompatible input types for this method";
        else if ( e == "!Method" ) f = " due to an unknown method";
        else if ( llGetSubString( e, -1, -1 ) == "A" || llGetSubString( e, -1, -1 ) == "B" ) f = " due to input parameter " + llGetSubString( e, -1, -1 ) + " being an invalid " + llGetSubString( e, 1, -2 );
        // terminate failure reason
        f += " at line " + (string)n + ".";
        // log error
        if ( l == FATAL ) enLog_Fatal( f );
        else enLog_To( l, __LINE__, "", f );
    #endif
}

/*
The enTest_Test function performs the actual validation of function return values.
Values are passed in as strings (since LSL has no way to pass in untyped parameters).
The function first validates that the string represents a valid typecasted value of the specified type.
Then, the function validates that the string, cast to that type, passes an ENTEST_* validation method.
If the result passes, an empty list is returned; otherwise, the inputs are returned with an error.
*/
list enTest_Test(
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
        if ( !enKey_Is( av ) ) f = "!KeyA"; // av is not a valid key or NULL_KEY
        if ( !enKey_Is( bv ) ) f = "!KeyB"; // bv is not a valid key or NULL_KEY
    }
    if ( at == LIST )
    { // validate lists
        // TODO
    }
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    if ( m == ENTEST_EQUAL || m == ENTEST_NOT_EQUAL )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av != (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( llFabs( (float)av - (float)bv ) <= ENTEST_PRECISION_FLOAT ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecDist( (vector)av, (vector)bv ) <= ENTEST_PRECISION_VECTOR ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecDist( llRot2Euler( (rotation)av ), llRot2Euler( (rotation)bv ) ) <= ENTEST_PRECISION_ROTATION ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST )
        {
            if ( av != bv ) f = "!";
        }
        if ( m == ENTEST_NOT_EQUAL ) f = enString_If( (f == ""), "!", "" ); // invert result
    }
    else if ( m == ENTEST_GREATER )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av <= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + ENTEST_PRECISION_FLOAT <= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) + ENTEST_PRECISION_VECTOR <= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) + ENTEST_PRECISION_ROTATION <= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else if ( m == ENTEST_LESS )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av >= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + ENTEST_PRECISION_FLOAT >= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) - ENTEST_PRECISION_VECTOR >= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) - ENTEST_PRECISION_ROTATION >= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else f = "!Method";
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    return []; // ok
}

//  converts integer type number into string representation
string enTest_Type(
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

//  converts integer method number into string representation
string enTest_Method(
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
