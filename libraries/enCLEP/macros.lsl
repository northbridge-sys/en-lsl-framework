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

string _ENCLEP_SERVICE;

list _ENCLEP_DOMAINS; // domain, flags, channel, handle
#define _ENCLEP_DOMAINS_STRIDE 4

#if defined ENCLEP_ENABLE_PTP
    list ENCLEP_PTP; // transfer_key, prim ("" for inbound), domain, message_buffer
    #define ENCLEP_PTP_STRIDE 4
#endif

#if defined ENCLEP_ENABLE_LEP
    string ENCLEP_LEP_SOURCE_PRIM = NULL_KEY;
    string ENCLEP_LEP_SOURCE_DOMAIN;
#endif

// cannot log this function because it is used by enLog
#define enCLEP_GetService() _ENCLEP_SERVICE

/*
To define the service string, call enCLEP_SetService( service ). This will be used twice:
    - Appended to the start of all chat messages in plain text for filtering.
    - Hashed against the domain to generate the integer channel for llListen.
*/
// not going to bother logging this function because service should always be hard-coded, no reason to debug this
#define enCLEP_SetService(s) \
    (_ENCLEP_SERVICE = s)
