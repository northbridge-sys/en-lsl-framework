/*
    XiChat.lsl
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

    This is an LSL Preprocessor include file that implements an overwhelmingly
    simple hashing algorithm that allows llListen channels to be defined using a
    domain (string set at run-time) and a service (string set at compile-time)
    hashed into a 32-bit integer (avoiding PUBLIC_CHANNEL and DEBUG_CHANNEL). This
    triggers the simulator-side filter for llListen channels and avoids having to
    execute the listen(...) event and waste script time.

    When XICHAT_ENABLE_PTP is defined, this file also offers a method of sending
    messages longer than 1024 bytes via chat using an in-memory buffer.

    What this is NOT:
        - Secure. Anyone with sufficient time and effort (and not a lot) can scan
            the entire integer channel spectrum, then capture your domain & service,
            which are sent plain-text inside the message, as well as the message
            itself.
        - An authentication mechanism.
        - A method of obfuscating text sent via chat or llMessageLinked. XiChat is
            intended to pass human-readable and easily-parsed IMP traffic over chat.
            If security is required, consider encrypting separately before sending
            IMP messages, ideally signed, but be aware that the domain & service are
            not hidden. (Or just use an external HTTPS server.)
        - A method of sending infinite-length strings. PTP has no memory overflow
            protection and should only be used for strings that you know will fit in
            memory for both the source and the target scripts.

    To define the service string, call XiChat$SetService( service ). Any string
    supported by llSHA256String can be used. This will be used twice:
        - Appended to the start of all chat messages in plain text for filtering.
        - Hashed against the domain to generate the integer channel for llListen.

    XiChat$Listen(...) will return 0 and fail to add the listen if you attempt to
    add more than 65 listeners (the maXimum allowed per script). If you call
    llListen separately, set the number of listens you want reserved for non-XiChat\
    use by adding the following line:
        #define XICHAT_RESERVE_LISTENS x
    where x is the number of listens you want to allocate for non-XiChat use.

    Note: domains can be set as the local prim's UUID, in which case they will be
    automatically refreshed on key or link change. However, this ONLY works if the
    domain itself is just the UUID - no other data can be added.

    WARNING: If the local prim's UUID is used as the domain, you MUST use the
    state_entry, on_rez, and changed event handler include files, which will
    dynamically update the domain after a key change. (This is done automatically
    in event-handlers.lsl if you use it.)
*/

// ==
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XICHAT_ENABLE_XILOG_TRACE
#endif

#ifndef XICHAT_RESERVE_LISTENS
#define XICHAT_RESERVE_LISTENS 0
#endif

#ifndef XICHAT_PTP_SIZE
// note that this value is set to the maximum number of UTF-8 characters that can be sent via llRegionSayTo
// if you are positive you will ALWAYS have ASCII-7 characters, this can be raised to 1024 for better performance and lower memory usage
#define XICHAT_PTP_SIZE 512
#endif

// ==
// == preprocessor flags
// ==

#define XICHAT_LISTEN_OWNERONLY 0x1
#define XICHAT_LISTEN_REMOVE 0x80000000

// ==
// == globals
// ==

string XICHAT_SERVICE;

list XICHAT_DOMAINS; // domain, flags, channel, handle
#define XICHAT_DOMAINS_STRIDE 4

#ifdef XICHAT_ENABLE_PTP
    list XICHAT_PTP; // transfer_key, prim ("" for inbound), domain, message_buffer
    #define XICHAT_PTP_STRIDE 4
#endif

// ==
// == functions
// ==

#define XiChat$GetService(...) _XiChat_GetService( __VA_ARGS__ )
string XiChat$GetService()
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams( "XiChat$GetService", [], [] );
    #endif
    return XICHAT_SERVICE;
}

#define XiChat$SetService(...) _XiChat_SetService( __VA_ARGS__ )
XiChat$SetService(
    string service
    )
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams( "XiChat$SetService", [ "service" ], [
            XiString$Elem( service )
            ] );
    #endif
    XICHAT_SERVICE = service;
}

#define XiChat$Channel(...) _XiChat_Channel( __VA_ARGS__ )
integer XiChat$Channel( // converts a string into an integer, hashed with XICHAT_SERVICE, can be called externally for dialog listeners
    string domain  // domain string to use to generate integer channel
    )
{
    integer chan = (integer)("0x" + llGetSubString(llSHA256String(domain + XiChat$GetService()), -8, -1));
    if (chan == PUBLIC_CHANNEL || chan == DEBUG_CHANNEL) chan++; // filter out channels that can be seen in the viewer by default
    return chan;
}

#define XiChat$RegionSayTo(...) _XiChat_RegionSayTo( __VA_ARGS__ )
XiChat$RegionSayTo( // llRegionSayTo with llRegionSay for NULL_KEY instead of silently failing
    string prim,
    integer channel,
    string message
    )
{
    if (prim == NULL_KEY) llRegionSay(channel, message);
    else llRegionSayTo(prim, channel, message);
}

#define XiChat$Send(...) _XiChat_Send( __VA_ARGS__ )
XiChat$Send( // send via XiChat
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("XiChat$Send", ["prim", "domain", "type", "message", "(service)" ], [
            XiObject$Elem(prim),
            XiString$Elem(domain),
            XiString$Elem(type),
            XiString$Elem(message),
            XiString$Elem(XICHAT_SERVICE)
            ]);
    #endif
    XiChat$RegionSayTo(prim, XiChat$Channel(domain), XiList$ToString(["XiChat", XICHAT_SERVICE, prim, domain, type, message]));
}

#define XiChat$SendPTP(...) _XiChat_SendPTP( __VA_ARGS__ )
XiChat$SendPTP( // send via XiChat using the Packet Transfer Protocol
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("XiChat$SendPTP", ["prim", "domain", "type", "message", "(service)" ], [
            XiObject$Elem(prim),
            XiString$Elem(domain),
            XiString$Elem(type),
            XiString$Elem(message),
            XiString$Elem(XICHAT_SERVICE)
            ]);
    #endif
    #ifndef XICHAT_ENABLE_PTP
        XiLog(WARN, "XiChat$SendPTP called but XICHAT_ENABLE_PTP not defined.");
    #else
        message = XiList$ToString(["XiChat", XICHAT_SERVICE, prim, domain, type, message]); // add XiChat$PTP header to message to be sent
        // 51 + llStringLength(...) is length of "10\nXiChat$PTP32\n00000000000000000000000000000000" + {packet_size} + "\n"
        max = XICHAT_PTP_SIZE - (51 + llStringLength((string)llStringLength(XICHAT_PTP_SIZE))); // get maXimum length of packet after XiChat$PTP header via XiList$ToString
        string k = llGenerateKey(); // transfer key for identifying a specific message in transit
        string c = XiChat$Channel(domain);
        XiChat$RegionSayTo(prim, c, XiList$ToString(["XiChat$PTP", domain, k, llGetSubString(message, 0, max - 2)])); // first packet gets sent immediately
        if (llStringLength(message) > max) XICHAT_PTP += [k, prim, "", llDeleteSubString(message, 0, max - 2)]; // we don't need to save domain here
        // TODO: some cleanup function that clears stalled transfers (in and out) from XICHAT_PTP_QUEUE
    #endif
}

#define XiChat$Listen(...) _XiChat_Listen( __VA_ARGS__ )
integer XiChat$Listen(  // initializes or updates a dynamically managed llListen
    string domain,  // domain to listen to "within" XICHAT_SERVICE
    integer flags   // XICHAT_LISTEN_* flags
    )
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("XiChat$Listen", ["domain", "flags", "(service)"], [
            XiString$Elem(domain),
            XiInteger$ElemBitfield(flags),
            XiString$Elem(XICHAT_SERVICE)
            ]);
    #endif
    _XiChat$UnListenDomains();
    integer index = llListFindList(llList2ListSlice(XICHAT_DOMAINS, 0, -1, XICHAT_DOMAINS_STRIDE, 0), [domain]);
    if (index == -1 && flags & XICHAT_LISTEN_REMOVE)
    { // nothing to remove, so return error
        _XiChat$ListenDomains();
        return 0;
    }
    if (index != -1)
    { // delete eXisting domain XiChat, so it can be cleanly appended to the end
        XICHAT_DOMAINS = llDeleteSubList(XICHAT_DOMAINS, index * XICHAT_DOMAINS_STRIDE, (index + 1) * XICHAT_DOMAINS_STRIDE - 1);
    }
    if (llGetListLength(XICHAT_DOMAINS) + 1 > 65 - XICHAT_RESERVE_LISTENS)
    { // too many listens
        _XiChat$ListenDomains();
        return 0;
    }
    if (!(flags & XICHAT_LISTEN_REMOVE))
    { // add to XICHAT_DOMAINS only if we aren't removing it
        XICHAT_DOMAINS += [domain, flags, XiChat$Channel(domain), 0];
    }
    _XiChat$ListenDomains();
    return 1;
}

#define _XiChat$Process(...) _XiChat_Process( __VA_ARGS__ )
integer _XiChat$Process(
    integer channel,
    string name,
    key id,
    string message
    )
{
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("_XiChat$Process", ["channel", "name", "id", "message"], [
            channel,
            XiString$Elem(name),
            XiString$Elem(id),
            XiString$Elem(message)
            ]);
    #endif
    list data = XiList$FromStr(message);
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceVars(["data"], [
            XiList$Elem(data)
            ]);
    #endif
    if (llGetListLength(data) != 6) return 0; // error in XiChat unserialize operation
    #ifdef XICHAT_ENABLE_PTP
        if (llList2String(data, 0) == "XiChat$PTP")
        { // we have a PTP packet
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            string m = llList2String(data, 3); // message fragment
            integer i = llListFindList(llList2ListSlice(XICHAT_PTP, 0, -1, XICHAT_PTP_STRIDE, 0), [k]);
            if (m == "")
            { // end of received message
                if (i == -1) return 1; // nothing in queue
                _XiChat$Process(channel, name, id, llList2String(XICHAT_PTP, i * XICHAT_PTP_STRIDE + 3)); // release buffer from queue
                XICHAT_PTP = llDeleteSubList(XICHAT_PTP, i * XICHAT_PTP_STRIDE, (i + 1) * XICHAT_PTP_STRIDE - 1); // clear transfer from queue
                return 1;
            }
            if (i == -1) XICHAT_PTP = [k, "", channel, m]; // create new buffer
            else XICHAT_PTP = llListReplaceList(XICHAT_PTP, [llList2String(XICHAT_PTP, i * XICHAT_PTP_STRIDE + 3) + m], i * XICHAT_PTP_STRIDE + 3, i * XICHAT_PTP_STRIDE + 3); // append to eXisting buffer
            XiChat$RegionSayTo(id, XiChat$Channel(d), XiList$ToString(["XiChat$PTP_More", d, k])); // request next message fragment
            return 1;
        }
        if (llList2String(data, 0) == "XiChat$PTP_More")
        { // someone is requesting the next message fragment
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            integer i = llListFindList(llList2ListSlice(XICHAT_PTP, 0, -1, XICHAT_PTP_STRIDE, 0), [k]);
            if (i == -1)
            { // we have nothing to send, because this transfer_key does not eXist in the queue
                XiChat$RegionSayTo(id, c, XiList$ToString(["XiChat$PTP", d, k, ""])); // send empty packet to signal end of transfer
                return 1;
            }
            string m = llList2String(XICHAT_PTP, i * XICHAT_PTP_STRIDE + 3);
            XiChat$RegionSayTo(id, c, XiList$ToString(["XiChat$PTP", d, k, llGetSubString(m, 0, max - 2)])); // send next packet
            if (llStringLength(m) > max)
            { // trim from buffer
                XICHAT_PTP = llListReplaceList(XICHAT_PTP, [llDeleteSubString(llList2String(XICHAT_PTP, i * XICHAT_PTP_STRIDE + 3), 0, max - 1)], i * XICHAT_PTP_STRIDE + 3, i * XICHAT_PTP_STRIDE + 3);
            }
            else
            { // delete from buffer, message fully transferred
                XICHAT_PTP = llDeleteSubList(XICHAT_PTP, i * XICHAT_PTP_STRIDE, (i + 1) * XICHAT_PTP_STRIDE - 1); // clear transfer from queue
            }
            return 1;
        }
    #endif
    if (llList2String(data, 0) != "XiChat") return 0; // not a valid XiChat message
    // note: at this point we have a valid XiChat message, so all returns should be 1 to indicate that the XiChat message was processed
    if (llList2String(data, 1) != XICHAT_SERVICE) return 1; // not for our service
    integer domain_ind = llListFindList(llList2ListSlice(XICHAT_DOMAINS, 0, -1, XICHAT_DOMAINS_STRIDE, 0), [llList2String(data, 3)]);
    if (domain_ind == -1) return 0; // not listening to this domain
    integer flags = (integer)llList2String(XICHAT_DOMAINS, domain_ind * XICHAT_DOMAINS_STRIDE + 1);
    if (flags & XICHAT_LISTEN_OWNERONLY)
    { // owner only flag enabled for this listener
        if (llGetOwnerKey(id) != llGetOwner()) return 1; // not sent by same-owner object/agent
    }
    #ifdef XICHAT_ENABLE_XIIMP
        if (llList2String(data, 4) == "XiIMP")
        { // IMP message
                data = XiList$FromStr(llList2String(data, 5));
                if (llGetListLength(data) != 3) return 1; // error in IMP unserialize operation
                _XiIMP$Process(
                    id,
                    -1,
                    (integer)llList2String(data, 0),
                    llList2String(data, 1),
                    llList2String(data, 2)
                    );
            return 1;
        }
    #endif
    #ifdef XICHAT_ENABLE_XILSD
        string domain = llList2String(data, 3);
        if (llList2String(data, 4) == "XiLSD$Pull")
        { // send LSD pair
            data = XiList$FromStr(llList2String(data, 5));
            if (llGetListLength(data) != 2) return 1; // error in operation unserialize operation
            XiLSD$Push(
                id, // prim
                domain, // domain
                (integer)llList2String(data, 0) // use_header
                llList2String(data, 1), // name
                );
            return 1;
        }
        if (llList2String(data, 4) == "XiLSD$Push")
        { // save LSD pair
            string prim = llList2String(data, 2);
            data = XiList$FromStr(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            _XiLSD$Process(
                prim, // target prim from XiLSD$Push
                (integer)llList2String(data, 0), // use_uuid
                (integer)llList2String(data, 1), // use_header
                id, // source uuid
                llList2String(data, 2), // source header
                llList2String(data, 3), // name
                llList2String(data, 4) // value
                );
            return 1;
        }
    #endif
    #ifdef XICHAT_ENABLE_XIINVENTORY
        string domain = llList2String(data, 3);
        if (llList2String(data, 4) == "XiInventory$Push")
        { // send inventory
            data = XiList$FromStr(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            XiInventory$Pull(
                id, // prim
                domain, // domain
                llList2String(data, 0), // name
                (integer)llList2String(data, 1), // required type
                (integer)llList2String(data, 2), // llRemoteLoadScriptPin pin
                (integer)llList2String(data, 3), // script running
                (integer)llList2String(data, 4) // script start param
                );
            return 1;
        }
        if (llList2String(data, 4) == "XiInventory$Pull")
        { // send inventory
            data = XiList$FromStr(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            XiInventory$Push(
                id, // prim
                domain, // domain
                llList2String(data, 0), // name
                (integer)llList2String(data, 1), // required type
                (integer)llList2String(data, 2), // llRemoteLoadScriptPin pin
                (integer)llList2String(data, 3), // script running
                (integer)llList2String(data, 4) // script start param
                );
            return 1;
        }
    #endif
    #ifdef XICHAT_ENABLE_XIINVENTORY_REZREMOTE
        if (llList2String( data, 4 ) == "XiInventory$RezRemote")
        { // we have rezzed an object with Remote.lsl
            integer param = (integer)llList2String( XIINVENTORY_REMOTE, 0 );
            list scripts = XiList$Collate( XiList$FromStr( llList2String( XIINVENTORY_REMOTE, 1 ) ), XiList$FromStr( llList2String( XIINVENTORY_REMOTE, 2 ) ) ); // script_name, running
            XIINVENTORY_REMOTE = llDeleteSubList( XIINVENTORY_REMOTE, 0, XIINVENTORY_REMOTE_STRIDE - 1 );
            integer i;
            integer l = llGetListLength( scripts ) / 2;
            for ( i = 0; i < l; i++ )
            { // copy each script into remote
                XiInventory$Copy( // copies an inventory item to another object
                    id, // prim
                    llList2String( scripts, i * 2 ), // name
                    INVENTORY_SCRIPT, // type
                    (integer)llList2String( data, 5 ), // pin
                    (integer)llList2String( scripts, i * 2 + 1 ), // run
                    param // param
                    );
            }
            return 1;
        }
    #endif
    // generic message
    #ifndef XICHAT_ENABLE_RAW
        XiLog(DEBUG, "Raw XiChat message received, but XICHAT_ENABLE_CHAT not defined.");
    #else
        Xi$raw_message(
            id, // source id
            llList2String(data, 2), // domain
            llList2String(data, 4) // message
            );
    #endif
    return 1;
}

#define _XiChat$UnListenDomains(...) _XiChat_UnListenDomains( __VA_ARGS__ )
_XiChat$UnListenDomains()
{ // internal function that runs llListenRemove on everything in XICHAT_DOMAINS
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("_XiChat$UnListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(XICHAT_DOMAINS) / XICHAT_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in XICHAT_DOMAINS, remove listen by handle (we'll be replacing later)
        llListenRemove((integer)llList2String(XICHAT_DOMAINS, i * XICHAT_DOMAINS_STRIDE + 3));
    }
}

#define _XiChat$ListenDomains(...) _XiChat_ListenDomains( __VA_ARGS__ )
_XiChat$ListenDomains()
{ // internal function that runs llListen on everything in XICHAT_DOMAINS - DON'T run this without running XiChat$UnListenDomains() first!
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("_XiChat$ListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(XICHAT_DOMAINS) / XICHAT_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in XICHAT_DOMAINS, add listen and update XICHAT_DOMAINS with handle
        XiLog( TRACE, "llListen( " + llList2String( XICHAT_DOMAINS, i * XICHAT_DOMAINS_STRIDE + 2 ) + ", \"\", \"\", \"\" ) called for domain \"" + llList2String( XICHAT_DOMAINS, i * XICHAT_DOMAINS_STRIDE ) + "\" on service \"" + XICHAT_SERVICE + "\"." );
        llListReplaceList(XICHAT_DOMAINS, [llListen((integer)llList2String(XICHAT_DOMAINS, i * XICHAT_DOMAINS_STRIDE + 2), "", "", "")], i * XICHAT_DOMAINS_STRIDE + 3, i * XICHAT_DOMAINS_STRIDE + 3);
    }
}

#define _XiChat$RefreshLinkset(...) _XiChat_RefreshLinkset( __VA_ARGS__ )
_XiChat$RefreshLinkset()
{ // internal function that runs after key change to reset any listens based on previous UUID
    #ifdef XICHAT_ENABLE_XILOG_TRACE
        XiLog$TraceParams("_XiChat$RefreshLinkset", [], []);
    #endif
    _XiChat$UnListenDomains();
    if (XIOBJECT_LIMIT_SELF)
    { // we can check for self prim domains
        string new = (string)llGetKey();
        if (llList2String(XIOBJECT_UUIDS_SELF, 0) != new)
        { // UUID change
            integer index = llListFindList(llList2ListSlice(XICHAT_DOMAINS, 0, -1, XICHAT_DOMAINS_STRIDE, 0), llList2List(XIOBJECT_UUIDS_SELF, 0, 0));
            if (index)
            { // we are listening to a self prim domain, so update it
                XICHAT_DOMAINS = llListReplaceList(XICHAT_DOMAINS, [
                    new,
                    (integer)llList2String(XICHAT_DOMAINS, index * XICHAT_DOMAINS_STRIDE + 1),
                    XiChat$Channel(new)
                    ], index + XICHAT_DOMAINS_STRIDE, index + XICHAT_DOMAINS_STRIDE + 2);
            }
        }
    }
    _XiChat$ListenDomains();
}
