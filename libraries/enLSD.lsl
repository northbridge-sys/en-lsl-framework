/*
    enLSD.lsl
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

string _ENLSD_HEADER;
string _ENLSD_PASS;

#ifdef ENLSD_ENABLE_SCRIPT_NAME_HEADER
    string _ENLSD_SCRIPT_NAME;
#endif

// ==
// == macros
// ==

#define enLSD_SetHeader(s) \
    (_ENLSD_HEADER = s)

#define enLSD_SetPass(s) \
    (_ENLSD_PASS = s)

#define enLSD_Head() \
    enLSD_BuildHead(llGetScriptName(), llGetKey())

#define enLSD_GetHeadCount() \
    (llGetListLength(llParseStringKeepNulls(enLSD_Head(), ["\n"], [])) - 1)

#define enLSD_WriteRaw(name, data) \
    llLinksetDataWrite(enLSD_Head() + name, data)

#define enLSD_ReadRaw(name, data) \
    llLinksetDataRead(enLSD_Head() + name)

#define enLSD_WriteProtectedRaw(name, data, pass) \
    llLinksetDataWriteProtected(enLSD_Head() + name, data, pass)

#define enLSD_ReadProtectedRaw(name, pass) \
    llLinksetDataReadProtected(enLSD_Head() + name, pass)

// ==
// == functions
// ==

enLSD_Reset() // safely resets linkset data
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams( "enLSD_Reset", [], [] );
    #endif
    // note: retained pairs MUST be unprotected
    list retain = [
        "loglevel",
        "logtarget",
        "logsay",
        "logchannel"
        ];
    list values;
    integer i;
    integer l = llGetListLength( retain );
    for ( i = 0; i < l; i++ )
    { // store values temporarily
        values += [ llLinksetDataRead( llList2String( retain, i ) ) ];
    }
    llLinksetDataDeleteFound("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, enLSD_Head()) + ".*$", _ENLSD_PASS);
    for ( i = 0; i < l; i++ )
    { // write retained values back to datastore
        llLinksetDataWrite( llList2String( retain, i ), llList2String( values, i ) );
    }
}

integer enLSD_Write(list name, string data)
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Write", ["name", "data"], [
            enList_Elem(name),
            enString_Elem(data)
            ]);
    #endif
	if (_ENLSD_PASS == "") return llLinksetDataWrite(enLSD_Head() + llDumpList2String(name, "\n"), data);
    return llLinksetDataWriteProtected(enLSD_Head() + llDumpList2String(name, "\n"), data, _ENLSD_PASS);
}

string enLSD_Read(list name)
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Read", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	if (_ENLSD_PASS == "") return llLinksetDataRead(enLSD_Head() + llDumpList2String(name, "\n"));
    return llLinksetDataReadProtected(enLSD_Head() + llDumpList2String(name, "\n"), _ENLSD_PASS);
}

list enLSD_Delete(list name)
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Delete", ["name"], [
            enList_Elem(name)
            ]);
    #endif
	return llLinksetDataDeleteFound("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, enLSD_Head() + llDumpList2String(name, "\n")) + "$", _ENLSD_PASS);
}

integer enLSD_Exists(list name)
{
    return (enLSD_Find(name, 0, 1) != []);
}

list enLSD_Find(list name, integer start, integer count)
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Find", ["name", "start", "count"], [
            enString_Elem(name),
            start,
            count
            ]);
    #endif
	return llLinksetDataFindKeys("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, enLSD_Head() + llDumpList2String(name, "\n")) + "$", start, count);
}

list enLSD_FindRegex(string regex, integer start, integer count)
{ // note: do NOT include ^ and $ anchors in regex string, they will be added automatically
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_FindRegex", ["regex", "start", "count"], [
            enString_Elem(regex),
            start,
            count
            ]);
    #endif
	return llLinksetDataFindKeys("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, enLSD_Head()) + regex + "$", start, count);
}

string enLSD_BuildHead(
    string script_name,
    string uuid
)
{
    string h = _ENLSD_HEADER + "\n";
    #if defined ENLSD_ENABLE_SCRIPT_NAME_HEADER && !defined ENLSD_ENABLE_SCRIPT_NAME_HEADER_HASH_LENGTH
        h = script_name + "\n" + h; // prepend full script name
    #endif
    #if defined ENLSD_ENABLE_SCRIPT_NAME_HEADER && defined ENLSD_ENABLE_SCRIPT_NAME_HEADER_HASH_LENGTH
        h = llGetSubString(llSHA256String(script_name), 0, ENLSD_ENABLE_SCRIPT_NAME_HEADER_HASH_LENGTH - 1) + "\n" + h; // prepend first chars of SHA256 hashed script name
    #endif
    #if defined ENLSD_ENABLE_UUID_HEADER && !defined ENLSD_ENABLE_UUID_HEADER_HASH_LENGTH
        h = uuid + "\n" + h; // prepend llGetKey to start of string to avoid linkset conflicts
    #endif
    #if defined ENLSD_ENABLE_UUID_HEADER && defined ENLSD_ENABLE_UUID_HEADER_HASH_LENGTH
        h = llGetSubString(uuid, 0, ENLSD_ENABLE_UUID_HEADER_HASH_LENGTH - 1) + "\n" + h; // prepend first chars of llGetKey to start of string to avoid linkset conflicts
    #endif
    return h;
}

list enLSD_PairToName( // converts a raw LSD pair name to an enLSD name list
    string pair
)
{
    if (pair == "") return [];
    list elems = llParseStringKeepNulls(pair, ["\n"], []);
    integer head = enLSD_GetHeadCount();
    if (head) elems = llDeleteSubList(elems, 0, head - 1);
    return elems;
}

enLSD_Pull( // reads a linkset data name-value pair FROM another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Pull", ["prim", "domain", "use_header", "name"], [
            enObject_Elem(prim),
            enString_Elem(domain),
            use_header,
            enString_Elem(name)
            ]);
    #endif
    enCLEP_SendRaw(prim, domain, "enLSD_PullLSD", enList_ToString([use_header, name]));
}

enLSD_Push( // writes a linkset data name-value pair TO another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Push", ["prim", "domain", "use_header", "name"], [
            enObject_Elem(prim),
            enString_Elem(domain),
            use_header,
            enString_Elem(name)
            ]);
    #endif
    string v;
    if (use_header) v = enLSD_Read(name);
    else v = llLinksetDataRead(name);
    integer u;
    #ifdef ENLSD_ENABLE_UUID_HEADER
        u = 1; // if ENLSD_ENABLE_UUID_HEADER defined, note in response
    #endif
    enCLEP_SendRaw(prim, domain, "enLSD_Push", enList_ToString([u, use_header, _ENLSD_HEADER, name, v]));
}

enLSD_Process( // writes a linkset data name-value pair FROM another script
    string prim,
    integer use_uuid,
    integer use_header,
    string uuid,
    string header,
    string name,
    string value
    )
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_Process", ["prim", "use_uuid", "use_header", "uuid", "header", "name", "value"], [
            enObject_Elem(prim),
            use_uuid,
            use_header,
            enString_Elem(uuid),
            enString_Elem(header),
            enString_Elem(name),
            enString_Elem(value)
            ]);
    #endif
    #ifndef ENLSD_PUSHED_ALLOW_BROADCAST
        if (prim != (string)llGetKey()) return; // do not allow enLSD_Push calls sent to NULL_KEY
    #endif
    #ifdef ENLSD_PUSHED_ADD_HEADER
        use_header = 1; // always use header when writing
    #endif
    #ifdef ENLSD_PUSHED_UPDATE_HEADER
        if (use_header) header = _ENLSD_HEADER; // update header to local header
    #endif
    #ifdef ENLSD_PUSHED_ADD_UUID
        use_uuid = 1; // always use uuid when writing (also define ENLSD_PUSHED_ADD_HEADER)
    #endif
    #ifdef ENLSD_PUSHED_REMOVE_UUID
        use_uuid = 0; // never use uuid when writing (also define ENLSD_PUSHED_ADD_HEADER)
    #endif
    #ifdef ENLSD_PUSHED_UPDATE_UUID
        // change header key if used
        if (use_uuid) header = llGetKey() + header;
    #else
        if (use_uuid) header = uuid + header;
    #endif
    #ifdef ENLSD_PUSHED_EVENT
        en_pushed_lsd(
            prim,
            use_uuid,
            use_header,
            uuid,
            header,
            name,
            value
            );
    #endif
    #ifdef ENLSD_PUSHED_WRITE
        if (!use_header) header = "";
        llLinksetDataWrite(header + name, value);
    #endif
}

enLSD_MoveAllPairs( // utility function for enLSD_Check*
    string k
)
{
    list l;
    string n;
    #ifdef ENLSD_USE_SCRIPT_NAME_HEADER
        n = _ENLSD_SCRIPT_NAME;
    #endif
    string old_head = enLSD_BuildHead(n, k);
    do
    {
        l = llLinksetDataFindKeys("^" + enString_Escape(ENSTRING_ESCAPE_FILTER_REGEX, old_head) + ".*$", 0, 1);
        if (l != [])
        {
            string old_pair = llList2String(l, 0);
            string pair_name = llDeleteSubString(old_pair, 0, llStringLength(old_head) - 1);
            enLog_Trace("LSD pair \"" + pair_name + "\" moved");
            if (_ENLSD_PASS == "")
            {
                llLinksetDataWrite(enLSD_Head() + pair_name, llLinksetDataRead(old_pair)); // write with updated header
                llLinksetDataDelete(old_pair); // immediately delete old pair to save memory
            }
            else
            {
                llLinksetDataWriteProtected(enLSD_Head() + pair_name, llLinksetDataReadProtected(old_pair, _ENLSD_PASS), _ENLSD_PASS); // write with updated header
                llLinksetDataDeleteProtected(old_pair, _ENLSD_PASS); // immediately delete old pair to save memory
            }
        }
    } while (l != []); // repeat until we didn't find any keys left with old header
}

enLSD_CheckUUID() // updates LSD entries that use old UUID
{ // note: if ENLSD_DISABLE_UUID_CHECK is defined, this function is never called - only need to run enLSD_CheckUUID in one script in each prim
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_CheckUUID", [], []);
    #endif
    #ifdef ENLSD_ENABLE_UUID_HEADER
        string k = enObject_Self( 0 ); // get last key
        if (k == (string)llGetKey() || k == "") return; // no UUID change, or no UUID history stored
        enLog_Debug("Moving LSD due to UUID change from \"" + k + "\" to \"" + (string)llGetKey() + "\"");
        enLSD_MoveAllPairs(k);
    #endif
}

enLSD_CheckScriptName() // updates LSD entries that use old script name
{
    #ifdef ENLSD_TRACE
        enLog_TraceParams("enLSD_CheckScriptName", [], []);
    #endif
    #ifdef ENLSD_ENABLE_SCRIPT_NAME_HEADER
        if (llGetScriptName() == _ENLSD_SCRIPT_NAME) return; // no script name change
        if (_ENLSD_SCRIPT_NAME != "")
        {
            enLog_Debug("Moving LSD due to script name change from \"" + _ENLSD_SCRIPT_NAME + "\" to \"" + llGetScriptName() + "\"");
            enLSD_MoveAllPairs(llGetKey());
        }
        _ENLSD_SCRIPT_NAME = llGetScriptName();
    #endif
}
