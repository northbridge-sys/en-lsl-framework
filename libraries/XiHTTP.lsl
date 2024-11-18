 /*
    XiHTTP.lsl
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

    TODO

    WARNING: XiHTTP uses the llSetTimerEvent() timer. TODO: allow using either SIT
    or MIT
*/

// ==
// == globals
// ==

integer _XIHTTP_PAUSE; // pause for rate limit
list _XIHTTP_REQUESTS; // Xihttp_id, req_id, url, http_params, body
#define _XIHTTP_REQUESTS_STRIDE 5

// ==
// == functions
// ==

key XiHTTP$Request( // sends an HTTP request to a URL
    string url,         // url to pass to llHTTPRequest
    list http_params,   // parameters to pass to llHTTPRequest
                        //  do not specify the following parameters:
                        //  - HTTP_VERBOSE_THROTTLE: automatically set FALSE
                        //  - HTTP_EXTENDED_ERROR: must always be FALSE (default)
    string body         // body to pass to llHTTPRequest
    )
{
    #ifdef XIHTTP$TRACE
        XiLog$TraceParams("XiHTTP$Request", ["url", "http_params", "body"], [
            XiString$Elem(url),
            XiList$Elem(http_params),
            XiString$Elem(body)
            ]);
    #endif
    #ifndef XIHTTP$ENABLE_REQUESTS
        XiLog$(DEBUG, "XiHTTP$Request failed due to XIHTTP$ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer len = llStringLength(url) + llStringLength(body);
    if (len * 4 + 2048 > llGetFreeMemory())
    { // refuse request due to low memory
        XiLog$(DEBUG, "XiHTTP$Request failed due to low memory.");
        return NULL_KEY;
    }
    // populate pending requests stack
    string Xi_id = llGenerateKey();
    _XIHTTP_REQUESTS += [
        Xi_id,
        NULL_KEY,
        url,
        llDumpList2String(http_params, "\n"),
        body
        ];
    if (!_XIHTTP_PAUSE) _XiHTTP$NextRequest(); // not being throttled, so request now
    return Xi_id;
}

_XiHTTP$ProcessResponse( // processes http_response
    string req_id,
    integer status,
    list metadata,
    string body
    )
{
    #ifdef XIHTTP$TRACE
        XiLog$TraceParams("_XiHTTP$ProcessResponse", ["req_id", "status", "metadata", "body"], [
            XiString$Elem(req_id),
            status,
            XiList$Elem(metadata),
            XiString$Elem(body)
            ]);
    #endif
    #ifndef XIHTTP$ENABLE_REQUESTS
        XiLog$(DEBUG, "_XiHTTP$ProcessResponse failed due to XIHTTP$ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer req_ind = llListFindList(llList2ListSlice(_XIHTTP_REQUESTS, 0, -1, _XIHTTP_REQUESTS_STRIDE, 1), [req_id]);
    if (req_ind == -1) return; // not a response to a known request
    #ifdef XIHTTP$ENABLE
        Xi$http_response(
            orig_id,
            llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS_STRIDE + 2), // url
            llParseStringKeepNulls(llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS_STRIDE + 3), ["\n"], []), // http_params
            llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS_STRIDE + 4), // request_body
            status,
            metadata,
            body
            );
    #endif
    _XIHTTP_REQUESTS = llDeleteSubList(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS_STRIDE, (req_ind + 1) * _XIHTTP_REQUESTS_STRIDE - 1);
}

_XiHTTP$Timer() // request queue timer
{
    #ifdef XIHTTP$TRACE
        XiLog$TraceParams("_XiHTTP$Timer", [], []);
    #endif
    #ifdef XIHTTP$ENABLE_REQUESTS
        // TODO: allow using either SIT or MIT instead of directly calling llSetTimerEvent
        llSetTimerEvent(0.0);
        if (_XIHTTP_REQUESTS == [])
        { // no requests to process
            _XIHTTP_PAUSE = 0;
            return;
        }
        // keep firing off queued requests
        integer resp;
        do resp = _XiHTTP$NextRequest();
        while (resp == 1);
        // can't fire off any more queued requests
        if (resp == -1)
        { // throttled while processing queue
            _XIHTTP_PAUSE *= 2; // double _XIHTTP_PAUSE
            XiLog$(DEBUG, "XiHTTP$Request retry throttled, pausing " + (string)_XIHTTP_PAUSE + " seconds.");
            llSetTimerEvent(_XIHTTP_PAUSE);
            return;
        }
        // not throttled
        _XIHTTP_PAUSE = 0;
    #endif
}

integer _XiHTTP$NextRequest() // fire off next request in queue (used internally by _XiHTTP$Timer)
{
    #ifdef XIHTTP$TRACE
        XiLog$TraceParams("_XiHTTP$NextRequest", [], []);
    #endif
    integer req_ind = llListFindList(llList2ListSlice(_XIHTTP_REQUESTS, 0, -1, _XIHTTP_REQUESTS_STRIDE, 1), [NULL_KEY]);
    if (req_ind == -1) return 0; // no more requests to make
    string req_id = llHTTPRequest(
        llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS + 2),
        llParseStringKeepNulls(llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS + 3), ["\n"], []) + [HTTP_VERBOSE_THROTTLE, FALSE],
        llList2String(_XIHTTP_REQUESTS, req_ind * _XIHTTP_REQUESTS + 4)
        );
    if (req_id == NULL_KEY)
    {
        if (!_XIHTTP_PAUSE)
        {
            _XIHTTP_PAUSE = 40;
            llSetTimerEvent(_XIHTTP_PAUSE);
            XiLog$(DEBUG, "XiHTTP$Request throttled, pausing " + (string)_XIHTTP_PAUSE + " seconds.");
        }
        return -1; // throttled
    }
    _XIHTTP_REQUESTS = llListReplaceList(_XIHTTP_REQUESTS, [req_id], req_ind * _XIHTTP_REQUESTS + 1, req_ind * _XIHTTP_REQUESTS + 1);
    return 1;
}
