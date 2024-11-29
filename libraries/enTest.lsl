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

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

    TBD
*/

// ==
// == globals
// ==

// ==
// == functions
// ==

list enTest$Assert( // unit test
    integer l, // loglevel (FATAL stops script, all others get logged, 0 to not log)
    integer n, // line
    integer at, // value A type
    string av, // value A value
    integer m, // method
    integer bt, // value B type
    string bv // value B value
    )
{
    #ifndef ENTEST$ENABLE
        return []; // enTest not enabled
    #else
        list r = _enTest$Check( at, av, m, bt, bv );
        if ( r == [] ) return []; // tested ok
        string e = llList2String( r, -1 ); // error type
        string f = "enTest$Assert( " + enLog$Level( l ) + ", " + (string)n + ", " + _enTest$Type( at ) + ", \"" + av + "\", ENTEST$" + _enTest$Method( m ) + ", " + _enTest$Type( bt ) + ", \"" + bv + "\" ) failed"; // failure reason
        // generate extended failure reason if error type is not "!"
        if ( e == "!Match") f = " due to input parameter type mismatch";
        else if ( e == "!Type" ) f = " due to incompatible input types for this method";
        else if ( e == "!Method" ) f = " due to an unknown method";
        else if ( llGetSubString( e, -1, -1 ) == "A" || llGetSubString( e, -1, -1 ) == "B" ) f = " due to input parameter " + llGetSubString( e, -1, -1 ) + " being an invalid " + llGetSubString( e, 1, -2 );
        // terminate failure reason
        f += " at line " + (string)n + ".";
        // log error
        if ( l == FATAL ) enLog$Fatal( f );
        else enLog$( l, f );
    #endif
}

string enTest$Type( // converts integer type number into string representation
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

string enTest$Method( // converts integer method number into string representation
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

list _enTest$Check( // internal function called for each test
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
        if ( !enKey$Is( av ) ) f = "!KeyA"; // av is not a valid key or NULL_KEY
        if ( !enKey$Is( bv ) ) f = "!KeyB"; // bv is not a valid key or NULL_KEY
    }
    if ( at == LIST )
    { // validate lists
        // TODO
    }
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    if ( m == ENTEST$EQUAL || m == ENTEST$NOT_EQUAL )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av != (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( llFabs( (float)av - (float)bv ) <= ENTEST$PRECISION_FLOAT ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecDist( (vector)av, (vector)bv ) <= ENTEST$PRECISION_VECTOR ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecDist( llRot2Euler( (rotation)av ), llRot2Euler( (rotation)bv ) ) <= ENTEST$PRECISION_ROTATION ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST )
        {
            if ( av != bv ) f = "!";
        }
        if ( m == ENTEST$NOT_EQUAL ) f = enString$Bool( (f == ""), "!" ); // invert result
    }
    else if ( m == ENTEST$GREATER )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av <= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + ENTEST$PRECISION_FLOAT <= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) + ENTEST$PRECISION_VECTOR <= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) + ENTEST$PRECISION_ROTATION <= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else if ( m == ENTEST$LESS )
    {
        if ( at == INTEGER )
        {
            if ( (integer)av >= (integer)bv ) f = "!";
        }
        if ( at == FLOAT )
        {
            if ( (float)av + ENTEST$PRECISION_FLOAT >= (float)bv ) f = "!";
        }
        if ( at == VECTOR )
        {
            if ( llVecMag( (vector)av ) - ENTEST$PRECISION_VECTOR >= llVecMag( (vector)bv ) ) f = "!";
        }
        if ( at == ROTATION )
        {
            if ( llVecMag( llRot2Euler( (rotation)av ) ) - ENTEST$PRECISION_ROTATION >= llVecMag( llRot2Euler( (rotation)bv ) ) ) f = "!";
        }
        if ( at == STRING || at == KEY || at == LIST ) f = "!Type";
    }
    else f = "!Method";
    if ( f != "" ) return [ at, av, m, bt, bv, f ]; // not ok
    return []; // ok
}

enTest$StopOnFail(
    list a // results of enTest$Assert
    )
{
    if ( a = [] ) return; // no need to crash
    enLog$TraceParams( "enTest$Crash", [ "enTest$Assert(...)" ], [ enList$Elem( a ) ); // log crash
    llSetScriptState( llGetScriptName(), FALSE ); // stop script
}
