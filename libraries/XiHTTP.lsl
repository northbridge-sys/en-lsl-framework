 /*
    XiHTTP.lsl
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

    TODO

    WARNING: XiHTTP uses the llSetTimerEvent() timer. TODO: allow using either SIT
    or MIT
*/

// ==
// == preprocessor options
// ==

#ifdef XIALL_ENABLE_XILOG_TRACE
#define XIHTTP_ENABLE_XILOG_TRACE
#endif

// ==
// == globals
// ==

integer XIHTTP_PAUSE; // pause for rate limit
list XIHTTP_REQUESTS; // Xihttp_id, req_id, url, http_params, body
#define XIHTTP_REQUESTS_STRIDE 5

// ==
// == functions
// ==

key XiHTTP_Request( // sends an HTTP request to a URL
    string url,         // url to pass to llHTTPRequest
    list http_params,   // parameters to pass to llHTTPRequest
                        //  do not specify the following parameters:
                        //  - HTTP_VERBOSE_THROTTLE: automatically set FALSE
                        //  - HTTP_EXTENDED_ERROR: must always be FALSE (default)
    string body         // body to pass to llHTTPRequest
    )
{
    #ifdef XIHTTP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiHTTP_Request", ["url", "http_params", "body"], [
            XiString_Elem(url),
            XiList_Elem(http_params),
            XiString_Elem(body)
            ]);
    #endif
    #ifndef XIHTTP_ENABLE_REQUESTS
        XiLog(DEBUG, "XiHTTP_Request failed due to XIHTTP_ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer len = llStringLength(url) + llStringLength(body);
    if (len * 4 + 2048 > llGetFreeMemory())
    { // refuse request due to low memory
        XiLog(DEBUG, "XiHTTP_Request failed due to low memory.");
        return NULL_KEY;
    }
    // populate pending requests stack
    string Xi_id = llGenerateKey();
    XIHTTP_REQUESTS += [
        Xi_id,
        NULL_KEY,
        url,
        llDumpList2String(http_params, "\n"),
        body
        ];
    if (!XIHTTP_PAUSE) _XiHTTP_NextRequest(); // not being throttled, so request now
    return Xi_id;
}

_XiHTTP_ProcessResponse( // processes http_response
    string req_id,
    integer status,
    list metadata,
    string body
    )
{
    #ifdef XIHTTP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiHTTP_ProcessResponse", ["req_id", "status", "metadata", "body"], [
            XiString_Elem(req_id),
            status,
            XiList_Elem(metadata),
            XiString_Elem(body)
            ]);
    #endif
    #ifndef XIHTTP_ENABLE_REQUESTS
        XiLog(DEBUG, "_XiHTTP_ProcessResponse failed due to XIHTTP_ENABLE_REQUESTS not being defined.");
        return;
    #endif
    integer req_ind = llListFindList(llList2ListSlice(XIHTTP_REQUESTS, 0, -1, XIHTTP_REQUESTS_STRIDE, 1), [req_id]);
    if (req_ind == -1) return; // not a response to a known request
    Xi_http_response(
        orig_id,
        llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS_STRIDE + 2), // url
        llParseStringKeepNulls(llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS_STRIDE + 3), ["\n"], []), // http_params
        llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS_STRIDE + 4), // request_body
        status,
        metadata,
        body
        );
    XIHTTP_REQUESTS = llDeleteSubList(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS_STRIDE, (req_ind + 1) * XIHTTP_REQUESTS_STRIDE - 1);
}

_XiHTTP_Timer() // request queue timer
{
    #ifdef XIHTTP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiHTTP_Timer", [], []);
    #endif
    #ifdef XIHTTP_ENABLE_REQUESTS
        // TODO: allow using either SIT or MIT instead of directly calling llSetTimerEvent
        llSetTimerEvent(0.0);
        if (XIHTTP_REQUESTS == [])
        { // no requests to process
            XIHTTP_PAUSE = 0;
            return;
        }
        // keep firing off queued requests
        integer resp;
        do resp = _XiHTTP_NextRequest();
        while (resp == 1);
        // can't fire off any more queued requests
        if (resp == -1)
        { // throttled while processing queue
            XIHTTP_PAUSE *= 2; // double XIHTTP_PAUSE
            XiLog(DEBUG, "XiHTTP_Request retry throttled, pausing " + (string)XIHTTP_PAUSE + " seconds.");
            llSetTimerEvent(XIHTTP_PAUSE);
            return;
        }
        // not throttled
        XIHTTP_PAUSE = 0;
    #endif
}

integer _XiHTTP_NextRequest() // fire off next request in queue (used internally by _XiHTTP_Timer)
{
    #ifdef XIHTTP_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiHTTP_NextRequest", [], []);
    #endif
    integer req_ind = llListFindList(llList2ListSlice(XIHTTP_REQUESTS, 0, -1, XIHTTP_REQUESTS_STRIDE, 1), [NULL_KEY]);
    if (req_ind == -1) return 0; // no more requests to make
    string req_id = llHTTPRequest(
        llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS + 2),
        llParseStringKeepNulls(llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS + 3), ["\n"], []) + [HTTP_VERBOSE_THROTTLE, FALSE],
        llList2String(XIHTTP_REQUESTS, req_ind * XIHTTP_REQUESTS + 4)
        );
    if (req_id == NULL_KEY)
    {
        if (!XIHTTP_PAUSE)
        {
            XIHTTP_PAUSE = 40;
            llSetTimerEvent(XIHTTP_PAUSE);
            XiLog(DEBUG, "XiHTTP_Request throttled, pausing " + (string)XIHTTP_PAUSE + " seconds.");
        }
        return -1; // throttled
    }
    XIHTTP_REQUESTS = llListReplaceList(XIHTTP_REQUESTS, [req_id], req_ind * XIHTTP_REQUESTS + 1, req_ind * XIHTTP_REQUESTS + 1);
    return 1;
}
