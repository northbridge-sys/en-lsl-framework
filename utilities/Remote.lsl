/*
    Remote.lsl
	Utility Script
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

    This is a full script that sets llRemoteLoadScriptPin( ... ) and notifies its
    parent object of the pin via enChat on rez, then deletes itself.  This can be
    used to load one or more scripts dynamically into the newly rezzed object.
*/

#define EN$ALL_TRACE

#include "en-lsl-framework/main.lsl"

default
{
    // we don't need full En support in this script, so the state_entry and on_rez event handlers are defined manually
    state_entry()
    {
        enLog$TraceParams( "state_entry", [], [] );

        // force temp off
        llSetLinkPrimitiveParamsFast( LINK_SET, [ PRIM_TEMP_ON_REZ, FALSE ] );
        enLog$( WARN, "Disabled temp-on-rez because script was reset. Make sure you re-enable it before packaging." );
    }

    on_rez( integer param )
    {
        // calling enInventory$RezRemote in the parent causes the loglevel to be sent as the start parameter,
        // so immediately write loglevel based on llRez* start parameter
        llLinksetDataWrite( "loglevel", (string)param );

        // trace event params after setting loglevel
        enLog$TraceParams( "on_rez", [ "param" ], [ param ] );

        enObject$StopIfOwnerRezzed(); // if owner rezzed us from inventory, stop script for inspection

        // check that object is temp-on-rez and, if not, warn the owner that it was packaged improperly
        if ( !(integer)llList2String( llGetObjectDetails( llGetKey(), [ OBJECT_TEMP_ON_REZ ] ), 0 ) ) enLog$Fatal( "Object is not temp-on-rez; set temp-on-rez and repackage." );

        // generate and llRemoteLoadScriptPin pin
        integer pin = enInteger$Rand();
        if ( !pin ) pin++; // need a nonzero pin
        llSetRemoteScriptAccessPin( pin );

        // notify parent that we are rezzed and ready to receive script(s)
        enChat$SetService( "enInventory$RezRemote" );
        enChat$Send( // send via enChat
            enObject$Parent(), // prim
            enObject$Parent(), // domain
            "enInventory$RezRemote", // type
            (string)pin // message
            );

        // immediately delete this script, if the script transfer fails the object will be culled as temporary anyway
        llRemoveInventory( llGetScriptName() );
    }
}
