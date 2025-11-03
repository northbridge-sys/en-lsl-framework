/*
enTimer.lsl
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
*/

#define FLAG_ENTIMER_ONESHOT 0x0
#define FLAG_ENTIMER_PERIODIC 0x1

#ifndef OVERRIDE_FLOAT_ENTIMER_MINIMUM_INTERVAL
    #define OVERRIDE_FLOAT_ENTIMER_MINIMUM_INTERVAL 0.1
#endif

#if defined TRACE_EN
    #define TRACE_ENTIMER
#endif

#if defined FEATURE_ENTIMER_DISABLE_MULTIPLE
    list _ENTIMER_QUEUE; // id, callback, length
    #define _ENTIMER_QUEUE_STRIDE 3
#else
    list _ENTIMER_QUEUE; // id, callback, length, trigger
    #define _ENTIMER_QUEUE_STRIDE 4
#endif

/*  
FEATURE_ENTIMER_ENABLE_PREEMPTION is required to enable "preemption" mode, which exposes
the enTimer_SetPreempt accessor function. If enTimer_SetPreempt(1) is called,
all future timer events will skip the slow enTimer_Check call and, in
combination with EVENT_EN_TIMER, pass the timer event directly to en_timer.

This is useful for scripts that need to temporarily process high-frequency timer
events and can tolerate delaying enTimer triggers until enTimer_SetPreempt(0) is
called.
*/
#if defined FEATURE_ENTIMER_ENABLE_PREEMPTION
    integer _ENTIMER_PREEMPT;
#endif
