/*
enLNX.lsl
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

// safely resets LNX namespaces
enLNX_Reset(
    integer flags
)
{
    #if defined TRACE_ENLNX
        enLog_TraceParams(
            "enLNX_Reset",
            [
                "flags"
            ],
            [
                flags
            ]
        );
    #endif

    // erase all pairs starting with the head defined by flags
    llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, enLNX_Head(flags)) + ".*$", "");
}

integer enLNX_Write(integer flags, list name, string data)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
    return llLinksetDataWrite(enLNX_Head(flags) + llDumpList2String(name, "\n"), data);
}

string enLNX_Read(integer flags, list name)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
    return llLinksetDataRead(_enLNX_BuildHead(flags, llGetScriptName(), prim) + llDumpList2String(name, "\n"));
}

list enLNX_Delete(integer flags, list name)
{
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
    string regex;
    if (flags & FLAG_ENLNX_DELETE_CHILDREN) regex = "\n.*";
	return llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLNX_BuildHead(flags, llGetScriptName(), prim) + llDumpList2String(name, "\n")) + regex + "$", "");
}

integer enLNX_Exists(integer flags, list name)
{
    return (enLNX_Find(flags, name, 0, 1) != []);
}

list enLNX_Find(integer flags, list name, integer start, integer count)
{
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_Find", ["flags", "name", "start", "count"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(name),
            start,
            count
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
	return llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLNX_BuildHead(flags, llGetScriptName(), prim) + llDumpList2String(name, "\n")) + "$", start, count);
}

list enLNX_FindRegex(integer flags, string regex, integer start, integer count)
{ // note: do NOT include ^ and $ anchors in regex string, they will be added automatically
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_FindRegex", ["flags", "regex", "start", "count"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(regex),
            start,
            count
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
	return llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLNX_BuildHead(flags, llGetScriptName(), prim)) + regex + "$", start, count);
}

list enLNX_DeleteRegex(integer flags, string regex)
{ // note: do NOT include ^ and $ anchors in regex string, they will be added automatically
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_DeleteRegex", ["flags", "regex"], [
            enInteger_ElemBitfield(flags),
            enString_Elem(regex)
            ]);
    #endif
    string prim = (string)llGetKey();
    if (flags & FLAG_ENLNX_ROOT) prim = enPrim_GetMyRoot();
	return llLinksetDataDeleteFound("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, _enLNX_BuildHead(flags, llGetScriptName(), prim)) + regex + "$", "");
}

string _enLNX_BuildHead(
    string script_name,
    string prim_uuid,
    integer flags
)
{
    if (~flags & FLAG_ENLNX_SCRIPT_SCOPE) script_name = ""; // erase script_name if we are not in script-scope namespace
    if (~flags & (FLAG_ENLNX_SCRIPT_SCOPE | FLAG_ENLNX_PRIM_SCOPE)) prim_uuid = ""; // we are not using prim- or script-scope namespace, so erase prim_uuid (linkset-scope)
    else if (flags & FLAG_ENLNX_ROOT) prim_uuid = enPrim_GetMyRoot(); // if we are specifically using the root namespace, replace prim_uuid if we are using prim- or script-scope namespace
    return llReplaceSubString(prim_uuid, "\n", "", 0) + "\n" + llReplaceSubString(script_name, "\n", "", 0) + "\n"; // filter out newlines to enforce LNX spec compliance
}

//  purges all enLNX pairs assigned to UUIDs that are not part of this linkset
enLNX_Purge()
{
    string root = enPrim_GetMyRoot();
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
                enLog_Debug("Purging enLNX pairs associated with prim " + enPrim_Elem(prim) + " (root " + enPrim_Elem(prim_root) + ")");
                llLinksetDataDeleteFound("^" + prim + "\n.*$", ""); // delete all pairs scoped to this prim, since it's gone
                i = 0; // start search again
            }
            else if (script != "" && prim == (string)llGetKey() && llGetInventoryType(script) != INVENTORY_SCRIPT)
            { // this pair is associated with a script that is no longer in this prim
                enLog_Debug("Purging enLNX pairs associated with script \"" + script + "\" in prim " + enPrim_Elem(prim) + " (root " + enPrim_Elem(prim_root) + ")");
                llLinksetDataDeleteFound("^" + prim + "\n" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, script) + "\n.*$", ""); // delete all pairs scoped to this prim & script, since it's gone
                i = 0; // start search again
            }
            else i++; // progress to next index
        }
    }
    while (pair != []);
    enLog_Debug("Purged " + (string)(start - llLinksetDataCountKeys()) + " enLNX pairs");
}

// converts a raw LSD pair name to an enLNX name list
list enLNX_PairToName(
    string pair
)
{
    if (pair == "") return [];
    list elems = llParseStringKeepNulls(pair, ["\n"], []);
    integer head = enLNX_GetHeadCount();
    if (head) elems = llDeleteSubList(elems, 0, head - 1);
    return elems;
}

/*
NOTE: FLAG_ENLNX_PRIM_SCOPE and FLAG_ENLNX_SCRIPT_SCOPE do not limit the scope of migration, but rather the method:
FLAG_ENLNX_PRIM_SCOPE migrates pairs where the old prim_uuid matches the selector, which is replaced by llGetKey()
FLAG_ENLNX_SCRIPT_SCOPE migrates pairs where the old prim_uuid matches llGetKey() and the old script_name matches the selector, which is replaced by llGetScriptName()
*/
enLNX_Migrate(
    integer flags,
    string selector
)
{
    // can't migrate linkset-scope pairs in prim mode, or linkset/prim-scope pairs in script mode
    // can't migrate linkset-scope pairs (neither scope flag set)
    // can't migrate if both flags are set
    if (selector == "" || ~flags & (FLAG_ENLNX_PRIM_SCOPE | FLAG_ENLNX_SCRIPT_SCOPE) || (flags & FLAG_ENLNX_PRIM_SCOPE && flags & FLAG_ENLNX_SCRIPT_SCOPE)) return;
    if (flags & FLAG_ENLNX_PRIM_SCOPE) enLog_Debug("Migrating LNX datastore for prim " + enPrim_Elem(selector));
    else enLog_Debug("Migrating LNX datastore for script " + enString_EscapedQuote(selector));
    list l;
    do
    {
        if (flags & FLAG_ENLNX_PRIM_SCOPE) // find keys where prim_uuid matches selector, any script_name
            l = llLinksetDataFindKeys("^" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, selector) + "\n.*\n.*$", 0, 1);
        else // find keys where prim_uuid is llGetKey(), and script_name matches selector
            l = llLinksetDataFindKeys("^" + (string)llGetKey() + "\n" + enString_Escape(FLAG_ENSTRING_ESCAPE_FILTER_REGEX, selector) + "\n.*$", 0, 1);
        if (l != [])
        {
            list old_pair = llParseStringKeepNulls(llList2String(l, 0), ["\n"], []);
            string old_prim_uuid = llList2String(old_pair, 0);
            string old_script_name = llList2String(old_pair, 1);

            list new_pair;
            if (flags & FLAG_ENLNX_PRIM_SCOPE) // replace prim_uuid
                new_pair = llListReplaceList(new_pair, [(string)llGetKey()], 0, 0);
            else // replace script_name
                new_pair = llListReplaceList(new_pair, [llGetScriptName()], 1, 1);

            string type = "prim-scope";
            if (old_script_name != "") type = "script-scope (\"" + enString_Escape(old_script_name) + "\")";
            enLog_Trace("LNX " + type + " pair [\"" + llDumpList2String(llList2List(old_pair, 2, -1), "\", \"") + "\"] migrated");
            
            llLinksetDataWrite(llDumpList2String(new_pair, "\n"), llLinksetDataRead(old_pair)); // write with modified pair name
            llLinksetDataDelete(old_pair); // immediately delete old pair
        }
    }
    while (l != []); // repeat until we didn't find any keys left with old header
}

// updates LSD entries that use old script name
enLNX_CheckScriptName()
{
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_CheckScriptName", [], []);
    #endif
    #if defined FEATURE_ENLNX_ENABLE_SCRIPT_NAME_HEADER
        if (llGetScriptName() == _ENLNX_SCRIPT_NAME) return; // no script name change
        if (_ENLNX_SCRIPT_NAME != "")
        {
            enLog_Debug("Migrating LNX namespaces due to script name change");
            enLNX_Migrate(FLAG_ENLNX_SCRIPT_SCOPE, llGetKey());
        }
        _ENLNX_SCRIPT_NAME = llGetScriptName();
    #endif
}

_enLNX_uuid_changed(
    string last_uuid
)
{
    // if FEATURE_ENLNX_PRIM_MONITOR is not defined, we do not need to migrate
    #if defined FEATURE_ENLNX_ENABLE_SCOPE && defined FEATURE_ENLNX_PRIM_MONITOR
        enLog_Debug("Migrating LNX namespaces due to prim UUID change");
        enLNX_Migrate(FLAG_ENLNX_PRIM_SCOPE, last_uuid);
    #endif
}

_enLNX_changed(
    integer change
)
{
    if (change & CHANGED_INVENTORY) enLNX_CheckScriptName(); // migrate script-scope pairs to new script name
}

_enLNX_on_rez(
    integer param
)
{
    // update enLNX names if any use the UUID header
    #if defined FEATURE_ENLNX_ENABLE_SCOPE && defined FEATURE_ENLNX_PRIM_MONITOR
        _enLNX_uuid_changed(enPrim_GetMyLast(1));
    #endif
}

// the below functions were never tested and are no longer "enLNX-compliant" so need to be rewritten at some point

/*enLNX_Pull( // reads a linkset data name-value pair FROM another script, optionally using the active enLNX header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_Pull", ["prim", "domain", "use_header", "name"], [
            enPrim_Elem(prim),
            enString_Elem(domain),
            use_header,
            enString_Elem(name)
            ]);
    #endif
    enCLEP_SendRaw(domain, prim, "enLNX_PullLSD", enList_ToEscapedCSV([use_header, name]));
}

enLNX_Push( // writes a linkset data name-value pair TO another script, optionally using the active enLNX header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_Push", ["prim", "domain", "use_header", "name"], [
            enPrim_Elem(prim),
            enString_Elem(domain),
            use_header,
            enString_Elem(name)
            ]);
    #endif
    string v;
    if (use_header) v = enLNX_Read(name);
    else v = llLinksetDataRead(name);
    integer u;
    #if defined FEATURE_ENLNX_ENABLE_SCOPE
        u = 1; // if FEATURE_ENLNX_ENABLE_SCOPE defined, note in response
    #endif
    enCLEP_SendRaw(domain, prim, "enLNX_Push", enList_ToEscapedCSV([u, use_header, _ENLNX_HEADER, name, v]));
}

enLNX_Process( // writes a linkset data name-value pair FROM another script
    string prim,
    integer use_uuid,
    integer use_header,
    string uuid,
    string header,
    string name,
    string value
    )
{
    #if defined TRACE_ENLNX
        enLog_TraceParams("enLNX_Process", ["prim", "use_uuid", "use_header", "uuid", "header", "name", "value"], [
            enPrim_Elem(prim),
            use_uuid,
            use_header,
            enString_Elem(uuid),
            enString_Elem(header),
            enString_Elem(name),
            enString_Elem(value)
            ]);
    #endif
    #if !defined ENLNX_PUSHED_ALLOW_BROADCAST
        if (prim != (string)llGetKey()) return; // do not allow enLNX_Push calls sent to NULL_KEY
    #endif
    #if defined ENLNX_PUSHED_ADD_HEADER
        use_header = 1; // always use header when writing
    #endif
    #if defined ENLNX_PUSHED_UPDATE_HEADER
        if (use_header) header = _ENLNX_HEADER; // update header to local header
    #endif
    #if defined ENLNX_PUSHED_ADD_UUID
        use_uuid = 1; // always use uuid when writing (also define ENLNX_PUSHED_ADD_HEADER)
    #endif
    #if defined ENLNX_PUSHED_REMOVE_UUID
        use_uuid = 0; // never use uuid when writing (also define ENLNX_PUSHED_ADD_HEADER)
    #endif
    #if defined ENLNX_PUSHED_UPDATE_UUID
        // change header key if used
        if (use_uuid) header = llGetKey() + header;
    #else
        if (use_uuid) header = uuid + header;
    #endif
    #if defined ENLNX_PUSHED_EVENT
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
    #if defined ENLNX_PUSHED_WRITE
        if (!use_header) header = "";
        llLinksetDataWrite(header + name, value);
    #endif
}*/
