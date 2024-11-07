/*
    XiMIT.lsl
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
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XITIMER_ENABLE_XILOG_TRACE
#endif

#ifndef XITIMER_MINIMUM_INTERVAL
#define XITIMER_MINIMUM_INTERVAL 0.1
#endif

// ==
// == globals
// ==

#ifdef XITIMER_ENABLE_MULTIPLE
list XITIMER_QUEUE; // id, remain, length, callback
string XISIT_CALLBACK;
integer XISIT_PERIODIC;
#else

#endif
#define XITIMER_QUEUE_STRIDE 4

// ==
// == functions
// ==

string XiTimer_Start( // adds a timer
    float interval,
    integer periodic,
    string callback
    )
{
    #ifdef XITIMER_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiTimer_Start", ["interval", "periodic", "callback"], [
            interval,
            periodic,
            XiString_Elem( callback )
            ]);
    #endif

    // check inputs
    if ( interval < 0.00001 ) return NULL_KEY; // invalid interval
    if ( interval < XITIMER_MINIMUM_INTERVAL ) interval = XITIMER_MINIMUM_INTERVAL; // clamp to minimum interval

    #ifdef XITIMER_ENABLE_MULTIPLE
        if (interval < 0.00001) return ""; // invalid interval
        if (interval < XIMIT_MINIMUM_INTERVAL) interval = XIMIT_MINIMUM_INTERVAL;
        if (XIMIT_TIMERS == []) llResetTime(); // reset time to get better precision
        string id = llGenerateKey();
        XIMIT_TIMERS += [id, interval + llGetTime(), interval * !!periodic, callback];
        _XiMIT_Check();
        return id;
    #else
        if ( XITIMER_QUEUE != [] ) return NULL_KEY; // timer is already running, cancel it first
        if (

        if (XISIT_CALLBACK != "" ) return 0; // SIT timer already eXists
        if (callback == "") return 0; // callback must be defined
        if (interval < 0.00001) return 0; // interval must be positive
        // all set, start timer
        XISIT_CALLBACK = callback;
        XISIT_PERIODIC = periodic;
        llSetTimerEvent(interval);
        return 1;
    #endif
    #ifdef XISIT_ENABLE
        XiLog(WARN, "XISIT_ENABLE defined but XiMIT_Add called; SIT and MIT cannot be enabled simultaneously, this will cause problems.");
    #endif
    #ifndef XIMIT_ENABLE
        XiLog(WARN, "XIMIT_ENABLE not defined.");
        return "";
    #else
    #endif
}

integer XiMIT_Remove( // removes an MIT timer
    string id
    )
{
    #ifdef XIMIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiMIT_Remove", ["id"], [
            XiString_Elem(id)
            ]);
    #endif
    #ifdef XISIT_ENABLE
        XiLog(WARN, "XISIT_ENABLE defined but XiMIT_Remove called; SIT and MIT cannot be enabled simultaneously, this will cause problems.");
    #endif
    #ifndef XIMIT_ENABLE
        XiLog(WARN, "XIMIT_ENABLE not defined.");
        return 0;
    #else
        integer i = llListFindList(llList2ListSlice(XIMIT_TIMERS, 0, -1, XIMIT_TIMERS_STRIDE, 0), [id]);
        if (i == -1) return 0;
        XIMIT_TIMERS = llDeleteSubList(XIMIT_TIMERS, i, i + XIMIT_TIMERS_STRIDE - 1);
        _XiMIT_Check();
        return 1;
    #endif
}

string XiMIT_Find( // finds an MIT timer by callback
    string callback
    )
{
    #ifdef XIMIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiMIT_Find", ["callback"], [
            XiString_Elem(callback)
            ]);
    #endif
    #ifdef XISIT_ENABLE
        XiLog(WARN, "XISIT_ENABLE defined but XiMIT_Find called; SIT and MIT cannot be enabled simultaneously, this will cause problems.");
    #endif
    #ifndef XIMIT_ENABLE
        XiLog(WARN, "XIMIT_ENABLE not defined.");
        return "";
    #else
        integer i = llListFindList(llList2ListSlice(XIMIT_TIMERS, 0, -1, XIMIT_TIMERS_STRIDE, 3), [callback]);
        if (i == -1) return "";
        return llList2String(XIMIT_TIMERS, i * XIMIT_TIMERS_STRIDE);
    #endif
}

_XiMIT_Check() // checks the MIT timers to see if any are triggered
{
    #ifdef XIMIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiMIT_Check", [], []);
    #endif
    #ifdef XIMIT_ENABLE
        llSetTimerEvent(0.0);
        float time = llGetAndResetTime(); // TODO: at some point port this to XiDate_MSNow() so we don't keep messing with llGetTime
        integer i;
        integer l = llGetListLength(XIMIT_TIMERS) / XIMIT_TIMERS_STRIDE;
        list new;
        float lowest = 3.402823466E+38;
        for (i = 0; i < l; i++)
        {
            string t_id = llList2String(XIMIT_TIMERS, i * XIMIT_TIMERS_STRIDE);
            float t_remain = (float)llList2String(XIMIT_TIMERS, i * XIMIT_TIMERS_STRIDE + 1);
            float t_repeat = (float)llList2String(XIMIT_TIMERS, i * XIMIT_TIMERS_STRIDE + 2);
            string t_callback = llList2String(XIMIT_TIMERS, i * XIMIT_TIMERS_STRIDE + 3);
            if (t_remain - XIMIT_MINIMUM_INTERVAL <= time)
            { // timer triggered
                if (t_repeat >= XIMIT_MINIMUM_INTERVAL)
                { // add to new as repeated
                    new += [t_id, t_remain, t_repeat, t_callback];
                    if (t_repeat < lowest) lowest = t_repeat;
                }
                Xi_mit_trigger(
                    t_id,
                    t_callback
                    );
            }
            else
            { // timer not triggered
                new += [t_id, t_remain, t_repeat, t_callback];
                if (t_remain - time < lowest) lowest = t_remain - time;
            }
        }
        if (new != [])
        {
            float x = lowest - llGetTime();
            if (x < XIMIT_MINIMUM_INTERVAL) x = XIMIT_MINIMUM_INTERVAL;
            llSetTimerEvent(x);
        }
        XIMIT_TIMERS = new;
    #endif
}


/*
    XiSIT.lsl
    Single Interval Timer
    Library Script
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

    The Single Interval Timer is a method of
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XISIT_ENABLE_XILOG_TRACE
#endif

// ==
// == globals
// ==

#ifdef XISIT_ENABLE
#endif

// ==
// == functions
// ==

integer XiSIT_Start( // starts the SIT timer
    float interval,
    integer periodic,
    string callback,
    integer force
    )
{
    #ifdef XISIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiSIT_Start", ["interval", "periodic", "callback", "force"], [
            interval,
            periodic,
            XiString_Elem(callback),
            force
            ]);
    #endif
    #ifndef XISIT_ENABLE
        XiLog(WARN, "XISIT_ENABLE not defined.");
        return 0;
    #else
    #endif
}

XiSIT_Cancel( // cancels the SIT timer
    )
{
    #ifdef XISIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("XiSIT_Cancel", [], []);
    #endif
    #ifndef XISIT_ENABLE
        XiLog(WARN, "XISIT_ENABLE not defined.");
        return;
    #else
        llSetTimerEvent(0.0);
        XISIT_CALLBACK = "";
    #endif
}

_XiSIT_Trigger( // internal function called when timer is triggered
    )
{
    #ifdef XISIT_ENABLE_XILOG_TRACE
        XiLog_TraceParams("_XiSIT_Trigger", [], []);
    #endif
    #ifdef XISIT_ENABLE
        if (XISIT_CALLBACK == "")
        { // reset timer and do nothing if mode is empty
            llSetTimerEvent(0.0);
            return;
        }
        string t_c = XISIT_CALLBACK; // this must be moved to a temporary variable, because XISIT_MODE might be set via XiSIT_Start in Xi_sit_trigger, and also we will lose XISIT_CALLBACK if not XISIT_PERIODIC
        if (!XISIT_PERIODIC)
        { // we are not periodic, so reset timer and clear callback
            llSetTimerEvent(0.0); // only reset timer if not periodic or mode empty
            XISIT_CALLBACK = ""; // clear timer
        }
        Xi_sit_trigger(t_c);
    #endif
}
