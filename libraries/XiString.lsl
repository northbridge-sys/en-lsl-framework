/*
    XiString.lsl
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
// == globals
// ==

// ==
// == functions
// ==

string XiString$Elem(string var)
{
    return "\"" + var + "\"";
}

string XiString$Plural( // returns pluralization ("s"/"es"/etc.) for specified integer
    integer x,
    string s
    )
{
    if (x == 1) return "";
    if (s == "") s = "s";
    return s;
}

string XiString$If( // returns specified string if x is 1; can be used for text like "IS" or "IS NOT" enabled
    integer x,
    string s
    )
{
    if (x) return s;
    return "";
}

string XiString$Pad( // pads a string to length l_target
	string src,
	string pad,
	integer l_target,
	integer align)
{
    // len: positive to pad or trim to l_target, negative to only pad (do not trim if already too long)
    // align: 0 = left (pad & trim), 1 = right (pad & trim), 2 = center (pad only, left-aligned trim)
    integer trim;
    if (l_target >= 0)
    {
        trim = 1; // trim only if len is positive
    }
    else
    {
        l_target -= 2 * l_target; // too lazy to do some fancy bitwise for this
    }
    integer l_diff = l_target - llStringLength(src);
    if (l_diff < 0 && trim)
    { // overlength
        if (trim)
        { // we're allowed to trim it back down
            if (align == 1) src = llDeleteSubString(src, 0, -l_diff - 1); // trim from left
            else src = llDeleteSubString(src, l_diff, -1); // trim from right
        }
    }
    if (l_diff > 0)
    { // we need to pad
        if (pad == "") pad = " "; // if pad wasn't specified, we need at least something to pad with
        integer l_pad;
        for (l_pad = llStringLength(pad); l_pad < l_diff; l_pad *= 2)
        { // duplicate pad until it exceeds diff
            pad += pad;
        }
        if (l_pad > l_diff)
        { // trim the pad back down to diff
            pad = llDeleteSubString(pad, -l_pad + l_diff, -1);
        }
        if (align == XISTRING$PAD_ALIGN_CENTER)
        { // center align
            if (l_diff == 1) src += llGetSubString(pad, 0, 0);
            else src = llGetSubString(pad, 0, (l_diff / 2) - 1) + src + llGetSubString(pad, 0, (l_diff - (l_diff / 2)) - 1);
        }
        else if (align == XISTRING$PAD_ALIGN_RIGHT) src = pad + src; // right align
        else src += pad; // left align
    }
    return src; // return src as-modified
}

string XiString$MultiByteUnit( // appends the SI prefix to a specified number of bytes, rounding to the largest possible prefix
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

string XiString$Escape(
    integer f, // filter string flag
    string x
    )
{
    string y;
    string e;
    if (f & XISTRING$ESCAPE_FILTER_REGEX)
    {
        y = "^$*+?.()|{}[]\\"; // note that \\ must be the last entry, otherwise previously escaped characters will be double-escaped
        e = "\\"; // regex escaped with single backwards slash
    }
    if (f & XISTRING$ESCAPE_REVERSE)
    {
        // TODO: unescape
    }
    integer i;
    integer l = llStringLength(y);
    for (i = 0; i < l; i++)
    {
        x = llReplaceSubString(x, llGetSubString(y, i, i), e + llGetSubString(y, i, i), 0);
    }
    return x;
}

list XiString$ParseCfgLine( // parses a notecard line using a basic configuration markup format
    string s
    )
{
    s = llStringTrim(s, STRING_TRIM);
    if (llGetSubString(s, 0, 0) == "#") return []; // comment
    integer i = llSubStringIndex(s, "=");
    if (i == -1) return []; // invalid line
    if (i == 0) return ["", s]; // section start
    string n = llStringTrim(llToUpper(llGetSubString(s, 0, i - 1)), STRING_TRIM);
    string v = llStringTrim(llGetSubString(s, i + 1, -1), STRING_TRIM);
    if (i == llStringLength(s) - 1) v = ""; // value empty if = is at end of line, but above line will fail if that happens
    return [n, v];
}

integer XiString$FindChars( // finds the first instance of any of the specified characters, used for user input validation
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
        if (x != -1) return x;
    }
    return -1;
}

string XiString$JsonAttempt( // attempts to get a value from a json string, and if fails, returns preset value instead of JSON_INVALID
    string json,
    list specifiers,
    string value
)
{
    string new_val = llJsonGetValue(json, specifiers);
    if (new_val != JSON_INVALID) return new_val;
    return val;
}
