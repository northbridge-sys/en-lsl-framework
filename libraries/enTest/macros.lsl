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

#define INTEGER 0
#define FLOAT 1
#define VECTOR 2
#define ROTATION 3
#define STRING 4
#define KEY 5
#define LIST 6

#define ENTEST_EQUAL 0
#define ENTEST_NOT_EQUAL 1
#define ENTEST_GREATER 2
#define ENTEST_LESS 3

// 0xFFFFFFFF is 1 byte and 1 operation more efficient than -1
#define ENTEST_VM_LSO 0xFFFFFFFF
#define ENTEST_VM_MONO 1

#ifndef ENTEST_PRECISION_FLOAT
    // default exact precision for floats - adjust this in script if desired
    #define ENTEST_PRECISION_FLOAT 0.0
#endif

#ifndef ENTEST_PRECISION_VECTOR
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST_PRECISION_VECTOR 0.0
#endif

#ifndef ENTEST_PRECISION_ROTATION
    // default exact precision for vectors - adjust this in script if desired
    #define ENTEST_PRECISION_ROTATION 0.0
#endif

#if defined EN_TRACE_LIBRARIES
    #define ENTEST_TRACE
#endif

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
