/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-framework

Used to sign and verify data using llSignRSA() and llVerifyRSA().

enSign signatures incorporate the following:
- any string
- source script name
- source prim UUID
- message timestamp
- private key

enSign signatures DO NOT enforce the following:
- message originality (use one-time tokens and/or use a very strict expiry time to guard against replay attacks)
- message privacy (RSA signing does not obscure the original message)
- authenticity of script name or prim UUID sent in-band (both self-reported)
*/

/*!
Returns a JSON object with a signed message:
{
    "enSign": {
        "a": "sha512", (can be other algorithms, but there is no performance or memory penalty for sha512, so it is currently used)
        "t": llGetTimestamp(),
        "p": llGetKey(),
        "n": llGetScriptName(),
        "m": message,
        "s": RSA signature of llGetTimestamp() + (string)llGetKey() + llGetScriptName() + message, using private_key
    }
}
enSign only signs the timestamp and a UUID for simplicity, so that the signature can be dropped directly into an encapsulated message as an independent signature.
@param string message Any string.
@param string private_key RSA private key. You may omit newlines, but not the header/footer.
@return string JSON object with portable signature data.
*/
string enSign_Sign(
    string message,
    string private_key
)
{
    string timestamp = llGetTimestamp();
    return "{\"a\":\"sha512\",\"t\":\"" + timestamp + "\",\"p\":\"" + (string)llGetKey() + "\",\"n\":\"" + enString_EscapeQuotes(llGetScriptName()) + "\",\"m\":\"" + enString_EscapeQuotes(message) + "\",\"s\":\"" + llSignRSA(private_key, timestamp + (string)llGetKey() + llGetScriptName() + message, "sha512") + "\"}";
}

string enSign_Sign

/*!
Validates a JSON object as a valid enSign signature created using enSign_Sign() and returns various information verified by the signature.
@param string ensign_object JSON object created by enSign_Sign().
@param string public_key RSA public key.
@param integer expiry Seconds to allow for timestamp fluctuation.
@return list [prim_uuid, script_name, message]
*/
list enSign_ExtractAll(
    string ensign_object,
    string public_key,
    integer expiry
)
{
    string t = llJsonGetValue(ensign_object, ["t"]);
    string p = llJsonGetValue(ensign_object, ["p"]);
    string n = llJsonGetValue(ensign_object, ["n"]);
    string m = llJsonGetValue(ensign_object, ["m"]);
    string s = llJsonGetValue(ensign_object, ["s"]);
    string a = llJsonGetValue(ensign_object, ["a"]);

    integer e = llAbs(enDate_TimestampDiffToSeconds(t, llGetTimestamp())) > expiry; // expired
    integer v = llVerifyRSA(public_key, t + p + n + m, s, a);
    if (e || !v)
    {
        enLog_Warn("Received " + enString_If(e, "expired", "invalid") + " enSign signature from " + enPrim_Elem(p) + ": " + ensign_object);
        return [];
    }

    return [p, n, m]; // prim_uuid, script_name, message
}
