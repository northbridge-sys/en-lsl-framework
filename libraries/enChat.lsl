/*
    enChat.lsl
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

    This is an LSL Preprocessor include file that implements an overwhelmingly
    simple hashing algorithm that allows llListen channels to be defined using a
    domain (string set at run-time) and a service (string set at compile-time)
    hashed into a 32-bit integer (avoiding PUBLIC_CHANNEL and DEBUG_CHANNEL). This
    triggers the simulator-side filter for llListen channels and avoids having to
    execute the listen(...) event and waste script time.

    When ENCHAT$ENABLE_PTP is defined, this file also offers a method of sending
    messages longer than 1024 bytes via chat using an in-memory buffer.

    What this is NOT:
        - Secure. Anyone with sufficient time and effort (and not a lot) can scan
            the entire integer channel spectrum, then capture your domain & service,
            which are sent plain-text inside the message, as well as the message
            itself.
        - An authentication mechanism.
        - A method of obfuscating text sent via chat or llMessageLinked. enChat is
            intended to pass human-readable and easily-parsed IMP traffic over chat.
            If security is required, consider encrypting separately before sending
            IMP messages, ideally signed, but be aware that the domain & service are
            not hidden. (Or just use an external HTTPS server.)
        - A method of sending infinite-length strings. PTP has no memory overflow
            protection and should only be used for strings that you know will fit in
            memory for both the source and the target scripts.

    To define the service string, call enChat$SetService( service ). Any string
    supported by llSHA256String can be used. This will be used twice:
        - Appended to the start of all chat messages in plain text for filtering.
        - Hashed against the domain to generate the integer channel for llListen.

    enChat$Listen(...) will return 0 and fail to add the listen if you attempt to
    add more than 65 listeners (the maximum allowed per script). If you call
    llListen separately, set the number of listens you want reserved for non-enChat\
    use by adding the following line:
        #define ENCHAT$RESERVE_LISTENS x
    where x is the number of listens you want to allocate for non-enChat use.

    Note: domains can be set as the local prim's UUID, in which case they will be
    automatically refreshed on key or link change. However, this ONLY works if the
    domain itself is just the UUID - no other data can be added.

    WARNING: If the local prim's UUID is used as the domain, you MUST use the
    state_entry, on_rez, and changed event handler include files, which will
    dynamically update the domain after a key change. (This is done automatically
    in event-handlers.lsl if you use it.)
*/

// ==
// == globals
// ==

string _ENCHAT_SERVICE;

list _ENCHAT_DOMAINS; // domain, flags, channel, handle
#define _ENCHAT_DOMAINS_STRIDE 4

#ifdef ENCHAT$ENABLE_PTP
    list ENCHAT$PTP; // transfer_key, prim ("" for inbound), domain, message_buffer
    #define ENCHAT$PTP_STRIDE 4
#endif

// ==
// == functions
// ==

string enChat$GetService()
{
    // cannot log this function because it is used by enLog
    return _ENCHAT_SERVICE;
}

enChat$SetService(
    string service
    )
{
    #ifdef ENCHAT$TRACE
        enLog$TraceParams( "enChat$SetService", [ "service" ], [
            enString$Elem( service )
            ] );
    #endif
    _ENCHAT_SERVICE = service;
}

integer enChat$Channel( // converts a string into an integer, hashed with _ENCHAT_SERVICE, can be called externally for dialog listeners
    string domain  // domain string to use to generate integer channel
    )
{
    integer chan = (integer)("0x" + llGetSubString(llSHA256String(domain + enChat$GetService()), -8, -1));
    if (chan == PUBLIC_CHANNEL || chan == DEBUG_CHANNEL) chan++; // filter out channels that can be seen in the viewer by default
    return chan;
}

enChat$RegionSayTo( // llRegionSayTo with llRegionSay for NULL_KEY instead of silently failing
    string prim,
    integer channel,
    string message
    )
{
    if (prim == NULL_KEY) llRegionSay(channel, message);
    else llRegionSayTo(prim, channel, message);
}

enChat$Send( // send via enChat
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("enChat$Send", ["prim", "domain", "type", "message", "(service)" ], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(type),
            enString$Elem(message),
            enString$Elem(_ENCHAT_SERVICE)
            ]);
    #endif
    enChat$RegionSayTo(prim, enChat$Channel(domain), enList$ToString(["enChat", _ENCHAT_SERVICE, prim, domain, type, message]));
}

enChat$SendPTP( // send via enChat using the Packet Transfer Protocol
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("enChat$SendPTP", ["prim", "domain", "type", "message", "(service)" ], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(type),
            enString$Elem(message),
            enString$Elem(_ENCHAT_SERVICE)
            ]);
    #endif
    #ifndef ENCHAT$ENABLE_PTP
        enLog$(WARN, "enChat$SendPTP called but ENCHAT$ENABLE_PTP not defined.");
    #else
        message = enList$ToString(["enChat", _ENCHAT_SERVICE, prim, domain, type, message]); // add enChat$PTP header to message to be sent
        // 51 + llStringLength(...) is length of "10\nenChat$PTP32\n00000000000000000000000000000000" + {packet_size} + "\n"
        max = ENCHAT$PTP_SIZE - (51 + llStringLength((string)llStringLength(ENCHAT$PTP_SIZE))); // get maximum length of packet after enChat$PTP header via enList$ToString
        string k = llGenerateKey(); // transfer key for identifying a specific message in transit
        string c = enChat$Channel(domain);
        enChat$RegionSayTo(prim, c, enList$ToString(["enChat$PTP", domain, k, llGetSubString(message, 0, max - 2)])); // first packet gets sent immediately
        if (llStringLength(message) > max) ENCHAT$PTP += [k, prim, "", llDeleteSubString(message, 0, max - 2)]; // we don't need to save domain here
        // TODO: some cleanup function that clears stalled transfers (in and out) from ENCHAT$PTP_QUEUE
    #endif
}

integer enChat$Listen(  // initializes or updates a dynamically managed llListen
    string domain,  // domain to listen to "within" _ENCHAT_SERVICE
    integer flags   // ENCHAT$LISTEN_* flags
    )
{
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("enChat$Listen", ["domain", "flags", "(service)"], [
            enString$Elem(domain),
            enInteger$ElemBitfield(flags),
            enString$Elem(_ENCHAT_SERVICE)
            ]);
    #endif
    _enChat$UnListenDomains();
    integer index = llListFindList(llList2ListSlice(_ENCHAT_DOMAINS, 0, -1, _ENCHAT_DOMAINS_STRIDE, 0), [domain]);
    if (index == -1 && flags & ENCHAT$LISTEN_REMOVE)
    { // nothing to remove, so return error
        _enChat$ListenDomains();
        return 0;
    }
    if (index != -1)
    { // delete eensting domain enChat, so it can be cleanly appended to the end
        _ENCHAT_DOMAINS = llDeleteSubList(_ENCHAT_DOMAINS, index * _ENCHAT_DOMAINS_STRIDE, (index + 1) * _ENCHAT_DOMAINS_STRIDE - 1);
    }
    if (llGetListLength(_ENCHAT_DOMAINS) + 1 > 65 - ENCHAT$RESERVE_LISTENS)
    { // too many listens
        _enChat$ListenDomains();
        return 0;
    }
    if (!(flags & ENCHAT$LISTEN_REMOVE))
    { // add to _ENCHAT_DOMAINS only if we aren't removing it
        _ENCHAT_DOMAINS += [domain, flags, enChat$Channel(domain), 0];
    }
    _enChat$ListenDomains();
    return 1;
}

integer _enChat$Process(
    integer channel,
    string name,
    key id,
    string message
    )
{
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("_enChat$Process", ["channel", "name", "id", "message"], [
            channel,
            enString$Elem(name),
            enString$Elem(id),
            enString$Elem(message)
            ]);
    #endif
    list data = enList$FromString(message);
    #ifdef ENCHAT$TRACE
        enLog$TraceVars(["data"], [
            enList$Elem(data)
            ]);
    #endif
    if (llGetListLength(data) != 6) return 0; // error in enChat unserialize operation
    #ifdef ENCHAT$ENABLE_PTP
        if (llList2String(data, 0) == "enChat$PTP")
        { // we have a PTP packet
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            string m = llList2String(data, 3); // message fragment
            integer i = llListFindList(llList2ListSlice(ENCHAT$PTP, 0, -1, ENCHAT$PTP_STRIDE, 0), [k]);
            if (m == "")
            { // end of received message
                if (i == -1) return 1; // nothing in queue
                _enChat$Process(channel, name, id, llList2String(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE + 3)); // release buffer from queue
                ENCHAT$PTP = llDeleteSubList(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE, (i + 1) * ENCHAT$PTP_STRIDE - 1); // clear transfer from queue
                return 1;
            }
            if (i == -1) ENCHAT$PTP = [k, "", channel, m]; // create new buffer
            else ENCHAT$PTP = llListReplaceList(ENCHAT$PTP, [llList2String(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE + 3) + m], i * ENCHAT$PTP_STRIDE + 3, i * ENCHAT$PTP_STRIDE + 3); // append to eensting buffer
            enChat$RegionSayTo(id, enChat$Channel(d), enList$ToString(["enChat$PTP_More", d, k])); // request next message fragment
            return 1;
        }
        if (llList2String(data, 0) == "enChat$PTP_More")
        { // someone is requesting the next message fragment
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            integer i = llListFindList(llList2ListSlice(ENCHAT$PTP, 0, -1, ENCHAT$PTP_STRIDE, 0), [k]);
            if (i == -1)
            { // we have nothing to send, because this transfer_key does not eenst in the queue
                enChat$RegionSayTo(id, c, enList$ToString(["enChat$PTP", d, k, ""])); // send empty packet to signal end of transfer
                return 1;
            }
            string m = llList2String(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE + 3);
            enChat$RegionSayTo(id, c, enList$ToString(["enChat$PTP", d, k, llGetSubString(m, 0, max - 2)])); // send next packet
            if (llStringLength(m) > max)
            { // trim from buffer
                ENCHAT$PTP = llListReplaceList(ENCHAT$PTP, [llDeleteSubString(llList2String(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE + 3), 0, max - 1)], i * ENCHAT$PTP_STRIDE + 3, i * ENCHAT$PTP_STRIDE + 3);
            }
            else
            { // delete from buffer, message fully transferred
                ENCHAT$PTP = llDeleteSubList(ENCHAT$PTP, i * ENCHAT$PTP_STRIDE, (i + 1) * ENCHAT$PTP_STRIDE - 1); // clear transfer from queue
            }
            return 1;
        }
    #endif
    if (llList2String(data, 0) != "enChat") return 0; // not a valid enChat message
    // note: at this point we have a valid enChat message, so all returns should be 1 to indicate that the enChat message was processed
    if (llList2String(data, 1) != _ENCHAT_SERVICE) return 1; // not for our service
    integer domain_ind = llListFindList(llList2ListSlice(_ENCHAT_DOMAINS, 0, -1, _ENCHAT_DOMAINS_STRIDE, 0), [llList2String(data, 3)]);
    if (domain_ind == -1) return 0; // not listening to this domain
    integer flags = (integer)llList2String(_ENCHAT_DOMAINS, domain_ind * _ENCHAT_DOMAINS_STRIDE + 1);
    if (flags & ENCHAT$LISTEN_OWNERONLY)
    { // owner only flag enabled for this listener
        if (llGetOwnerKey(id) != llGetOwner()) return 1; // not sent by same-owner object/agent
    }
    #ifdef EN$IMP_MESSAGE
        if (llList2String(data, 4) == "enIMP")
        { // IMP message
                data = enList$FromString(llList2String(data, 5));
                if (llGetListLength(data) != 3) return 1; // error in IMP unserialize operation
                _enIMP$Process(
                    id,
                    -1,
                    (integer)llList2String(data, 0),
                    llList2String(data, 1),
                    llList2String(data, 2)
                    );
            return 1;
        }
    #endif
    #ifdef ENCHAT$ENABLE_ENLSD
        string domain = llList2String(data, 3);
        if (llList2String(data, 4) == "enLSD$Pull")
        { // send LSD pair
            data = enList$FromString(llList2String(data, 5));
            if (llGetListLength(data) != 2) return 1; // error in operation unserialize operation
            enLSD$Push(
                id, // prim
                domain, // domain
                (integer)llList2String(data, 0) // use_header
                llList2String(data, 1), // name
                );
            return 1;
        }
        if (llList2String(data, 4) == "enLSD$Push")
        { // save LSD pair
            string prim = llList2String(data, 2);
            data = enList$FromString(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            _enLSD$Process(
                prim, // target prim from enLSD$Push
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
    #ifdef ENCHAT$ENABLE_ENINVENTORY
        string domain = llList2String(data, 3);
        if (llList2String(data, 4) == "enInventory$Push")
        { // send inventory
            data = enList$FromString(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            enInventory$Pull(
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
        if (llList2String(data, 4) == "enInventory$Pull")
        { // send inventory
            data = enList$FromString(llList2String(data, 5));
            if (llGetListLength(data) != 5) return 1; // error in operation unserialize operation
            enInventory$Push(
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
    #ifdef ENCHAT$ENABLE_ENINVENTORY_REZREMOTE
        if (llList2String( data, 4 ) == "enInventory$RezRemote")
        { // we have rezzed an object with Remote.lsl
            integer param = (integer)llList2String( ENINVENTORY$REMOTE, 0 );
            list scripts = enList$Collate( enList$FromString( llList2String( ENINVENTORY$REMOTE, 1 ) ), enList$FromString( llList2String( ENINVENTORY$REMOTE, 2 ) ) ); // script_name, running
            ENINVENTORY$REMOTE = llDeleteSubList( ENINVENTORY$REMOTE, 0, ENINVENTORY$REMOTE_STRIDE - 1 );
            integer i;
            integer l = llGetListLength( scripts ) / 2;
            for ( i = 0; i < l; i++ )
            { // copy each script into remote
                enInventory$Copy( // copies an inventory item to another object
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
    #ifndef EN$CHAT_MESSAGE
        enLog$( DEBUG, "Raw enChat message received from " + enObject$Elem( id ) + " on domain \"" + llList2String( data, 2 ) + "\", but EN$CHAT_MESSAGE not defined: " + llList2String( data, 4 ) );
    #else
        en$chat_message(
            id, // source id
            llList2String(data, 2), // domain
            llList2String(data, 4) // message
            );
    #endif
    return 1;
}

_enChat$UnListenDomains()
{ // internal function that runs llListenRemove on everything in _ENCHAT_DOMAINS
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("_enChat$UnListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCHAT_DOMAINS) / _ENCHAT_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in _ENCHAT_DOMAINS, remove listen by handle (we'll be replacing later)
        llListenRemove((integer)llList2String(_ENCHAT_DOMAINS, i * _ENCHAT_DOMAINS_STRIDE + 3));
    }
}

_enChat$ListenDomains()
{ // internal function that runs llListen on everything in _ENCHAT_DOMAINS - DON'T run this without running enChat$UnListenDomains() first!
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("_enChat$ListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCHAT_DOMAINS) / _ENCHAT_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in _ENCHAT_DOMAINS, add listen and update _ENCHAT_DOMAINS with handle
        enLog$( TRACE, "llListen( " + llList2String( _ENCHAT_DOMAINS, i * _ENCHAT_DOMAINS_STRIDE + 2 ) + ", \"\", \"\", \"\" ) called for domain \"" + llList2String( _ENCHAT_DOMAINS, i * _ENCHAT_DOMAINS_STRIDE ) + "\" on service \"" + _ENCHAT_SERVICE + "\"." );
        llListReplaceList(_ENCHAT_DOMAINS, [llListen((integer)llList2String(_ENCHAT_DOMAINS, i * _ENCHAT_DOMAINS_STRIDE + 2), "", "", "")], i * _ENCHAT_DOMAINS_STRIDE + 3, i * _ENCHAT_DOMAINS_STRIDE + 3);
    }
}

_enChat$RefreshLinkset()
{ // internal function that runs after key change to reset any listens based on previous UUID
    #ifdef ENCHAT$TRACE
        enLog$TraceParams("_enChat$RefreshLinkset", [], []);
    #endif
    _enChat$UnListenDomains();
    if (ENOBJECT$LIMIT_SELF)
    { // we can check for self prim domains
        string new = (string)llGetKey();
        if ( enObject$Self( 0 ) != new )
        { // UUID change
            integer index = llListFindList( llList2ListSlice( _ENCHAT_DOMAINS, 0, -1, _ENCHAT_DOMAINS_STRIDE, 0), [ enObject$Self( 0 ) ] );
            if (index)
            { // we are listening to a self prim domain, so update it
                _ENCHAT_DOMAINS = llListReplaceList(_ENCHAT_DOMAINS, [
                    new,
                    (integer)llList2String(_ENCHAT_DOMAINS, index * _ENCHAT_DOMAINS_STRIDE + 1),
                    enChat$Channel(new)
                    ], index + _ENCHAT_DOMAINS_STRIDE, index + _ENCHAT_DOMAINS_STRIDE + 2);
            }
        }
    }
    _enChat$ListenDomains();
}
