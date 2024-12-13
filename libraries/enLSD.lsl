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

#ifdef ENLSD$ENABLE_SCRIPT_NAME_HEADER
    string _ENLSD_SCRIPT_NAME;
#endif

// ==
// == macros
// ==

#define enLSD$Head() \
    _enLSD_BuildHead(llGetScriptName(), llGetKey())

// ==
// == functions
// ==

enLSD$Reset() // safely resets linkset data
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams( "enLSD$Reset", [], [] );
    #endif
    list protected = [
        "loglevel",
        "logtarget"
        ];
    list values;
    integer i;
    integer l = llGetListLength( protected );
    for ( i = 0; i < l; i++ )
    { // store values temporarily
        values += [ llLinksetDataRead( llList2String( protected, i ) ) ];
    }
    llLinksetDataDeleteFound("^" + enString$Escape(ENSTRING$ESCAPE_FILTER_REGEX, enLSD$Head()) + ".*$", "");
    for ( i = 0; i < l; i++ )
    { // write protected values back to datastore
        llLinksetDataWrite( llList2String( protected, i ), llList2String( values, i ) );
    }
}

integer enLSD$Write(string name, string data)
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Write", ["name", "data"], [
            enString$Elem(name),
            enString$Elem(data)
            ]);
    #endif
	return llLinksetDataWrite(enLSD$Head() + name, data);
}

string enLSD$Read(string name)
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Read", ["name"], [
            enString$Elem(name)
            ]);
    #endif
	return llLinksetDataRead(enLSD$Head() + name);
}

list enLSD$Delete(string name)
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Delete", ["name"], [
            enString$Elem(name)
            ]);
    #endif
	return llLinksetDataDeleteFound("^" + enLSD$Head() + name + "$", "");
}

integer enLSD$Exists(string name)
{
    return (enLSD$Find(name, 0, 1) != []);
}

list enLSD$Find(string name, integer start, integer count)
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Find", ["name", "start", "count"], [
            enString$Elem(name),
            start,
            count
            ]);
    #endif
	return llLinksetDataFindKeys("^" + enString$Escape(ENSTRING$ESCAPE_FILTER_REGEX, enLSD$Head() + name) + "$", start, count);
}

string enLSD$BuildHead(
    string script_name,
    string uuid
)
{
    string h = ENLSD$HEADER + "\n";
    integer count = 1;
    #ifdef ENLSD$ENABLE_SCRIPT_NAME_HEADER
        h = llGetSubString(llSHA256String(script_name), 0, 7) + "\n" + h; // prepend first 8 chars of SHA256 hashed script name
        count++;
    #endif
    #ifdef ENLSD$ENABLE_UUID_HEADER
        h = llGetSubString(uuid, 0, 7) + "\n" + h; // prepend first 8 chars of llGetKey to start of string to avoid linkset conflicts
        count++;
    #endif
    return (string)count + "\n" + h;
}

enLSD$Pull( // reads a linkset data name-value pair FROM another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Pull", ["prim", "domain", "use_header", "name"], [
            enObject$Elem(prim),
            enString$Elem(domain),
            use_header,
            enString$Elem(name)
            ]);
    #endif
    enCLEP$Send(prim, domain, "enLSD$PullLSD", enList$ToString([use_header, name]));
}

enLSD$Push( // writes a linkset data name-value pair TO another script, optionally using the active enLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Push", ["prim", "domain", "use_header", "name"], [
            enObject$Elem(prim),
            enString$Elem(domain),
            use_header,
            enString$Elem(name)
            ]);
    #endif
    string v;
    if (use_header) v = enLSD$Read(name);
    else v = llLinksetDataRead(name);
    integer u;
    #ifdef ENLSD$ENABLE_UUID_HEADER
        u = 1; // if ENLSD$ENABLE_UUID_HEADER defined, note in response
    #endif
    enCLEP$Send(prim, domain, "enLSD$Push", enList$ToString([u, use_header, ENLSD$HEADER, name, v]));
}

list enLSD$GetPairHead( // returns the header from a specified LSD pair name
    string pair
)
{
    list parts = llParseStringKeepNulls(pair, ["\n"], []);
    if ((integer)llList2String(parts, 0) < 2) return []; // number of elements must be at least 2 (number of elements, ENLSD$HEADER)
    return llList2List(parts, 1, (integer)llList2String(parts, 0) - 1);
}

enLSD$Process( // writes a linkset data name-value pair FROM another script
    string prim,
    integer use_uuid,
    integer use_header,
    string uuid,
    string header,
    string name,
    string value
    )
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$Process", ["prim", "use_uuid", "use_header", "uuid", "header", "name", "value"], [
            enObject$Elem(prim),
            use_uuid,
            use_header,
            enString$Elem(uuid),
            enString$Elem(header),
            enString$Elem(name),
            enString$Elem(value)
            ]);
    #endif
    #ifndef ENLSD$PUSHED_ALLOW_BROADCAST
        if (prim != (string)llGetKey()) return; // do not allow enLSD$Push calls sent to NULL_KEY
    #endif
    #ifdef ENLSD$PUSHED_ADD_HEADER
        use_header = 1; // always use header when writing
    #endif
    #ifdef ENLSD$PUSHED_UPDATE_HEADER
        if (use_header) header = ENLSD$HEADER; // update header to local header
    #endif
    #ifdef ENLSD$PUSHED_ADD_UUID
        use_uuid = 1; // always use uuid when writing (also define ENLSD$PUSHED_ADD_HEADER)
    #endif
    #ifdef ENLSD$PUSHED_REMOVE_UUID
        use_uuid = 0; // never use uuid when writing (also define ENLSD$PUSHED_ADD_HEADER)
    #endif
    #ifdef ENLSD$PUSHED_UPDATE_UUID
        // change header key if used
        if (use_uuid) header = llGetKey() + header;
    #else
        if (use_uuid) header = uuid + header;
    #endif
    #ifdef ENLSD$PUSHED_EVENT
        en$pushed_lsd(
            prim,
            use_uuid,
            use_header,
            uuid,
            header,
            name,
            value
            );
    #endif
    #ifdef ENLSD$PUSHED_WRITE
        if (!use_header) header = "";
        llLinksetDataWrite(header + name, value);
    #endif
}

enLSD$MoveAllPairs( // utility function for enLSD$Check*
    string k
)
{
    list l;
    string old_head = enLSD$BuildHead(_ENLSD_SCRIPT_NAME, k);
    do
    {
        l = llLinksetDataFindKeys("^" + enString$Escape(ENSTRING$ESCAPE_FILTER_REGEX, old_head) + ".*$", 0, 1);
        if (l != [])
        {
            string old_pair = llList2String(l, 0);
            string pair_name = llDeleteSubString(old_pair, 0, llStringLength(old_head) - 1);
            enLog$Trace("LSD pair \"" + pair_name + "\" moved");
            llLinksetDataWrite(enLSD$Head() + pair_name, llLinksetDataRead(old_pair)); // write with updated header
            llLinksetDataDelete(old_pair); // immediately delete old pair to save memory
        }
    } while (l != []); // repeat until we didn't find any keys left with old header
}

enLSD$CheckUUID() // updates LSD entries that use old UUID
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$CheckUUID", [], []);
    #endif
    #ifdef ENLSD$ENABLE_UUID_HEADER
        string k = enObject$Self( 0 ); // get last key
        if (k == (string)llGetKey() || k == "") return; // no UUID change, or no UUID history stored
        enLog$Debug("Moving LSD due to UUID change from \"" + k + "\" to \"" + (string)llGetKey() + "\"");
        enLSD$MoveAllPairs(k);
    #endif
}

enLSD$CheckScriptName() // updates LSD entries that use old script name
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$CheckScriptName", [], []);
    #endif
    #ifdef ENLSD$ENABLE_SCRIPT_NAME_HEADER
        if (llGetScriptName() == _ENLSD_SCRIPT_NAME) return; // no script name change
        if (_ENLSD_SCRIPT_NAME != "")
        {
            enLog$Debug("Moving LSD due to script name change from \"" + _ENLSD_SCRIPT_NAME + "\" to \"" + llGetScriptName() + "\"");
            enLSD$MoveAllPairs(llGetKey());
        }
        _ENLSD_SCRIPT_NAME = llGetScriptName();
    #endif
}
