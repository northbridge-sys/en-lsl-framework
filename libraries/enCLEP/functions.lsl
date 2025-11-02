/*
enCLEP.lsl
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

//  Internal function that dynamically selects a chat method to use based on the target prim
//  NULL_KEY or "" can be passed as a prim to use llRegionSay automatically
//  If FEATURE_ENCLEP_ENABLE_SHOUT is defined, a llRegionSayTo message will be sent via llShout to attempt to reach a prim across a nearby sim border
_enCLEP_MultiSayTo( // llRegionSayTo with llRegionSay for NULL_KEY instead of silently failing
    string prim,
    integer channel,
    string message
    )
{
    #if defined TRACE_ENCLEP_MULTISAYTO
        enLog_TraceParams("enCLEP_MultiSayTo", ["prim", "channel", "message"], [
            enString_Elem(prim),
            channel,
            enString_Elem(message)
        ]);
    #endif
        if (prim == "") prim = NULL_KEY;
        if (prim == NULL_KEY) llRegionSay(channel, message); // RS if prim is not specified
        else if (llGetObjectDetails(prim, [OBJECT_PHANTOM]) != []) llRegionSayTo(prim, channel, message); // RST if prim is in region
    #if defined FEATURE_ENCLEP_ENABLE_SHOUT
        else llShout(channel, message); // shout if prim is not in region and FEATURE_ENCLEP_ENABLE_SHOUT is defined
    #elif defined FEATURE_ENCLEP_ENABLE_SAY
        else llSay(channel, message); // say if prim is not in region and FEATURE_ENCLEP_ENABLE_SAY is defined
    #elif defined FEATURE_ENCLEP_ENABLE_WHISPER
        else llWhisper(channel, message); // whisper if prim is not in region and FEATURE_ENCLEP_ENABLE_WHISPER is defined
    #endif
}

/*
Basic LEP-over-CLEP messaging function.
This function sends a LEP message to a specified prim via the specified CLEP domain (or all prims listening on the specified domain).
The recipient script(s) must be listening to the domain and must share the same active service.
The target_script, flags, parameters, and data values are the same as used by LEP (see enLEP_Send).
*/
enCLEP_Send(
    string service,
    string domain,
    string target_prim,
    string target_script,
    integer flags,
    list parameters,
    string data
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_Send", ["service", "domain", "target_prim", "target_script", "flags", "parameters", "data"], [
            enString_Elem(service),
            enString_Elem(domain),
            enObject_Elem(target_prim),
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    enCLEP_SendRaw(
        service,
        domain,
        target_prim,
        "LEP",
        enList_ToString([flags, enLEP_Generate(target_script, parameters), data])
    );
}

/*
Experimental LEP-over-LEP-and-CLEP messaging function.
This is used to dynamically send a LEP message via either enCLEP or enLEP based on whether the target link is a positive link number.
This can be used to reduce CLEP traffic in large networks.
TODO: This doesn't work with LINK_* constants
TODO: Add a macro to automatically search for the link via the enObject link cache, and/or via ClosestLink, since currently that has to be done manually
*/
enCLEP_SendHybrid(
    string service,
    string domain,
    string target_prim,
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_SendHybrid", ["service", "domain", "target_prim", "target_link", "target_script", "flags", "parameters", "data"], [
            enString_Elem(service),
            enString_Elem(domain),
            enObject_Elem(target_prim),
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (target_link < 0)
    { // prim not part of same linkset, send via enCLEP
        enCLEP_SendRaw(
            service,
            domain,
            target_prim,
            "LEP",
            enList_ToString([flags, enLEP_Generate(target_script, parameters), data])
        );
    }
    else
    { // prim part of same linkset, send via enLEP
        enLEP_Send( // sends a LEP message
            target_link,
            target_script,
            flags,
            parameters,
            data
        );
    }
}

/*
Sends raw data via CLEP encapsulation.
This causes the recipient to call enclep_message, similar to a plain listen event, instead of enlep_message.
Can be useful for situations where you don't need LEP features but still want to only communicate to a specific CLEP domain and service.
*/
enCLEP_SendRaw( // send via enCLEP
    string service,
    string domain,
    string target_prim,
    string type,
    string message
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_SendRaw", ["service", "domain", "target_prim", "type", "message"], [
            enString_Elem(service),
            enString_Elem(domain),
            enObject_Elem(target_prim),
            enString_Elem(type),
            enString_Elem(message)
            ]);
    #endif
    _enCLEP_MultiSayTo(target_prim, enCLEP_Channel(service, domain), enList_ToString(["CLEP", service, domain, target_prim, type, message]));
}

/*
Sends raw data via CLEP encapsulation with PTP packetization.
WARNING: This function hasn't been tested since major CLEP rework and is probably broken.
*/
enCLEP_SendPTP( // send via enCLEP using the Packet Transfer Protocol
    string service,
    string domain,
    string target_prim,
    string type,
    string message
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_SendPTP", ["service", "domain", "target_prim", "type", "message"], [
            enString_Elem(service),
            enString_Elem(domain),
            enObject_Elem(target_prim),
            enString_Elem(type),
            enString_Elem(message)
            ]);
    #endif
    #ifndef FEATURE_ENCLEP_ENABLE_PTP
        enLog_Warn("enCLEP_SendPTP called but FEATURE_ENCLEP_ENABLE_PTP not defined.");
    #else
        // TODO: message really should be dynamically loaded from linkset data - maybe with some way of loading data of arbitrary length into safe ~1K chunks in linkset data for situations like this?
        message = enList_ToString(["CLEP", service, domain, target_prim, type, message]); // add enCLEP_PTP header to message to be sent
        // 51 + llStringLength(...) is length of "10\nenCLEP_PTP32\n00000000000000000000000000000000" + {packet_size} + "\n"
        max = OVERRIDE_ENCLEP_PTP_SIZE - (51 + llStringLength((string)llStringLength(OVERRIDE_ENCLEP_PTP_SIZE))); // get maximum length of packet after enCLEP_PTP header via enList_ToString
        string k = llGenerateKey(); // transfer key for identifying a specific message in transit
        string c = enCLEP_Channel(service, domain);
        _enCLEP_MultiSayTo(prim, c, enList_ToString(["CLEP_PTP", domain, k, llGetSubString(message, 0, max - 2)])); // first packet gets sent immediately
        if (llStringLength(message) > max) _ENCLEP_PTP += [k, prim, "", llDeleteSubString(message, 0, max - 2)]; // we don't need to save domain here
        // TODO: some cleanup function that clears stalled transfers (in and out) from _ENCLEP_PTP_QUEUE
    #endif
}

/*
Initializes or updates a dynamically managed enCLEP listener.
This is like llListen, but easier to use.

enCLEP_Listen(...) will return 0 and fail to add the listen if you attempt to
add more than 65 listeners (the maximum allowed per script). If you call
llListen separately, set the number of listens you want reserved for non-enCLEP\
use by adding the following line:
    #define OVERRIDE_INTEGER_ENCLEP_RESERVE_LISTENS x
where x is the number of listens you want to allocate for non-enCLEP use.

Note: domains can be set as the local prim's UUID, in which case they will be
automatically refreshed on key or link change. However, this ONLY works if the
domain itself is just the UUID - no other data can be added.

WARNING: If the local prim's UUID is used as the domain, you MUST use the
state_entry, on_rez, and changed event handler include files, which will
dynamically update the domain after a key change. (This is done automatically
in event-handlers.lsl if you use it.)
*/
integer enCLEP_Listen(
    string service, // service to listen to
    string domain,  // domain to listen to "within" the service
    integer flags   // ENCLEP_LISTEN_* flags
    )
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_Listen", ["service", "domain", "flags"], [
            enString_Elem(service),
            enString_Elem(domain),
            enInteger_ElemBitfield(flags)
            ]);
    #endif
    _enCLEP_UnListenDomains();
    integer index = llListFindList(_ENCLEP_DOMAINS, [service, domain]);
    if (index == -1 && flags & FLAG_ENCLEP_LISTEN_REMOVE)
    { // nothing to remove, so return error
        _enCLEP_ListenDomains();
        return __LINE__;
    }
    if (~index) _ENCLEP_DOMAINS = llDeleteSubList(_ENCLEP_DOMAINS, index, index + _ENCLEP_DOMAINS_STRIDE - 1); // index == -1; delete existing domain enCLEP, so it can be cleanly appended to the end
    if (llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE + OVERRIDE_INTEGER_ENCLEP_RESERVE_LISTENS > 63)
    { // too many listens (maximum 65, so if we are currently at 64 or more, fail)
        _enCLEP_ListenDomains();
        return __LINE__;
    }
    if (~flags & FLAG_ENCLEP_LISTEN_REMOVE) _ENCLEP_DOMAINS += [service, domain, flags, 0]; // add to _ENCLEP_DOMAINS only if we aren't removing it
    _enCLEP_ListenDomains();
    return 0;
}

//  resets and removes all enCLEP listeners, for single-purpose scripts to not have to independently keep track of listen handles
enCLEP_Reset()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_Reset", [], []);
    #endif
    _enCLEP_UnListenDomains();
    _ENCLEP_DOMAINS = [];
}

/*
Process incoming listen event to see if it is a CLEP message.
If not, return a positive integer.
If so, check that the message is acceptable (matches a listened-to domain, ownership checks, etc.)
If the message is acceptable, route it appropriately (either to enLEP, or whatever other library or protocol) and return 0.
If not, return 0 to signal a CLEP message even if it wasn't routable.
*/

integer _enclep_listen(
    integer channel,
    string name,
    string id,
    string message
)
{
    list data = enList_FromString(message);
    #if defined TRACE_ENCLEP || defined TRACE_ENCLEP_PROCESS
        enLog_TraceParams("_enCLEP_listen", ["channel", "name", "id", "message", "(data)"], [
            channel,
            enString_Elem(name),
            enString_Elem(id),
            enString_Elem(message),
            enList_Elem(data)
            ]);
    #endif
    if (llGetListLength(data) != 6) return __LINE__; // error in enCLEP unserialize operation
    #if defined FEATURE_ENCLEP_ENABLE_PTP
        if (llList2String(data, 0) == "CLEP_PTP")
        { // we have a PTP packet
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            string m = llList2String(data, 3); // message fragment
            integer i = llListFindList(llList2ListSlice(ENCLEP_PTP, 0, -1, _ENCLEP_PTP_STRIDE, 0), [k]);
            if (m == "")
            { // end of received message
                if (i == -1) return 0; // nothing in queue
                _enclep_listen(channel, name, id, llList2String(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE + 3)); // release buffer from queue
                _ENCLEP_PTP = llDeleteSubList(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE, (i + 1) * _ENCLEP_PTP_STRIDE - 1); // clear transfer from queue
                return 0;
            }
            if (i == -1) _ENCLEP_PTP = [k, "", channel, m]; // create new buffer
            // TODO: PTPs only from non-broadcasts (any way to enforce this?)
            // TODO: do not just blindly accept PTPs
            // TODO: PTP buffers must be requested with the total length of the message
            // TODO: if total length of message would exceed script memory, reject message
            else _ENCLEP_PTP = llListReplaceList(ENCLEP_PTP, [llList2String(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE + 3) + m], i * _ENCLEP_PTP_STRIDE + 3, i * _ENCLEP_PTP_STRIDE + 3); // append to existing buffer
            // TODO: SERVICE IS DEFINED AS "" HERE - NEED TO REWORK PTP PROTOCOL TO PASS SERVICE
            _enCLEP_MultiSayTo(id, enCLEP_Channel("", d), enList_ToString(["CLEP_PTP_More", d, k])); // request next message fragment
            return 0;
        }
        if (llList2String(data, 0) == "CLEP_PTP_More")
        { // someone is requesting the next message fragment
            string d = llList2String(data, 1); // domain
            string k = llList2String(data, 2); // transfer key
            integer i = llListFindList(llList2ListSlice(ENCLEP_PTP, 0, -1, _ENCLEP_PTP_STRIDE, 0), [k]);
            if (i == -1)
            { // we have nothing to send, because this transfer_key does not exist in the queue
                _enCLEP_MultiSayTo(id, c, enList_ToString(["CLEP_PTP", d, k, ""])); // send empty packet to signal end of transfer
                return 0;
            }
            string m = llList2String(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE + 3);
            _enCLEP_MultiSayTo(id, c, enList_ToString(["CLEP_PTP", d, k, llGetSubString(m, 0, max - 2)])); // send next packet
            if (llStringLength(m) > max) _ENCLEP_PTP = llListReplaceList(ENCLEP_PTP, [llDeleteSubString(llList2String(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE + 3), 0, max - 1)], i * _ENCLEP_PTP_STRIDE + 3, i * _ENCLEP_PTP_STRIDE + 3); // trim from buffer
            else _ENCLEP_PTP = llDeleteSubList(ENCLEP_PTP, i * _ENCLEP_PTP_STRIDE, (i + 1) * _ENCLEP_PTP_STRIDE - 1);  // delete from buffer, message fully transferred; clear transfer from queue
            return 0;
        }
    #endif

    // enList_ToString(["CLEP", service, domain, target_prim, type, message])

    if (llList2String(data, 0) != "CLEP") return __LINE__; // not a valid enCLEP message
    // note: at this point we have a valid enCLEP message, so all returns should be 0 to indicate that the enCLEP message was processed
    string service = llList2String(data, 1);
    string domain = llList2String(data, 2);
    string target_prim = llList2String(data, 3);
    if (target_prim != "" && target_prim != (string)llGetKey()) return __LINE__; // enCLEP message targeted to a different prim
    // we do a little trick here - this can technically be hacked if you use integers for your service and domain, so don't do that
    integer match_ind = llListFindList(_ENCLEP_DOMAINS, [service, domain]);
    if (match_ind == -1)
    #if defined FEATURE_ENCLEP_REPORT_INTERFERENCE
        {
            enLog_Debug(llList2String(data, 4) + " interference on channel " + (string)channel + " from service \"" + service + "\" domain \"" + domain + "\": " + llList2String(data, 5));
    #endif
    return 0; // not listening to this service + domain (channel interference)
    #if defined FEATURE_ENCLEP_REPORT_INTERFERENCE
        } // memory trick :)
    #endif

    // process flags for the matched listen
    integer flags = (integer)llList2String(_ENCLEP_DOMAINS, match_ind + 2);
    if (flags & FLAG_ENCLEP_LISTEN_OWNERONLY)
    { // owner only flag enabled for this listener
        // NOTE: THIS WILL NOT WORK FOR CROSS-REGION COMMUNICATIONS! DO NOT USE THIS FLAG FOR THAT
        if (llGetOwnerKey(id) != llGetOwner()) return 0; // not sent by same-owner object/agent
    }

    // process as LEP message
    if (llList2String(data, 4) == "LEP")
    { // LEP message
    #if defined EVENT_ENLEP_MESSAGE
        // enList_ToString([flags, enLEP_Generate(target_script, parameters), data])
        data = enList_FromString(llList2String(data, 5));
        if (llGetListLength(data) != 3) return 0; // error in LEP unserialize operation
        ENCLEP_SOURCE_PRIM = (string)id; // since enLEP does not handle source UUID directly
        ENCLEP_SOURCE_SERVICE = service; // same with service
        ENCLEP_SOURCE_DOMAIN = domain; // same with domain
        enLEP_Process(
            -1,
            (integer)llList2String(data, 0),
            llList2String(data, 1),
            llList2String(data, 2)
            );
        ENCLEP_SOURCE_PRIM = NULL_KEY; // reset values to be safe
        ENCLEP_SOURCE_SERVICE = "";
        ENCLEP_SOURCE_DOMAIN = "";
    #else
        enLog_Debug("LEP message received on service \"" + service + "\" domain \"" + domain + "\" but EVENT_ENLEP_MESSAGE is not defined: " + message);
    #endif
        return 0;
    }

    // process as generic message
    #if !defined ENCLEP_MESSAGE
        enLog_Debug("Raw/unknown CLEP message received from " + id + " on domain \"" + llList2String(data, 2) + "\" with type \"" + llList2String(data, 4) + "\", but ENCLEP_MESSAGE not defined: " + llList2String(data, 5));
    #else
        enclep_message(
            id, // source id
            llList2String(data, 2), // domain
            llList2String(data, 4), // type
            llList2String(data, 5) // message
            );
    #endif
    return 0;
}

//  internal function that runs llListenRemove on everything in _ENCLEP_DOMAINS
_enCLEP_UnListenDomains()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_UnListenDomains", [], []);
    #endif
    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    for (i = 0; i < l; i++) llListenRemove((integer)llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 3)); // for each domain in _ENCLEP_DOMAINS, remove listen by handle (we'll be replacing later)
}

//  internal function that runs llListen on everything in _ENCLEP_DOMAINS - DON'T run this without running _enCLEP_UnListenDomains() first!
_enCLEP_ListenDomains()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_ListenDomains", [], []);
    #endif

    integer i;
    integer l = llGetListLength(_ENCLEP_DOMAINS) / _ENCLEP_DOMAINS_STRIDE;
    if (l > 64 - enCLEP_Reserved())
    {
        enLog_Warn("enCLEP overflow (" + (string)l + " + " + (string)enCLEP_Reserved() + " reserved > 64)");
        l = 64 - enCLEP_Reserved();
    }
    list c;
    // for each domain in _ENCLEP_DOMAINS, add listen and update _ENCLEP_DOMAINS with handle
    for (i = 0; i < l; i++)
    {
        string service = llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE);
        string domain = llList2String(_ENCLEP_DOMAINS, i * _ENCLEP_DOMAINS_STRIDE + 1);
        integer channel = enCLEP_Channel(service, domain);
        c += [channel];
        integer handle = llListen(llList2Integer(c, -1), "", "", "");
        llListReplaceList(_ENCLEP_DOMAINS, [handle], i * _ENCLEP_DOMAINS_STRIDE + 3, i * _ENCLEP_DOMAINS_STRIDE + 3);
        enLog_Trace("enCLEP listening on service \"" + service + "\" domain \"" + domain + "\" channel " + (string)channel + " handle " + (string)handle);
    }
}

//  internal function that runs after key change to reset any listens based on previous UUID
_enCLEP_RefreshLinkset()
{
    #if defined TRACE_ENCLEP
        enLog_TraceParams("enCLEP_RefreshLinkset", [], []);
    #endif
    _enCLEP_UnListenDomains();
    if (OVERRIDE_ENOBJECT_LIMIT_SELF)
    { // we can check for self prim domains
        string new = (string)llGetKey();
        if (enObject_Self(1) != new)
        { // UUID change
            integer index = llListFindList(llList2ListSlice(_ENCLEP_DOMAINS, 0, -1, _ENCLEP_DOMAINS_STRIDE, 1), [enObject_Self(1)]);
            if (index) _ENCLEP_DOMAINS = llListReplaceList(_ENCLEP_DOMAINS,
                [new],
                index * _ENCLEP_DOMAINS_STRIDE + 1,
                index * _ENCLEP_DOMAINS_STRIDE + 1); // we are listening to a self prim domain, so update it
        }
    }
    _enCLEP_ListenDomains();
}

/*
enCLEP_DialogListen opens a regular llListen on an enCLEP channel tied to this prim UUID and script name.
This can be used in conjunction with enCLEP_DialogChannel for a safe nearly-guaranteed-random channel for this script.
*/
enCLEP_DialogListen()
{
    _enCLEP_UnListenDomains();
    if (_ENCLEP_DIALOG_LSN) llListenRemove(_ENCLEP_DIALOG_LSN);
    integer channel = enCLEP_DialogChannel();
    _ENCLEP_DIALOG_LSN = llListen(channel, "", "", "");
    enLog_Trace("Dialog listening on channel " + (string)channel + " handle " + (string)_ENCLEP_DIALOG_LSN);
    _enCLEP_ListenDomains();
}

/*
Removes the listen created by enCLEP_DialogListen.
*/
enCLEP_DialogListenRemove()
{
    if (!_ENCLEP_DIALOG_LSN) return;
    _enCLEP_UnListenDomains();
    llListenRemove(_ENCLEP_DIALOG_LSN);
    _ENCLEP_DIALOG_LSN = 0;
    _enCLEP_ListenDomains();
}
