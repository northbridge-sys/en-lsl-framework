/*
    enList.lsl
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
// == macros
// ==

#define enList_FindStrideByElem( list_haystack, stride_length, index_in_stride, string_needle ) \
    llListFindList( llList2ListSlice( list_haystack, 0, -1, stride_length, index_in_stride ), [ string_needle ] )

// ==
// == functions
// ==

string enList_Elem(list var)
{
    if (var == []) return "[]";
    return "[\"" + llDumpList2String(var, "\", \"") + "\"]";
}

list enList_Empty( // if a list only has one element that is a blank string, convert it to an empty list
    list in
    )
{
    if (llGetListLength(in) == 1)
    {
        if (llList2String(in, 0) == "") in = [];
    }
    return in;
}

list enList_ToJson( // returns a string with each element converted to an escaped JSON string
    list in
)
{
    list out;
    integer i;
    integer l = llGetListLength(in);
    for (i = 0; i < l; i++)
    {
        out += ["\"" + enString_Escape(ENSTRING_ESCAPE_FILTER_JSON, llList2String(in, i)) + "\""];
    }
    return out;
}

list enList_Reverse(
    list l
)
{
    integer n = (l != []);
    while (n)
    {
        l += llList2List(l, (n = ~-n), n);
    }
    return llList2List(l, (l != []) >> 1, -1);
}

list enList_Collate(
    list a,
    list b
    )
{
    list out;
    integer i;
    integer l = llGetListLength(a);
    if (llGetListLength(b) > l) l = llGetListLength(b);
    for (i = 0; i < l; i++) out += llList2List(a, i, i) + llList2List(b, i, i);
    return out;
}

list enList_Concatenate(
    string start,
    list a,
    string mid,
    list b,
    string end
    )
{
    list out;
    integer i;
    integer l = llGetListLength(a);
    if (llGetListLength(b) > l) l = llGetListLength(b);
    for (i = 0; i < l; i++) out += [start + llList2String(a, i) + mid + llList2String(b, i) + end];
    return out;
}

/* benchmark results:
[22:50] Object: Testing enList_Legacy_ToString
Started with 15264 bytes used
Ended with 15450 bytes used
 Time Running Per Cycle: 0.002113 seconds
 
[22:49] Object: Testing enList_Legacy_FromString
Started with 25490 bytes used
Ended with 26144 bytes used
 Time Running Per Cycle: 0.008785 seconds
 
[22:51] Object: Testing enList_ToString
Started with 15242 bytes used
Ended with 15540 bytes used
 Time Running Per Cycle: 0.002673 seconds
 
[22:52] Object: Testing enList_FromString
Started with 16760 bytes used
Ended with 17000 bytes used
 Time Running Per Cycle: 0.004608 seconds
 
[22:55] Object: Testing enList_FromString llListReplaceList
Started with 16760 bytes used
Ended with 17116 bytes used
 Time Running Per Cycle: 0.005356 seconds
*/

string enList_ToString( // converts a list into a string without worrying about separators or JSON
    list in
    )
{
    string out;
    integer i;
    integer l = llGetListLength(in);
    string elem;
    for ( i = 0; i < l; i++ )
    {
        out += llEscapeURL(llList2String(in, i)) + ",";
    }
    return out;
}

string enList_Legacy_ToString( // converts a list into a string without worrying about separators or JSON
    list in
    )
{
    string out;
    integer i;
    integer l = llGetListLength( in );
    string elem;
    for ( i = 0; i < l; i++ )
    {
        elem = llList2String( in, i );
        out += (string)llStringLength( elem ) + " " + elem;
    }
    return "𒂗L" + (string)l + " " + out + " ";
}

list enList_FromString( // converts a string generated by enList_ToString(...) back into a list
    string in
    )
{
    if (in == "") return []; // empty list
    list out = llCSV2List(in);
    if (llList2String(out, -1) != "") return []; // input string was truncated
    // WARNING: if the string is truncated exactly after a comma, this will not be caught!

    /* tested slower - 0.005356 seconds vs. 0.004608 seconds - also takes more memory somehow
    integer i;
    integer l = llGetListLength(out) - 1; // don't bother with padding element
    for (i = 0; i < l; i++)
    {
        out = llListReplaceList(out, [llUnescapeURL(llList2String(out, i))], i, i);
    }
    */
    list unescaped;
    integer i;
    integer l = llGetListLength(out) - 1; // don't bother with padding element
    for (i = 0; i < l; i++)
    {
        unescaped += [llUnescapeURL(llList2String(out, i))];
    }
    
    return unescaped;
}

list enList_Legacy_FromString( // converts a string generated by enList_ToString(...) back into a list
    string in
    )
{
    if (llGetSubString(in, 0, 1) != "𒂗L") return []; // not a enList string
    in = llDeleteSubString(in, 0, 1);
    integer length = llStringLength( in ); // count length once for speed
    integer space = llSubStringIndex( in, " " ); // find header delineator - int before this is number of elements
    integer count;
    integer expect = (integer)llGetSubString( in, 0, space - 1 );
    in = llDeleteSubString( in, 0, space ); // trim elem_expect header off
    length -= space + 1; // reduce total length counter
    string elem;
    integer elem_length = 1;
    list out;
    while ( length > 1 && space )
    { // for each element
        space = llSubStringIndex( in, " " ); // find header delineator - int before this is length of element body
        elem_length = (integer)llGetSubString( in, 0, space - 1 );
        if ( !elem_length ) elem = ""; // llGetSubString can't return an empty string
        else elem = llGetSubString( in, space + 1, space + elem_length );
        if (llStringLength(elem) == elem_length) out += [ elem ]; // only add if element has not been truncated
        in = llDeleteSubString( in, 0, space + elem_length ); // trim element off
        length -= space + elem_length + 1; // reduce total length counter
    }
    if ( in != " " )
    {
        enLog_Debug("enList_FromString failed due to truncation");
        return []; // all that should be left is the end-of-list space
    }
    return out;
}

integer enList_FindPartial( // llListFindList but needle can be only part of the element instead of the entire element
    list x,
    string s
    )
{
    integer i;
    integer l = llGetListLength(x);
    for (i = 0; i < l; i++)
    {
        if (llSubStringIndex(llList2String(x, i), s) != -1) return i;
    }
    return -1;
}

list enList_DeleteStrideByMatch(
    list haystack,
    integer stride,
    integer index,
    list needle
    )
{
    integer i = llListFindList(llList2ListSlice(haystack, 0, -1, stride, index), needle);
    if (i != -1) return llDeleteSubList(haystack, i * stride, (i + 1) * stride - 1); // delete existing stride because we'll be re-adding it
    return haystack;
}

list enList_ReplaceExact(
    list haystack,
    list needle,
    list new
    )
{
    integer l = llGetListLength(needle);
    integer ind;
    do
    {
        ind = llListFindList(haystack, needle);
        if (ind != -1) haystack = llListReplaceList(haystack, new, ind, ind + l - 1);
    }
    while (ind != -1);
    return haystack;
}
