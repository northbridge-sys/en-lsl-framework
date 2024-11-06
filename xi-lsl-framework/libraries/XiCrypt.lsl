/*
    XiCrypt.lsl
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
    │ DISCLAIMER                                                                   │
    └──────────────────────────────────────────────────────────────────────────────┘

    READ THE ABOVE LICENSE TERMS CAREFULLY.  BuildTronics takes NO RESPONSIBILTY FOR
    THE ACCURACY OR SECURITY OF THESE FUNCTIONS.  I am not a cryptography expert, I
    just know how to hash passwords and know how to evaluate encryption methods
    as a paranoid layperson.

    These implementations have been copied from public sources and may contain bugs,
    backdoors, or memory leaks.  If your preprocessor is configured properly, this
    file should be entirely omitted from the preprocessed script unless you
    specifically call these functions.  By doing so, you agree to the above terms
    and understand that these operations are EXPERIMENTAL ONLY and should not be
    relied upon for any secure communications, except insofar as Second Life does
    not actually have a way to securely communicate without using external servers.

    Keep in mind that these functions provide encryption only.  If your messages
    also need to be signed, use the signing feature provided in XiIMP.

    ╒══════════════════════════════════════════════════════════════════════════════╕
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

	TBD
*/

// ==
// == preprocessor options
// ==

#ifdef XI_ALL_ENABLE_XILOG_TRACE
#define XICRYPT_ENABLE_XILOG_TRACE
#endif

// ==
// == functions
// ==

// TODO
