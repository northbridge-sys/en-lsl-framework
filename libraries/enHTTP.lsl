 /*
    enHTTP.lsl
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

    TODO

    WARNING: enHTTP uses the llSetTimerEvent() timer. TODO: allow using either SIT
    or MIT
*/

// ==
// == globals
// ==

integer _ENHTTP_PAUSE; // pause for rate limit
list _ENHTTP_REQUESTS; // enhttp_id, req_id, url, http_params, body
#define _ENHTTP_REQUESTS_STRIDE 5

// ==
// == functions
// ==

key enHTTP$Request( // sends an HTTP request to a URL
    string url,         // url to pass to llHTTPRequest
    list http_params,   // parameters to pass to llHTTPRequest
                        //  do not specify the following parameters:
                        //  - HTTP_VERBOSE_THROTTLE: automatically set FALSE
                        //  - HTTP_EXTENDED_ERROR: must always be FALSE (default)
    string body         // body to pass to llHTTPRequest
    )
{
    #ifdef ENHTTP$TRACE
        enLog$TraceParams("enHTTP$Request", ["url", "http_params", "body"], [
            enString$Elem(url),
            enList$Elem(http_params),
            enString$Elem(body)
            ]);
    #endif
    #ifndef ENHTTP$ENABLE_REQUESTS
        enLog$(DEBUG, "enHTTP$Request failed due to ENHTTP$ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer len = llStringLength(url) + llStringLength(body);
    if (len * 4 + 2048 > llGetFreeMemory())
    { // refuse request due to low memory
        enLog$(DEBUG, "enHTTP$Request failed due to low memory.");
        return NULL_KEY;
    }
    // populate pending requests stack
    string en_id = llGenerateKey();
    _ENHTTP_REQUESTS += [
        en_id,
        NULL_KEY,
        url,
        llDumpList2String(http_params, "\n"),
        body
        ];
    if (!_ENHTTP_PAUSE) _enHTTP$NextRequest(); // not being throttled, so request now
    return en_id;
}

_enHTTP$ProcessResponse( // processes http_response
    string req_id,
    integer status,
    list metadata,
    string body
    )
{
    #ifdef ENHTTP$TRACE
        enLog$TraceParams("_enHTTP$ProcessResponse", ["req_id", "status", "metadata", "body"], [
            enString$Elem(req_id),
            status,
            enList$Elem(metadata),
            enString$Elem(body)
            ]);
    #endif
    #ifndef ENHTTP$ENABLE_REQUESTS
        enLog$(DEBUG, "_enHTTP$ProcessResponse failed due to ENHTTP$ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer req_ind = llListFindList(llList2ListSlice(_ENHTTP_REQUESTS, 0, -1, _ENHTTP_REQUESTS_STRIDE, 1), [req_id]);
    if (req_ind == -1) return; // not a response to a known request
    #ifdef ENHTTP$ENABLE
        en$http_response(
            orig_id,
            llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS_STRIDE + 2), // url
            llParseStringKeepNulls(llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS_STRIDE + 3), ["\n"], []), // http_params
            llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS_STRIDE + 4), // request_body
            status,
            metadata,
            body
            );
    #endif
    _ENHTTP_REQUESTS = llDeleteSubList(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS_STRIDE, (req_ind + 1) * _ENHTTP_REQUESTS_STRIDE - 1);
}

_enHTTP$Timer() // request queue timer
{
    #ifdef ENHTTP$TRACE
        enLog$TraceParams("_enHTTP$Timer", [], []);
    #endif
    #ifdef ENHTTP$ENABLE_REQUESTS
        // TODO: allow using either SIT or MIT instead of directly calling llSetTimerEvent
        llSetTimerEvent(0.0);
        if (_ENHTTP_REQUESTS == [])
        { // no requests to process
            _ENHTTP_PAUSE = 0;
            return;
        }
        // keep firing off queued requests
        integer resp;
        do resp = _enHTTP$NextRequest();
        while (resp == 1);
        // can't fire off any more queued requests
        if (resp == -1)
        { // throttled while processing queue
            _ENHTTP_PAUSE *= 2; // double _ENHTTP_PAUSE
            enLog$(DEBUG, "enHTTP$Request retry throttled, pausing " + (string)_ENHTTP_PAUSE + " seconds.");
            llSetTimerEvent(_ENHTTP_PAUSE);
            return;
        }
        // not throttled
        _ENHTTP_PAUSE = 0;
    #endif
}

integer _enHTTP$NextRequest() // fire off next request in queue (used internally by _enHTTP$Timer)
{
    #ifdef ENHTTP$TRACE
        enLog$TraceParams("_enHTTP$NextRequest", [], []);
    #endif
    integer req_ind = llListFindList(llList2ListSlice(_ENHTTP_REQUESTS, 0, -1, _ENHTTP_REQUESTS_STRIDE, 1), [NULL_KEY]);
    if (req_ind == -1) return 0; // no more requests to make
    string req_id = llHTTPRequest(
        llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS + 2),
        llParseStringKeepNulls(llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS + 3), ["\n"], []) + [HTTP_VERBOSE_THROTTLE, FALSE],
        llList2String(_ENHTTP_REQUESTS, req_ind * _ENHTTP_REQUESTS + 4)
        );
    if (req_id == NULL_KEY)
    {
        if (!_ENHTTP_PAUSE)
        {
            _ENHTTP_PAUSE = 40;
            llSetTimerEvent(_ENHTTP_PAUSE);
            enLog$(DEBUG, "enHTTP$Request throttled, pausing " + (string)_ENHTTP_PAUSE + " seconds.");
        }
        return -1; // throttled
    }
    _ENHTTP_REQUESTS = llListReplaceList(_ENHTTP_REQUESTS, [req_id], req_ind * _ENHTTP_REQUESTS + 1, req_ind * _ENHTTP_REQUESTS + 1);
    return 1;
}
