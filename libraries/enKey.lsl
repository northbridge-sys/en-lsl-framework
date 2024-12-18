/*
    enKey.lsl
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

integer enKey_Is( // returns 1 if is a valid key (INCLUDING NULL_KEY, unlike the regular if (key) conditional check)
    string k
    )
{
    if ( (key)k ) return 1;
    return k == NULL_KEY;
}

integer enKey_IsNotNull( // returns 1 if is a valid key, but NOT NULL_KEY
    string k
    )
{
    if ( (key)k ) return 1;
    return 0;
}

integer enKey_IsNull( // returns 1 if is NULL_KEY
    string k
    )
{
    return k == NULL_KEY;
}

integer enKey_IsInRegion( // returns 1 if is a key of something that exists IN THIS REGION
    string k
    )
{
    if ( enKey_IsAvatarInRegion( k ) ) return 1;
    return enKey_IsPrimInRegion( k );
}

integer enKey_IsAvatarInRegion( // returns 1 if a valid avatar key IN THIS REGION
    string k
)
{
    return llGetAgentSize() != ZERO_VECTOR;
}

integer enKey_IsPrimInRegion( // returns 1 if a valid prim key IN THIS REGION
    string k
    )
{
    list d = llGetObjectDetails( k, [ OBJECT_OWNER ] );
    if ( d == [] ) return 0; // not in region
    if ( llList2String( d, 0 ) == llToLower( k ) ) return 0; // is an avatar
    return 1; // must be a prim
}

string enKey_Strip( // strips dashes out of a key
    string k
    )
{
    if ( !enKey_Is( k ) ) return k; // not a valid key
    return llReplaceSubString( k, "-", "", 0 ); // valid key, so strip dashes
}

string enKey_Unstrip( // adds dashes into a 32-character hex string to turn it into a key
    string k
    )
{
    // TODO: make a hex validator
    if ( llStringLength(k) != 32 ) return k; // not a valid 32-character hex string
    return // inject dashes and return
        llGetSubString(k, 0, 7) + "-" +
        llGetSubString(k, 8, 11) + "-" +
        llGetSubString(k, 12, 15) + "-" +
        llGetSubString(k, 16, 19) + "-" +
        llGetSubString(k, 20, 31);
}

string enKey_Compress( // strips dashes out of a key and encodes it in Base64 for memory efficiency (36 characters down to 32 in hex, or 24 in Base64)
    string k
    )
{
    if ( !enKey_Is( k ) ) return k; // not a valid key
    k = enKey_Strip( k );
    return llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 0, 7))), 0, 5) // concatenate the first 6 characters of Base64 encoding of each 8 nybbles (the remaining is always padding)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 8, 15))), 0, 5)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 16, 23))), 0, 5)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 24, 31))), 0, 5);
}

string enKey_Decompress( // adds dashes back into a key that was sent through enKey_Compress(...)
    string k
    )
{
    if (llStringLength(k) != 24) return k; // not a compressed key
    // presumptively valid key at this point (no point k checking any further)
    // convert from Base64 to a 32-nybble hex string
    k = enInteger_ToHex(llBase64ToInteger(llGetSubString(k, 0, 5)), 8)
        + enInteger_ToHex(llBase64ToInteger(llGetSubString(k, 6, 11)), 8)
        + enInteger_ToHex(llBase64ToInteger(llGetSubString(k, 12, 17)), 8)
        + enInteger_ToHex(llBase64ToInteger(llGetSubString(k, 18, 23)), 8);
    // inject dashes and return
    return enKey_Unstrip( k );
}
