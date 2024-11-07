/*
    XiLSD.lsl
    Library
    Xi LSL Framework
    Revision 0
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
#define XILSD_ENABLE_XILOG_TRACE
#endif

#ifndef XILSD_HEADER
#define XILSD_HEADER ""
#endif

// ==
// == functions
// ==

// TODO: automatic LSD backup to KVP

XiLSD_Reset() // safely resets linkset data
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams( "XiLSD_Reset", [], [] );
    #endif
    list protected = [
        "loglevel"
        ];
    list values;
    integer i;
    integer l = llGetListLength( protected );
    for ( i = 0; i < l; i++ )
    { // store values temporarily
        values += [ llLinksetDataRead( llList2String( protected, i ) ) ];
    }
    llLinksetDataReset();
    for ( i = 0; i < l; i++ )
    { // write protected values back to datastore
        llLinksetDataWrite( llList2String( protected, i ), llList2String( values, i ) );
    }
}

integer XiLSD_Write(string name, string data)
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Write", ["name", "data"], [
            XiString_Elem(name),
            XiString_Elem(data)
            ]);
    #endif
	return llLinksetDataWrite(XiLSD_Head() + name, data);
}

string XiLSD_Read(string name)
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Read", ["name"], [
            XiString_Elem(name)
            ]);
    #endif
	return llLinksetDataRead(XiLSD_Head() + name);
}

list XiLSD_Delete(string name)
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Delete", ["name"], [
            XiString_Elem(name)
            ]);
    #endif
	return llLinksetDataDeleteFound("^" + XiLSD_Head() + name + "$", "");
}

list XiLSD_Find(string name, integer start, integer count)
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Find", ["name", "start", "count"], [
            XiString_Elem(name),
            start,
            count
            ]);
    #endif
	return llLinksetDataFindKeys("^" + XiString_Escape(XISTRING_ESCAPE_REGEX, XiLSD_Head() + name) + "$", start, count);
}

string XiLSD_Head() // gets LSD header
{
    string h = XILSD_HEADER;
    #ifdef XILSD_ENABLE_UUID_HEADER
        h = llGetKey() + h; // if XILSD_ENABLE_UUID_HEADER defined, append llGetKey to start of string to avoid linkset conflicts
    #endif
    return h;
}

XiLSD_Pull( // reads a linkset data name-value pair FROM another script, optionally using the active XiLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Pull", ["prim", "domain", "use_header", "name"], [
            XiObject_Elem(prim),
            XiString_Elem(domain),
            use_header,
            XiString_Elem(name)
            ]);
    #endif
    XiChat_Send(prim, domain, "XiLSD_PullLSD", XiList_ToString([use_header, name]));
}

XiLSD_Push( // writes a linkset data name-value pair TO another script, optionally using the active XiLSD header
    string prim,
    string domain,
    integer use_header,
    string name
    )
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiLSD_Push", ["prim", "domain", "use_header", "name"], [
            XiObject_Elem(prim),
            XiString_Elem(domain),
            use_header,
            XiString_Elem(name)
            ]);
    #endif
    string v;
    if (use_header) v = XiLSD_Read(name);
    else v = llLinksetDataRead(name);
    integer u;
    #ifdef XILSD_ENABLE_UUID_HEADER
        u = 1; // if XILSD_ENABLE_UUID_HEADER defined, note in response
    #endif
    XiChat_Send(prim, domain, "XiLSD_Push", XiList_ToString([u, use_header, XILSD_HEADER, name, v]));
}

_XiLSD_Process( // writes a linkset data name-value pair FROM another script
    string prim,
    integer use_uuid,
    integer use_header,
    string uuid,
    string header,
    string name,
    string value
    )
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiLSD_Process", ["prim", "use_uuid", "use_header", "uuid", "header", "name", "value"], [
            XiObject_Elem(prim),
            use_uuid,
            use_header,
            XiString_Elem(uuid),
            XiString_Elem(header),
            XiString_Elem(name),
            XiString_Elem(value)
            ]);
    #endif
    #ifndef XILSD_PUSHED_ALLOW_BROADCAST
        if (prim != (string)llGetKey()) return; // do not allow XiLSD_Push calls sent to NULL_KEY
    #endif
    #ifdef XILSD_PUSHED_ADD_HEADER
        use_header = 1; // always use header when writing
    #endif
    #ifdef XILSD_PUSHED_UPDATE_HEADER
        if (use_header) header = XILSD_HEADER; // update header to local header
    #endif
    #ifdef XILSD_PUSHED_ADD_UUID
        use_uuid = 1; // always use uuid when writing (also define XILSD_PUSHED_ADD_HEADER)
    #endif
    #ifdef XILSD_PUSHED_REMOVE_UUID
        use_uuid = 0; // never use uuid when writing (also define XILSD_PUSHED_ADD_HEADER)
    #endif
    #ifdef XILSD_PUSHED_UPDATE_UUID
        // change header key if used
        if (use_uuid) header = llGetKey() + header;
    #else
        if (use_uuid) header = uuid + header;
    #endif
    #ifdef XILSD_PUSHED_EVENT
        Xi_pushed_lsd(
            prim,
            use_uuid,
            use_header,
            uuid,
            header,
            name,
            value
            );
    #endif
    #ifdef XILSD_PUSHED_WRITE
        if (!use_header) header = "";
        llLinksetDataWrite(header + name, value);
    #endif
}

_XiLSD_CheckUUID() // updates LSD entries that use old UUID
{
    #ifdef XILSD_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiLSD_CheckUUID", [], []);
    #endif
    #ifdef XILSD_ENABLE_UUID_HEADER
        string k = llList2String(XIOBJECT_UUIDS_SELF, 0);
        if (k == (string)llGetKey()) return; // no UUID change
        string h = XILSD_HEADER;
        h = k + h;
        do
        {
            list l = llLinksetDataFindKeys("^" + XiString_Escape(XISTRING_ESCAPE_REGEX, h) + ".*$", 0, 1);
            if (l != [])
            {
                llLinksetDataWrite(_XiLSD_Head() + llDeleteSubString(llList2String(l, 0), 0, llStringLength(h) - 1)); // write with updated header
                llLinksetDataDelete(llList2String(l, 0)); // immediately delete old pair to save memory
            }
        } while (l != []); // repeat until we didn't find any keys left with old header
    #endif
}
