/*
enKVS_Remote.lsl
enlep_message Snippet
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

if (llList2String(parameters, 0) == "enKVS-remote" && flags & ENLEP_TYPE_REQUEST)
{
	string kvs_op = llList2String(parameters, 1);
	list kvs_pair = enList_FromString(llList2String(parameters, 2));
	if (kvs_op == "write" || kvs_op == "read")
	{ // check name for write or read operation first
		if (!enKVS_Exists(kvs_pair))
		{ // invalid name
			enLEP_Send(
				source_link,
				source_script,
				ENLEP_TYPE_RESPONSE | ENLEP_STATUS_ERROR,
				parameters + ["undefined"],
				data
			);
			return;
		}
	}
	if (kvs_op == "write")
	{ // writing an enKVS pair
		enKVS_Write(kvs_pair, data); // this should never fail
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			parameters,
			data
		);
		return;
	}
	if (kvs_op == "read")
	{ // reading an enKVS pair
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			parameters,
			enKVS_Read(kvs_pair)
		);
		return;
	}
	if (kvs_op == "list")
	{ // return list of KVS pairs
		enLEP_Send(
			source_link,
			source_script,
			ENLEP_TYPE_RESPONSE,
			parameters,
			enList_ToString(_ENKVS_NAMES)
		);
	}
	return;
}
