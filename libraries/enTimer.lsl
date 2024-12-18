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

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

    TODO
*/

// ==
// == globals
// ==

#ifdef ENTIMER_DISABLE_MULTIPLE
    list _ENTIMER_QUEUE; // id, callback, length
    #define _ENTIMER_QUEUE_STRIDE 3
#else
    list _ENTIMER_QUEUE; // id, callback, length, trigger
    #define _ENTIMER_QUEUE_STRIDE 4
#endif

// ==
// == functions
// ==

string enTimer_Start( // adds a timer
    float interval,
    integer periodic,
    string callback
    )
{
    #ifdef ENTIMER_TRACE
        enLog_TraceParams("enTimer_Start", [ "interval", "periodic", "callback" ], [
            interval,
            periodic,
            enString_Elem( callback )
            ]);
    #endif

    // check inputs
    if ( interval < 0.01 ) return NULL_KEY; // invalid interval
    if ( interval < ENTIMER_MINIMUM_INTERVAL ) interval = ENTIMER_MINIMUM_INTERVAL; // clamp to minimum interval
    string id = llGenerateKey();
    #ifdef ENTIMER_DISABLE_MULTIPLE
        _ENTIMER_QUEUE = [ // multiple timers not enabled, so set queue
            id,
            callback,
            (integer)( interval * 1000 ) * !!periodic
        ];
        llSetTimerEvent( interval ); // then start single timer
    #else
        _ENTIMER_QUEUE += [ // multiple timers enabled, so add to queue
            id,
            callback,
            (integer)( interval * 1000 ) * !!periodic,
            enDate_MSAdd( enDate_MSNow(), (integer)( interval * 1000 ) ) // convert to ms
        ];
        enTimer_Check(); // then reprocess queue
    #endif
    return id;
}

integer enTimer_Cancel( // removes a timer
    string id // required unless ENTIMER_DISABLE_MULTIPLE is set
    )
{
    #ifdef ENTIMER_TRACE
        enLog_TraceParams("enTimer_Cancel", [ "id" ], [
            enString_Elem( id )
            ]);
    #endif
    #ifdef ENTIMER_DISABLE_MULTIPLE
        _ENTIMER_QUEUE = []; // we only have one timer, so cancel it
        llSetTimerEvent( 0.0 );
    #else
        // find timer by id
        integer i = llListFindList( llList2ListSlice( _ENTIMER_QUEUE, 0, -1, _ENTIMER_QUEUE_STRIDE, 0 ), [ id ] );
        if ( i == -1 ) return 0; // not found
        // found, delete it
        _ENTIMER_QUEUE = llDeleteSubList( _ENTIMER_QUEUE, i, i + _ENTIMER_QUEUE_STRIDE - 1 );
        enTimer_Check(); // then reprocess queue
    #endif
    return 1;
}

string enTimer_Find( // finds a timer by callback
    string callback
    )
{
    #ifdef ENTIMER_TRACE
        enLog_TraceParams("enTimer_Find", [ "callback" ], [
            enString_Elem( callback )
            ]);
    #endif
    integer i = llListFindList( llList2ListSlice( _ENTIMER_QUEUE, 0, -1, _ENTIMER_QUEUE_STRIDE, 1 ), [ callback ] );
    if ( i == -1 ) return "";
    return llList2String( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE );
}

integer enTimer_InternalLoopback(
    string callback
)
{
    if (callback == "enObject_TextTemp")
    {
        enObject_TextTemp();
        return 1;
    }
    return 0;
}

enTimer_Check() // checks the MIT timers to see if any are triggered
{
    #ifdef ENTIMER_TRACE
        enLog_TraceParams("enTimer_Check", [], []);
    #endif
    llSetTimerEvent(0.0);
    if ( _ENTIMER_QUEUE == [] ) return; // no timer to check
    #ifdef ENMIT_DISABLE_MULTIPLE
        en_entimer(
            llList2String( _ENTIMER_QUEUE, 0 ),
            llList2String( _ENTIMER_QUEUE, 1 )
        );
        if ( (integer)llList2String( _ENTIMER_QUEUE, 3 ) ) llSetTimerEvent( (integer)llList2String( _ENTIMER_QUEUE, 3 ) * 0.001 ); // periodic
        else _ENTIMER_QUEUE = []; // one-shot
    #else
        integer now = enDate_MSNow();
        integer i;
        integer l = llGetListLength( _ENTIMER_QUEUE ) / _ENTIMER_QUEUE_STRIDE;
        integer lowest = 0x7FFFFFFF;
        for (i = 0; i < l; i++)
        {
            string t_id = llList2String( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE );
            string t_callback = llList2String( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE + 1 );
            integer t_length = (integer)llList2String( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE + 2 );
            integer t_trigger = (integer)llList2String( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE + 3 );
            integer remain = enDate_MSAdd( t_trigger, -now );
            if ( remain * 0.001 < ENTIMER_MINIMUM_INTERVAL )
            { // timer triggered
                if ( !t_length )
                { // one-shot, so drop it from the queue
                    _ENTIMER_QUEUE = llDeleteSubList( _ENTIMER_QUEUE, i * _ENTIMER_QUEUE_STRIDE, ( i + 1 ) * _ENTIMER_QUEUE_STRIDE - 1 );
                    i--; l--; // shift for loop to account for lost queue stride
                }
                else if ( t_length < lowest ) lowest = t_length; // periodic, and it is currently the next timer to trigger
                if (!enTimer_InternalLoopback(t_callback))
                {
                    #ifdef ENTIMER_ENABLE
                        enLog_Trace("enTimer " + t_id + " triggered: " + t_callback);
                        en_entimer( // fire function
                            t_id,
                            t_callback
                            );
                    #endif
                }
            }
            else if ( remain < lowest ) lowest = remain; // timer not triggered, but it is currently the next timer to trigger
        }
        if ( lowest != 0x7FFFFFFF )
        { // a timer is still in the queue
            llSetTimerEvent( lowest * 0.001 );
            enLog_Trace("enTimer set llSetTimerEvent(" + (string)(lowest * 0.001) + ")");
        }
    #endif
}
