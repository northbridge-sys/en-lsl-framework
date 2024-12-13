/*
    enCLEP.lsl
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

    When ENCLEP$ENABLE_PTP is defined, this file also offers a method of sending
    messages longer than 1024 bytes via chat using an in-memory buffer.

    What this is NOT:
        - Secure. Anyone with sufficient time and effort (and not a lot) can scan
            the entire integer channel spectrum, then capture your domain & service,
            which are sent plain-text inside the message, as well as the message
            itself.
        - An authentication mechanism.
        - A method of obfuscating text sent via chat or llMessageLinked. enCLEP is
            intended to pass human-readable and easily-parsed LEP traffic over chat.
            If security is required, consider encrypting separately before sending
            LEP messages, ideally signed, but be aware that the domain & service are
            not hidden. (Or just use an external HTTPS server.)
        - A method of sending infinite-length strings. PTP has no memory overflow
            protection and should only be used for strings that you know will fit in
            memory for both the source and the target scripts.

    To define the service string, call enCLEP$SetService( service ). Any string
    supported by llSHA256String can be used. This will be used twice:
        - Appended to the start of all chat messages in plain text for filtering.
        - Hashed against the domain to generate the integer channel for llListen.

    enCLEP$Listen(...) will return 0 and fail to add the listen if you attempt to
    add more than 65 listeners (the maximum allowed per script). If you call
    llListen separately, set the number of listens you want reserved for non-enCLEP\
    use by adding the following line:
        #define ENCLEP$RESERVE_LISTENS x
    where x is the number of listens you want to allocate for non-enCLEP use.

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

string _ENCLEP_SERVICE;

list _ENCLEP_DOMAINS; // domain, flags, channel, handle
#define _ENCLEP_DOMAINS_STRIDE 4

#ifdef ENCLEP$ENABLE_PTP
    list ENCLEP$PTP; // transfer_key, prim ("" for inbound), domain, message_buffer
    #define ENCLEP$PTP_STRIDE 4
#endif

// ==
// == functions
// ==

string enCLEP$GetService()
{
    // cannot log this function because it is used by enLog
    return _ENCLEP_SERVICE;
}

enCLEP$SetService(
    string service
    )
{
    #ifdef ENCLEP$TRACE
        enLog$TraceParams( "enCLEP$SetService", [ "service" ], [
            enString$Elem( service )
            ] );
    #endif
    _ENCLEP_SERVICE = service;
}

integer enCLEP$Channel( // converts a string into an integer, hashed with _ENCLEP_SERVICE, can be called externally for dialog listeners
    string domain  // domain string to use to generate integer channel
    )
{
    integer chan = (integer)("0x" + llGetSubString(llSHA256String(domain + enCLEP$GetService()), -8, -1));
    if (chan == PUBLIC_CHANNEL || chan == DEBUG_CHANNEL) chan++; // filter out channels that can be seen in the viewer by default
    return chan;
}

enCLEP$RegionSayTo( // llRegionSayTo with llRegionSay for NULL_KEY instead of silently failing
    string prim,
    integer channel,
    string message
    )
{
    if (prim == NULL_KEY) llRegionSay(channel, message);
    else llRegionSayTo(prim, channel, message);
}

enCLEP$Send( // send via enCLEP
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("enCLEP$Send", ["prim", "domain", "type", "message", "(service)" ], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(type),
            enString$Elem(message),
            enString$Elem(_ENCLEP_SERVICE)
            ]);
    #endif
    enCLEP$RegionSayTo(prim, enCLEP$Channel(domain), enList$ToString(["enCLEP", _ENCLEP_SERVICE, prim, domain, type, message]));
}

enCLEP$SendPTP( // send via enCLEP using the Packet Transfer Protocol
    string prim,
    string domain,
    string type,
    string message
    )
{
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("enCLEP$SendPTP", ["prim", "domain", "type", "message", "(service)" ], [
            enObject$Elem(prim),
            enString$Elem(domain),
            enString$Elem(type),
            enString$Elem(message),
            enString$Elem(_ENCLEP_SERVICE)
            ]);
    #endif
    #ifndef ENCLEP$ENABLE_PTP
        enLog$(WARN, "enCLEP$SendPTP called but ENCLEP$ENABLE_PTP not defined.");
    #else
        message = enList$ToString(["enCLEP", _ENCLEP_SERVICE, prim, domain, type, message]); // add enCLEP$PTP header to message to be sent
        // 51 + llStringLength(...) is length of "10\nenCLEP$PTP32\n00000000000000000000000000000000" + {packet_size} + "\n"
        max = ENCLEP$PTP_SIZE - (51 + llStringLength((string)llStringLength(ENCLEP$PTP_SIZE))); // get maximum length of packet after enCLEP$PTP header via enList$ToString
        string k = llGenerateKey(); // transfer key for identifying a specific message in transit
        string c = enCLEP$Channel(domain);
        enCLEP$RegionSayTo(prim, c, enList$ToString(["enCLEP$PTP", domain, k, llGetSubString(message, 0, max - 2)])); // first packet gets sent immediately
        if (llStringLength(message) > max) ENCLEP$PTP += [k, prim, "", llDeleteSubString(message, 0, max - 2)]; // we don't need to save domain here
        // TODO: some cleanup function that clears stalled transfers (in and out) from ENCLEP$PTP_QUEUE
    #endif
}

integer enCLEP$Listen(  // initializes or updates a dynamically managed llListen
    string domain,  // domain to listen to "within" _ENCLEP_SERVICE
    integer flags   // ENCLEP$LISTEN_* flags
    )
{
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("enCLEP$Listen", ["domain", "flags", "(service)"], [
            enString$Elem(domain),
            enInteger$ElemBitfield(flags),
            enString$Elem(_ENCLEP_SERVICE)
            ]);
    #endif
    _enCLEP$UnListenDomains();
    integer index = llListFindList(llList2ListSlice(_ENCLEP_DOMAINS, 0, -1, _ENCLEP_DOMAINS_STRIDE, 0), [domain]);
    if (index == -1 && flags & ENCLEP$LISTEN_REMOVE)
    { // nothing to remove, so return error
        _enCLEP$ListenDomains();
        return 0;
    }
    if (index != -1)
    { // delete existing domain enCLEP, so it can be cleanly appended to the end
        _ENCLEP_DOMAINS = llDeleteSubList(_ENCLEP_DOMAINS, index * _ENCLEP_DOMAINS_STRIDE, (index + 1) * _ENCLEP_DOMAINS_STRIDE - 1);
    }
    if (llGetListLength(_ENCLEP_DOMAINS) + 1 > 65 - ENCLEP$RESERVE_LISTENS)
    { // too many listens
        _enCLEP$ListenDomains();
        return 0;
    }
    if (!(flags & ENCLEP$LISTEN_REMOVE))
    { // add to _ENCLEP_DOMAINS only if we aren't removing it
        _ENCLEP_DOMAINS += [domain, flags, enCLEP$Channel(domain), 0];
    }
    _enCLEP$ListenDomains();
    return 1;
}

integer _enCLEP$Process(
    integer channel,
    string name,
    key id,
    string message
    )
{
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("_enCLEP$Process", ["channel", "name", "id", "message"], [
            channel,
            enString$Elem(name),
            enString$Elem(id),
            enString$Elem(message)
            ]);
    #endif
    list data = enList$FromString(message);
    #ifdef ENCLEP$TRACE
        enLog$TraceVars(["data"], [
            enList$Elem(data)
            ]);
    #endif
    if (llGetListLength(data) != 6) return 0; // error in enCLEP unserialize operation
    #ifdef ENCLEP$ENABLE_PTP
        if (llList2String(data, 0) == "enCLEP$PTP")
        { // we have a PTP packet
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            string m = llList2String(data, 3); // message fragment
            integer i = llListFindList(llList2ListSlice(ENCLEP$PTP, 0, -1, ENCLEP$PTP_STRIDE, 0), [k]);
            if (m == "")
            { // end of received message
                if (i == -1) return 1; // nothing in queue
                _enCLEP$Process(channel, name, id, llList2String(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE + 3)); // release buffer from queue
                ENCLEP$PTP = llDeleteSubList(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE, (i + 1) * ENCLEP$PTP_STRIDE - 1); // clear transfer from queue
                return 1;
            }
            if (i == -1) ENCLEP$PTP = [k, "", channel, m]; // create new buffer
            else ENCLEP$PTP = llListReplaceList(ENCLEP$PTP, [llList2String(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE + 3) + m], i * ENCLEP$PTP_STRIDE + 3, i * ENCLEP$PTP_STRIDE + 3); // append to existing buffer
            enCLEP$RegionSayTo(id, enCLEP$Channel(d), enList$ToString(["enCLEP$PTP_More", d, k])); // request next message fragment
            return 1;
        }
        if (llList2String(data, 0) == "enCLEP$PTP_More")
        { // someone is requesting the next message fragment
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            integer i = llListFindList(llList2ListSlice(ENCLEP$PTP, 0, -1, ENCLEP$PTP_STRIDE, 0), [k]);
            if (i == -1)
            { // we have nothing to send, because this transfer_key does not exist in the queue
                enCLEP$RegionSayTo(id, c, enList$ToString(["enCLEP$PTP", d, k, ""])); // send empty packet to signal end of transfer
                return 1;
            }
            string m = llList2String(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE + 3);
            enCLEP$RegionSayTo(id, c, enList$ToString(["enCLEP$PTP", d, k, llGetSubString(m, 0, max - 2)])); // send next packet
            if (llStringLength(m) > max)
            { // trim from buffer
                ENCLEP$PTP = llListReplaceList(ENCLEP$PTP, [llDeleteSubString(llList2String(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE + 3), 0, max - 1)], i * ENCLEP$PTP_STRIDE + 3, i * ENCLEP$PTP_STRIDE + 3);
            }
            else
            { // delete from buffer, message fully transferred
                ENCLEP$PTP = llDeleteSubList(ENCLEP$PTP, i * ENCLEP$PTP_STRIDE, (i + 1) * ENCLEP$PTP_STRIDE - 1); // clear transfer from queue
            }
            return 1;
        }
    #endif
    if (llList2String(data, 0) != "enCLEP") return 0; // not a valid enCLEP message
    // note: at this point we have a valid enCLEP message, so all returns should be 1 to indicate that the enCLEP message was processed
    if (llList2String(data, 1) != _ENCLEP_SERVICE) return 1; // not for our service
    integer domain_ind = llListFindList(llList2ListSlice(_ENCLEP_DOMAINS, 0, -1, _ENCLEP_DOMAINS_STRIDE, 0), [llList2String(data, 3)]);
    if (domain_ind == -1) return 0; // not listening to this domain
    integer flags = (integer)llList2String(_ENCLEP_DOMAINS, domain_ind * _ENCLEP_DOMAINS_STRIDE + 1);
    if (flags & ENCLEP$LISTEN_OWNERONLY)
    { // owner only flag enabled for this listener
        if (llGetOwnerKey(id) != llGetOwner()) return 1; // not sent by same-owner object/agent
    }
    #ifdef EN$LEP_MESSAGE
        if (llList2String(data, 4) == "enLEP")
        { // LEP message
                data = enList$FromString(llList2String(data, 5));
                if (llGetListLength(data) != 3) return 1; // error in LEP unserialize operation
                _enLEP$Process(
                    id,
                    -1,
                    (integer)llList2String(data, 0),
                    llList2String(data, 1),
                    llList2String(data, 2)
                    );
            return 1;
        }
    #endif
    #ifdef ENCLEP$ENABLE_ENLSD
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
            enLSD$Process(
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
    #ifdef ENCLEP$ENABLE_ENINVENTORY
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
    #ifdef ENCLEP$ENABLE_ENINVENTORY_REZREMOTE
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
        enLog$( DEBUG, "Raw enCLEP message received from " + enObject$Elem( id ) + " on domain \"" + llList2String( data, 2 ) + "\", but EN$CHAT_MESSAGE not defined: " + llList2String( data, 4 ) );
    #else
        en$chat_message(
            id, // source id
            llList2String(data, 2), // domain
            llList2String(data, 4) // message
            );
    #endif
    return 1;
}

_enCLEP$UnListenDomains()
{ // internal function that runs llListenRemove on everything in _ENCLEP_DOMAINS
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("_enCLEP$UnListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in _ENCLEP_DOMAINS, remove listen by handle (we'll be replacing later)
        llListenRemove((integer)llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 3));
    }
}

_enCLEP$ListenDomains()
{ // internal function that runs llListen on everything in _ENCLEP_DOMAINS - DON'T run this without running enCLEP$UnListenDomains() first!
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("_enCLEP$ListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    for (i = 0; i < l; i++)
    { // for each domain in _ENCLEP_DOMAINS, add listen and update _ENCLEP_DOMAINS with handle
        enLog$( TRACE, "llListen( " + llList2String( _ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 2 ) + ", \"\", \"\", \"\" ) called for domain \"" + llList2String( _ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE ) + "\" on service \"" + _ENCLEP_SERVICE + "\"." );
        llListReplaceList(_ENCLEP_DOMAINS, [llListen((integer)llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 2), "", "", "")], i * _ENCLEP_DOMAINS_STRIDE + 3, i * _ENCLEP_DOMAINS_STRIDE + 3);
    }
}

_enCLEP$RefreshLinkset()
{ // internal function that runs after key change to reset any listens based on previous UUID
    #ifdef ENCLEP$TRACE
        enLog$TraceParams("_enCLEP$RefreshLinkset", [], []);
    #endif
    _enCLEP$UnListenDomains();
    if (ENOBJECT$LIMIT_SELF)
    { // we can check for self prim domains
        string new = (string)llGetKey();
        if ( enObject$Self( 0 ) != new )
        { // UUID change
            integer index = llListFindList( llList2ListSlice( _ENCLEP_DOMAINS, 0, -1, _ENCLEP_DOMAINS_STRIDE, 0), [ enObject$Self( 0 ) ] );
            if (index)
            { // we are listening to a self prim domain, so update it
                _ENCLEP_DOMAINS = llListReplaceList(_ENCLEP_DOMAINS, [
                    new,
                    (integer)llList2String(_ENCLEP_DOMAINS, index * _ENCLEP_DOMAINS_STRIDE + 1),
                    enCLEP$Channel(new)
                    ], index + _ENCLEP_DOMAINS_STRIDE, index + _ENCLEP_DOMAINS_STRIDE + 2);
            }
        }
    }
    _enCLEP$ListenDomains();
}
