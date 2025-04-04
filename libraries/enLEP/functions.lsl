/*
enLEP.lsl
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

//  sends a LEP message
enLEP_Send(
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined ENLEP_TRACE
        enLog_TraceParams("enLEP_Send", ["target_link", "target_script", "flags", "paramters", "data"], [
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, enLEP_Generate(target_script, parameters), data);
}

//  sends a LEP message as a specific source_script name
enLEP_SendAs(
    string source_script,
    integer target_link,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    #if defined ENLEP_TRACE
        enLog_TraceParams("enLEP_SendAs", ["source_script", "target_link", "target_script", "flags", "paramters", "data"], [
            enString_Elem(source_script),
            target_link,
            enString_Elem(target_script),
            enInteger_ElemBitfield(flags),
            enList_Elem(parameters),
            enString_Elem(data)
            ]);
    #endif
    if (!target_link) target_link = ENLEP_LINK_MESSAGE_SCOPE;
    llMessageLinked(target_link, flags, llDumpList2String([source_script, target_script] + parameters, "\n"), data);
}

integer enLEP_Process(
    integer source_link,
    integer flags,
    string s,
    string k
)
{
    #if defined ENLEP_TRACE || defined ENLEP_PROCESS_TRACE
        enLog_TraceParams("enLEP_Process", ["source_link", "flags", "s", "k"], [
            source_link,
            flags,
            enString_Elem(s),
            enString_Elem(k)
            ]);
    #endif
    list parameters = llParseStringKeepNulls(s, ["\n"], []);
    if (llGetListLength(parameters) < 2) return 0; // not a valid LEP message
    if (source_link == llGetLinkNumber() && llList2String(parameters, 0) == llGetScriptName()) return 1; // discard message loopback even
    #if defined ENLEP_ALLOWED_SOURCE_SCRIPTS
        // filter out messages that don't match the allowed source script list
        if (llListFindList(ENLEP_ALLOWED_SOURCE_SCRIPTS, [llList2String(parameters, 0)]) == -1) return 1; // discard message, not sent from an allowed source script
    #endif
    list allowed_targets = ["", llGetScriptName()]; // allow messages targeted to "" (all) and this script only
    #if defined ENLEP_ALLOWED_TARGET_SCRIPTS
        allowed_targets += ENLEP_ALLOWED_TARGET_SCRIPTS; // allow messages targeted to any value in the macro ENLEP_ALLOWED_TARGET_SCRIPTS
    #endif
    #ifndef ENLEP_ALLOW_ALL_TARGET_SCRIPTS
        if (llListFindList(allowed_targets, [llList2String(parameters, 1)]) == -1)
        {
            if (llSubStringIndex(llGetScriptName(), llList2String(parameters, 1)) == -1) return 0; // discard message, not targeted to us
        }
    #endif
    #if defined ENLEP_MESSAGE && defined ENLEP_MESSAGE_TRACE
        enLog_TraceParams("enlep_message", ["source_link", "source_script", "target_script", "flags", "parameters", "data"], [
            source_link,
            enString_Elem(llList2String(parameters, 0)),
            enString_Elem(llList2String(parameters, 1)),
            enInteger_ElemBitfield(flags),
            enList_Elem(llDeleteSubList(parameters, 0, 1)),
            enString_Elem(k)
        ]);
    #endif
    #if defined ENLEP_MESSAGE
        enlep_message(
            source_link,
            llList2String(parameters, 0),
            llList2String(parameters, 1),
            flags,
            llDeleteSubList(parameters, 0, 1),
            k
            );
    #endif
    return 1;
}
