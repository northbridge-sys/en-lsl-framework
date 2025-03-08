/*
enTest.lsl
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

//  returns 1 for Mono (ENTEST_VM_MONO), -1 for LSO (ENTEST_VM_LSO)
//  relies on LSO returning strcmp instead of a boolean result
//  written before Luau was available to test; if you're here to rewrite this under Luau, good job living that long
//  2025-03-05: wtf it's already on beta grid??? TODO: figure out how to do this on Luau
#define enTest_GetVM() \
    ("" != "x")

#define enTest_AssertFatal(at, av, m, bt, bv) enTest_AssertAt(FATAL, __LINE__, at, av, m, bt, bv)
#define enTest_AssertError(at, av, m, bt, bv) enTest_AssertAt(ERROR, __LINE__, at, av, m, bt, bv)
#define enTest_AssertWarn(at, av, m, bt, bv) enTest_AssertAt(WARN, __LINE__, at, av, m, bt, bv)
#define enTest_AssertInfo(at, av, m, bt, bv) enTest_AssertAt(INFO, __LINE__, at, av, m, bt, bv)
#define enTest_AssertDebug(at, av, m, bt, bv) enTest_AssertAt(DEBUG, __LINE__, at, av, m, bt, bv)
#define enTest_AssertTrace(at, av, m, bt, bv) enTest_AssertAt(TRACE, __LINE__, at, av, m, bt, bv)
