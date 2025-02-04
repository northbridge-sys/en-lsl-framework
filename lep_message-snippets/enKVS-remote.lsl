/*
    enKVS-remote.lsl
    LEP Processor Snippet
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

    TBD
*/

if (llList2String(params, 0) == "enKVS-remote" && status & ENLEP_TYPE_REQUEST)
{
	string kvs_check_op = llList2String(params, 1);
	if (kvs_check_op == "write" || kvs_check_op == "read")
	{ // check name for write or read operation first
		if (!enKVS_Exists(llList2String(params, 1)))
		{ // invalid name
			enLEP_Send(
				source_link,
				source_script,
				ENLEP_TYPE_RESPONSE | ENLEP_STATUS_ERROR,
				params + ["undefined"],
				data
			);
			return;
		}
	}
	if (kvs_check_op == "write")
	{ // writing an enKVS pair
		enKVS_Write(llList2String(params, 1), data); // this should never fail
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			params,
			data
		);
		return;
	}
	if (kvs_check_op == "read")
	{ // reading an enKVS pair
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			params,
			enKVS_Read(llList2String(params, 1))
		);
		return;
	}
	if (kvs_check_op == "list")
	{ // return list of KVS pairs
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			params,
			llDumpList2String(ENKVS_NAMES, "\n")
		);
	}
	return;
}
