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
// == functions
// ==

// TODO: automatic LSD backup to KVP

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

string enLSD$Head() // gets LSD header
{
    string h = ENLSD$HEADER;
    #ifdef ENLSD$ENABLE_UUID_HEADER
        h = llGetKey() + h; // if ENLSD$ENABLE_UUID_HEADER defined, append llGetKey to start of string to avoid linkset conflicts
    #endif
    return h;
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

enLSD$CheckUUID() // updates LSD entries that use old UUID
{
    #ifdef ENLSD$TRACE
        enLog$TraceParams("enLSD$CheckUUID", [], []);
    #endif
    #ifdef ENLSD$ENABLE_UUID_HEADER
        string k = enObject$Self( 0 );
        if (k == (string)llGetKey()) return; // no UUID change
        string h = ENLSD$HEADER;
        h = k + h;
        do
        {
            list l = llLinksetDataFindKeys("^" + enString$Escape(ENSTRING$ESCAPE_FILTER_REGEX, h) + ".*$", 0, 1);
            if (l != [])
            {
                llLinksetDataWrite(_enLSD$Head() + llDeleteSubString(llList2String(l, 0), 0, llStringLength(h) - 1)); // write with updated header
                llLinksetDataDelete(llList2String(l, 0)); // immediately delete old pair to save memory
            }
        } while (l != []); // repeat until we didn't find any keys left with old header
    #endif
}
