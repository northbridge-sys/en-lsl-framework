/*
enString.lsl
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

//  returns pluralization ("s"/"es"/etc.) for specified integer
//  example:
//      (string)prim_count + " prim" + enString_Plural(prim_count, "s", "") + " counted"
string enString_Plural(
    integer x,
    string s
    )
{
    if (x == 1) return "";
    if (s == "") s = "s"; // default to "s"
    return s;
}

//  returns string a if x is truthy, or b if falsey
//  example:
//      "value is " + enString_If(value, "truthy", "falsey")
string enString_If(
    integer x,
    string a,
    string b
    )
{
    if (x) return a;
    return b;
}

/*
fast, memory-efficient way of left-padding src with leading zeroes up to l_target
use this instead of enString_Pad to save a bunch of memory for numerical uses
note: this does NOT trim src down to l_target!
*/
string enString_PadZeroes(
    string src,
    integer l_target
)
{
    while (llStringLength(src) < l_target) src = "0" + src;
    return src;
}

//  pads (or trims) a string to length l_target using specified alignment and padding
//  example:
//      "bank balance: $1" + enString_Pad("5", "0", 5, )
string enString_Pad(
	string src, // string to start with
	string pad, // padding string to use to grow src if necessary
	integer l_target, // number of digits to pad - if POSITIVE, also trims down to this length; if NEGATIVE, only pads to this length, overlength strings will be returned as overlength
	integer flags // either ENSTRING_PAD_ALIGN_LEFT, ENSTRING_PAD_ALIGN_CENTER, or ENSTRING_PAD_ALIGN_RIGHT (note that CENTER uses a left-aligned trim for memory reasons)
)
{
    // len: positive to pad or trim to l_target, negative to only pad (do not trim if already too long)
    // align: 0 = left (pad & trim), 1 = right (pad & trim), 2 = center (pad only, left-aligned trim)
    integer trim;
    if (l_target >= 0) trim = 1; // trim only if len is positive
    else l_target -= 2 * l_target; // too lazy to do some fancy bitwise for this
    integer l_diff = l_target - llStringLength(src);
    if (l_diff < 0 && trim)
    { // overlength
        if (trim)
        { // we're allowed to trim it back down
            if (flags & ENSTRING_PAD_ALIGN_LEFT) src = llDeleteSubString(src, 0, -l_diff - 1); // trim from left
            else src = llDeleteSubString(src, l_diff, -1); // trim from right
        }
    }
    if (l_diff > 0)
    { // we need to pad
        if (pad == "") pad = " "; // if pad wasn't specified, we need at least something to pad with
        integer l_pad;
        for (l_pad = llStringLength(pad); l_pad < l_diff; l_pad *= 2) pad += pad; // duplicate pad until it exceeds diff
        if (l_pad > l_diff) pad = llDeleteSubString(pad, -l_pad + l_diff, -1); // trim the pad back down to diff
        if (flags & ENSTRING_PAD_ALIGN_CENTER)
        { // center align
            if (l_diff == 1) src += llGetSubString(pad, 0, 0);
            else src = llGetSubString(pad, 0, (l_diff / 2) - 1) + src + llGetSubString(pad, 0, (l_diff - (l_diff / 2)) - 1);
        }
        else if (flags & ENSTRING_PAD_ALIGN_RIGHT) src = pad + src; // right align
        else src += pad; // left align
    }
    return src; // return src as-modified
}

//  appends the SI prefix to a specified number of bytes, rounding to the largest possible prefix
//  example:
//      enString_MultiByteUnit(llLinksetDataAvailable()) + "B available in linkset datastore"
string enString_MultiByteUnit(
	integer bytes
	)
{
    integer mult;
    while (bytes >= 1024)
    {
        bytes /= 1024;
        mult++;
    }
    return (string)bytes + llList2String(["", "K", "M", "G"], mult);
}

//  multi-purpose string escaping function for regex and JSON
//  example:
//      llLinksetDataFindKeys("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, needle) + ".*$"")
string enString_Escape(
    integer f, // filter string flag
    string x
    )
{
    list y;
    if (f & ENSTRING_ESCAPE_FILTER_REGEX) y = ["\\", "^", "$", "*", "+", "?", ".", "(", ")", "|", "{", "}", "[", "]"]; // note that \\ must be the first entry, otherwise previously escaped characters will be double-escaped
    if (f & ENSTRING_ESCAPE_FILTER_JSON) y = ["\""];
    integer i;
    integer l = llGetListLength(y);
    // run llReplaceSubString on each possible character that needs to be escaped
    // this is slow with regex, but takes the least memory compared to llParseStringKeepNulls-based approaches
    // both regex and JSON are escaped with single backwards slash, so we can just pass that right into the replacement
    for (i = 0; i < l; i++) x = llReplaceSubString(x, llList2String(y, i), "\\" + llList2String(y, i), 0);
    return x;
}

//  finds the first instance of any of the specified characters, used for user input validation
//  example:
//      if (enString_FindChars(input, "|~") != -1) enLog_FatalStop("Pipe (|) or tilde (~) detected in input");
integer enString_FindChars(
    string in,
    string chars
    )
{
    integer i;
    integer l = llStringLength(chars);
    integer x;
    for (i = 0; i < l; i++)
    {
        x = llSubStringIndex(in, llGetSubString(chars, i, i));
        if (~x) return x; // != -1
    }
    return -1;
}

//  attempts to get a value from a json string, and if fails, returns preset value instead of JSON_INVALID
//  example:
//      color = (vector)enString_JsonAttempt(json, ["set", "color"], (string)color);
//      //  if json contains a "set" object with a "color" value, the function will return it
//      //  otherwise, the function will return the existing value of the color variable
string enString_JsonAttempt(
    string json,
    list specifiers,
    string val
)
{
    string new_val = llJsonGetValue(json, specifiers);
    if (new_val != JSON_INVALID) return new_val;
    return val;
}
