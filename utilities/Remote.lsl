/*
    Remote.lsl
	Utility Script
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

    This is a full script that sets llRemoteLoadScriptPin( ... ) and notifies its
    parent object of the pin via XiChat on rez, then deletes itself.  This can be
    used to load one or more scripts dynamically into the newly rezzed object.
*/

#define XI$ALL_TRACE

#include "xi-lsl-framework/main.lsl"

default
{
    // we don't need full Xi support in this script, so the state_entry and on_rez event handlers are defined manually
    state_entry()
    {
        XiLog$TraceParams( "state_entry", [], [] );

        // force temp off
        llSetLinkPrimitiveParamsFast( LINK_SET, [ PRIM_TEMP_ON_REZ, FALSE ] );
        XiLog$( WARN, "Disabled temp-on-rez because script was reset. Make sure you re-enable it before packaging." );
    }

    on_rez( integer param )
    {
        // calling XiInventory$RezRemote in the parent causes the loglevel to be sent as the start parameter,
        // so immediately write loglevel based on llRez* start parameter
        llLinksetDataWrite( "loglevel", (string)param );

        // trace event params after setting loglevel
        XiLog$TraceParams( "on_rez", [ "param" ], [ param ] );

        XiObject$StopIfOwnerRezzed(); // if owner rezzed us from inventory, stop script for inspection

        // check that object is temp-on-rez and, if not, warn the owner that it was packaged improperly
        if ( !(integer)llList2String( llGetObjectDetails( llGetKey(), [ OBJECT_TEMP_ON_REZ ] ), 0 ) ) XiLog$Fatal( "Object is not temp-on-rez; set temp-on-rez and repackage." );

        // generate and llRemoteLoadScriptPin pin
        integer pin = XiInteger$Rand();
        if ( !pin ) pin++; // need a nonzero pin
        llSetRemoteScriptAccessPin( pin );

        // notify parent that we are rezzed and ready to receive script(s)
        XiChat$SetService( "XiInventory$RezRemote" );
        XiChat$Send( // send via XiChat
            XiObject$Parent(), // prim
            XiObject$Parent(), // domain
            "XiInventory$RezRemote", // type
            (string)pin // message
            );

        // immediately delete this script, if the script transfer fails the object will be culled as temporary anyway
        llRemoveInventory( llGetScriptName() );
    }
}
