/*
    kvp.lsl
    IMP Processor Snippet
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
    │ INSTRUCTIONS                                                                 │
    └──────────────────────────────────────────────────────────────────────────────┘

    TBD
*/

if (status == "" && llList2String(params, 0) == "kvp")
{
	string kvp_check_op = llList2String(params, 1);
	if (kvp_check_op == "list")
	{ // return list of KVP pairs
		XiIMP_Send("", source, 0, "ok", ident, params, llDumpList2String(XIKVP_NAMES, "\n"));
	}
	if (kvp_check_op == "set" || kvp_check_op == "get")
	{ // check name for set or get operation first
		if (!XiKVP_EXists(llList2String(params, 1)))
		{ // invalid name
			XiIMP_Send("", source, 0, "err:undefined", ident, params, data);
			return;
		}
	}
	if (kvp_check_op == "set")
	{ // setting an XiKVP pair
		if (!XiKVP_Set(llList2String(params, 1), data))
		{ // write failed due to protect
			XiIMP_Send("", source, 0, "err:readonly", ident, params, data);
			return;
		}
		XiIMP_Send("", source, 0, "ok", ident, params, data);
		return;
	}
	if (kvp_check_op == "get")
	{ // getting an XiKVP pair
		XiIMP_Send("", source, 0, "ok", ident, params, XiKVP_Get(llList2String(params, 1)));
	}
}
