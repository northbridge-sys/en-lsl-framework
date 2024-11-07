/*
    XiKey.lsl
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

    TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XIKEY_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

integer XiKey_Is( // returns 1 if is a valid key (INCLUDING NULL_KEY, unlike the regular if (key) conditional check)
    string k
    )
{
    if ((key)k) return 1;
    if (k == NULL_KEY) return 1;
    return 0;
}

integer XiKey_IsAvatar( // returns 1 if a valid avatar key IN THIS REGION
    string k
)
{
    return llGetAgentSize() != ZERO_VECTOR;
}

integer XiKey_IsPrim( // returns 1 if a valid prim key IN THIS REGION
    string k
    )
{
    list d = llGetObjectDetails( k, [ OBJECT_OWNER ] );
    if ( d == [] ) return 0; // not in region
    if ( llList2String( d, 0 ) == llToLower( k ) ) return 0; // is an avatar
    return 1; // must be a prim
}

string XiKey_Strip( // strips dashes out of a key
    string k
    )
{
    if ( !XiKey_Is( k ) ) return k; // not a valid key
    return llReplaceSubString( k, "-", "", 0 ); // valid key, so strip dashes
}

string XiKey_Unstrip( // adds dashes into a 32-character hex string to turn it into a key
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

string XiKey_Compress( // strips dashes out of a key and encodes it in Base64 for memory efficiency (36 characters down to 32 in hex, or 24 in Base64)
    string k
    )
{
    if ( !XiKey_Is( k ) ) return k; // not a valid key
    k = XiKey_Strip( k );
    return llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 0, 7))), 0, 5) // concatenate the first 6 characters of Base64 encoding of each 8 nybbles (the remaining is always padding)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 8, 15))), 0, 5)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 16, 23))), 0, 5)
        + llGetSubString(llIntegerToBase64((integer)("0x" + llGetSubString(k, 24, 31))), 0, 5);
}

string XiKey_Decompress( // adds dashes back into a key that was sent through XiKey_Compress(...)
    string k
    )
{
    if (llStringLength(k) != 24) return k; // not a compressed key
    // presumptively valid key at this point (no point k checking any further)
    // convert from Base64 to a 32-nybble hex string
    k = XiInteger_ToHex(llBase64ToInteger(llGetSubString(k, 0, 5)))
        + XiInteger_ToHex(llBase64ToInteger(llGetSubString(k, 6, 11)))
        + XiInteger_ToHex(llBase64ToInteger(llGetSubString(k, 12, 17)))
        + XiInteger_ToHex(llBase64ToInteger(llGetSubString(k, 18, 23)));
    // inject dashes and return
    return XiKey_Unstrip( k );
}
