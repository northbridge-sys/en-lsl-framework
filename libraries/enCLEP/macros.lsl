/*
enCLEP.lsl
Library Macros
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

// NOTE: do not use ENCLEP_LISTEN_OWNERONLY across region borders!
#define ENCLEP_LISTEN_OWNERONLY 0x1
#define ENCLEP_LISTEN_REMOVE 0x80000000

#ifndef ENCLEP_RESERVE_LISTENS
    #define ENCLEP_RESERVE_LISTENS 0
#endif

#ifndef ENCLEP_PTP_SIZE
    // note that this value is set to the maximum number of UTF-8 characters that can be sent via llRegionSayTo
    // if you are positive you will ALWAYS have ASCII-7 characters, this can be raised to 1024 for better performance and lower memory usage
    #define ENCLEP_PTP_SIZE 512
#endif

#if defined EN_TRACE_LIBRARIES
    #define ENCLEP_TRACE
#endif

// used by enCLEP_DialogListen()
integer _ENCLEP_DIALOG_LSN;

list _ENCLEP_DOMAINS; // service, domain, flags, handle
#define _ENCLEP_DOMAINS_STRIDE 4

#if defined ENCLEP_ENABLE_PTP
    list ENCLEP_PTP; // transfer_key, prim ("" for inbound), domain, message_buffer
    #define ENCLEP_PTP_STRIDE 4
#endif

#if defined ENCLEP_ENABLE && defined ENLEP_MESSAGE
    // enLEP via enCLEP is enabled automatically
    string ENCLEP_SOURCE_PRIM = NULL_KEY;
    string ENCLEP_SOURCE_SERVICE;
    string ENCLEP_SOURCE_DOMAIN;
#endif

/*
enCLEP_Channel is the hashing algorithm that converts DOMAINS and SERVICES together into a channel number.
This is used to enforce channel separation on different domains. This reduces script execution for llRegionSay calls.
enCLEP_Channel can also be used directly in llListen for a relatively safe llDialog channel.
enCLEP channels are always negative, so we just set the 0x80000000 bit to force a negative integer of some kind.
This also avoids PUBLIC_CHANNEL (0x0 -> 0x80000000) and DEBUG_CHANNEL (0x7FFFFFFF -> 0xFFFFFFFF) automatically.
*/
#define enCLEP_Channel(service, domain) \
    (llHash(service + domain) | INTEGER_NEGATIVE)

#define enCLEP_Reserved() \
    (!!_ENCLEP_DIALOG_LSN + ENCLEP_RESERVE_LISTENS)

/*
enCLEP_DialogChannel can be used to get the channel we are listing to if enCLEP_DialogListen was called.
*/
#define enCLEP_DialogChannel() \
    enCLEP_Channel((string)llGetKey(), llGetScriptName())
