/*
enList.lsl
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

#if defined EN_TRACE_LIBRARIES
    #define ENLIST_TRACE
#endif

#define enList_FindStrideByElem( list_haystack, stride_length, index_in_stride, string_needle ) \
    llListFindList( llList2ListSlice( list_haystack, 0, -1, stride_length, index_in_stride ), [ string_needle ] )

    )
{
    integer i = llListFindList(llList2ListSlice(haystack, 0, -1, stride, index), needle);
    if (~i) return llDeleteSubList(haystack, i * stride, (i + 1) * stride - 1);  // != -1; delete existing stride because we'll be re-adding it
    return haystack;
}
