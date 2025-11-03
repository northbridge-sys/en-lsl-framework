/*
enLSD.lsl
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

// safely resets linkset data
enLSD_Reset()
{
    #if defined TRACE_ENLSD
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
    llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, enLSD_Head()) + ".*$", _FLAG_ENLSD_PASS);
    for ( i = 0; i < l; i++ )
    { // write retained values back to datastore
        llLinksetDataWrite( llList2String( retain, i ), llList2String( values, i ) );
    }
}

integer enLSD_Write(integer flags, list name, string data)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
    return llLinksetDataWrite(enLSD_Head() + llDumpList2String(name, "\n"), data);
}

string enLSD_Read(integer flags, list name)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
    return llLinksetDataRead(_enLSD_BuildHead(llGetScriptName(), prim) + llDumpList2String(name, "\n"));
}

list enLSD_Delete(integer flags, list name)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
    string regex;
    if (flags & FLAG_ENLSD_DELETE_CHILDREN) regex = "\n.*";
	return llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLSD_BuildHead(llGetScriptName(), prim) + llDumpList2String(name, "\n")) + regex + "$", "");
}

integer enLSD_Exists(integer flags, list name)
{
    return (enLSD_Find(flags, name, 0, 1) != []);
}

list enLSD_Find(integer flags, list name, integer start, integer count)
{
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_Find", ["flags", "name", "start", "count"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(name),
            start,
            count
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
	return llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLSD_BuildHead(llGetScriptName(), prim) + llDumpList2String(name, "\n")) + "$", start, count);
}

list enLSD_FindRegex(integer flags, string regex, integer start, integer count)
{ // note: do NOT include ^ and $ anchors in regex string, they will be added automatically
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_FindRegex", ["flags", "regex", "start", "count"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(regex),
            start,
            count
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
	return llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLSD_BuildHead(llGetScriptName(), prim)) + regex + "$", start, count);
}

list enLSD_DeleteRegex(integer flags, string regex)
{ // note: do NOT include ^ and $ anchors in regex string, they will be added automatically
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_DeleteRegex", ["flags", "regex"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(regex)
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLSD_ROOT) prim = enObject_Root();
	return llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLSD_BuildHead(llGetScriptName(), prim)) + regex + "$", "");
}

string _enLSD_BuildHead(
    string script_name,
    string uuid
)
{
    return uuid + "\n"
    #if defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER
        + script_name
    #endif
        + "\n";
}

//  purges all enLSD pairs assigned to UUIDs that are not part of this linkset
enLSD_Purge()
{
    string root = enObject_Root();
    list pair;
    integer i;
    integer start = llLinksetDataCountKeys();
    do
    {
        pair = llLinksetDataFindKeys("^[0-9a-fA-F-]{36}\n.*$", i, 1);
        if (pair != [])
        {
            string prim = llGetSubString(llList2String(pair, 0), 0, 35);
            string prim_root = llList2String(llGetObjectDetails(prim, [OBJECT_ROOT]), 0);
            string script = llList2String(pair, 1);
            if (prim != "" && prim_root != root)
            { // this pair is associated with a prim that doesn't share the same root as us
                enLog_Debug("Purging enLSD pairs associated with prim " + enObject_Elem(prim) + " (root " + enObject_Elem(prim_root) + ")");
                llLinksetDataDeleteFound("^" + prim + "\n.*$", ""); // delete all pairs scoped to this prim, since it's gone
                i = 0; // start search again
            }
            else if (script != "" && prim == (string)llGetKey() && llGetInventoryType(script) != INVENTORY_SCRIPT)
            { // this pair is associated with a script that is no longer in this prim
                enLog_Debug("Purging enLSD pairs associated with script \"" + script + "\" in prim " + enObject_Elem(prim) + " (root " + enObject_Elem(prim_root) + ")");
                llLinksetDataDeleteFound("^" + prim + "\n" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, script) + "\n.*$", ""); // delete all pairs scoped to this prim & script, since it's gone
                i = 0; // start search again
            }
            else i++; // progress to next index
        }
    }
    while (pair != []);
    enLog_Debug("Purged " + (string)(start - llLinksetDataCountKeys()) + " enLSD pairs");
}

// converts a raw LSD pair name to an enLSD name list
list enLSD_PairToName(
    string pair
)
{
    if (pair == "") return [];
    list elems = llParseStringKeepNulls(pair, ["\n"], []);
    integer head = enLSD_GetHeadCount();
    if (head) elems = llDeleteSubList(elems, 0, head - 1);
    return elems;
}

// utility function for enLSD_Check*
enLSD_MoveAllPairs(
    string k
)
{
    list l;
    #if defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER
        string old_head = _enLSD_BuildHead(_ENLSD_SCRIPT_NAME, k);
    #else
        string old_head = _enLSD_BuildHead("", k);
    #endif
    do
    {
        l = llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, old_head) + ".*$", 0, 1);
        if (l != [])
        {
            string old_pair = llList2String(l, 0);
            string pair_name = llDeleteSubString(old_pair, 0, llStringLength(old_head) - 1);
            enLog_Trace("LSD pair \"" + pair_name + "\" moved");
            llLinksetDataWrite(enLSD_Head() + pair_name, llLinksetDataRead(old_pair)); // write with updated header
            llLinksetDataDelete(old_pair); // immediately delete old pair to save memory
        }
    } while (l != []); // repeat until we didn't find any keys left with old header
}

// updates LSD entries that use old UUID
enLSD_CheckUUID()
{ // note: if FEATURE_ENLSD_DISABLE_UUID_CHECK is defined, this function is never called - only need to run enLSD_CheckUUID in one script in each prim
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_CheckUUID", [], []);
    #endif
    #if defined FEATURE_ENLSD_ENABLE_UUID_HEADER
        string k = enObject_Self(1); // get last key
        if (k == (string)llGetKey() || k == "") return; // no UUID change, or no UUID history stored
        enLog_Debug("Moving LSD due to UUID change from \"" + k + "\" to \"" + (string)llGetKey() + "\"");
        enLSD_MoveAllPairs(k);
    #endif
}

// updates LSD entries that use old script name
enLSD_CheckScriptName()
{
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_CheckScriptName", [], []);
    #endif
    #if defined FEATURE_ENLSD_ENABLE_SCRIPT_NAME_HEADER
        if (llGetScriptName() == _ENLSD_SCRIPT_NAME) return; // no script name change
        if (_ENLSD_SCRIPT_NAME != "")
        {
            enLog_Debug("Moving LSD due to script name change from \"" + _ENLSD_SCRIPT_NAME + "\" to \"" + llGetScriptName() + "\"");
            enLSD_MoveAllPairs(llGetKey());
        }
        _ENLSD_SCRIPT_NAME = llGetScriptName();
    #endif
}

// the below functions were never tested and are no longer "enLSD-compliant" so need to be rewritten at some point

/*enLSD_Pull( // reads a linkset data name-value pair FROM another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #if defined TRACE_ENLSD
        enLog_TraceParams("enLSD_Pull", ["prim", "domain", "use_header", "name"], [
            enObject_Elem(prim),
            enString_Elem(domain),
            use_header,
            enString_Elem(name)
            ]);
    #endif
    enCLEP_SendRaw(domain, prim, "enLSD_PullLSD", enList_ToString([use_header, name]));
}

enLSD_Push( // writes a linkset data name-value pair TO another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #if defined TRACE_ENLSD
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
    #if defined FEATURE_ENLSD_ENABLE_UUID_HEADER
        u = 1; // if FEATURE_ENLSD_ENABLE_UUID_HEADER defined, note in response
    #endif
    enCLEP_SendRaw(domain, prim, "enLSD_Push", enList_ToString([u, use_header, _ENLSD_HEADER, name, v]));
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
    #if defined TRACE_ENLSD
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
    #if !defined ENLSD_PUSHED_ALLOW_BROADCAST
        if (prim != (string)llGetKey()) return; // do not allow enLSD_Push calls sent to NULL_KEY
    #endif
    #if defined ENLSD_PUSHED_ADD_HEADER
        use_header = 1; // always use header when writing
    #endif
    #if defined ENLSD_PUSHED_UPDATE_HEADER
        if (use_header) header = _ENLSD_HEADER; // update header to local header
    #endif
    #if defined ENLSD_PUSHED_ADD_UUID
        use_uuid = 1; // always use uuid when writing (also define ENLSD_PUSHED_ADD_HEADER)
    #endif
    #if defined ENLSD_PUSHED_REMOVE_UUID
        use_uuid = 0; // never use uuid when writing (also define ENLSD_PUSHED_ADD_HEADER)
    #endif
    #if defined ENLSD_PUSHED_UPDATE_UUID
        // change header key if used
        if (use_uuid) header = llGetKey() + header;
    #else
        if (use_uuid) header = uuid + header;
    #endif
    #if defined ENLSD_PUSHED_EVENT
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
    #if defined ENLSD_PUSHED_WRITE
        if (!use_header) header = "";
        llLinksetDataWrite(header + name, value);
    #endif
}*/
