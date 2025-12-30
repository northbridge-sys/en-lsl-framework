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
- anything related to parameters not included in the message (for example, enLEP sends an int parameter as the link_message integer; this is not incorporated)
*/

/*!
Returns a JSON object with an HMAC-signed message:
{
    "enSign": {
        "a": algorithm,
        "t": llGetTimestamp(),
        "p": llGetKey(),
        "n": llGetScriptName(),
        "j": any JSON object,
        "h": HMAC hash of llGetTimestamp() + (string)llGetKey() + llGetScriptName() + key_identifier + json_object, using shared_key
    }
}
enSign only signs the timestamp and a UUID for simplicity, so that the signature can be dropped directly into an encapsulated message as an independent signature.
@param string json_object Any JSON object.
@param string shared_key HMAC shared key. Can be any string.
@return string JSON object with portable signature data.
*/
string enSign_HMAC(
    string json_object,
    string shared_key,
    string algorithm
)
{
    if (llListFindList(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], [algorithm]) == -1)
    {
        enLog_Error("Invalid enSign algorithm: " + algorithm);
        return "";
    }
    string timestamp = llGetTimestamp();
    return "{\"a\":\"" + algorithm + "\",\"t\":\"" + timestamp + "\",\"p\":\"" + (string)llGetKey() + "\",\"n\":\"" + enString_EscapeQuotes(llGetScriptName()) + "\",\"j\":" + json_object + ",\"h\":\"" + llHMAC(shared_key, timestamp + (string)llGetKey() + llGetScriptName() + json_object, algorithm) + "\"}";
}

/*!
Returns a JSON object with an RSA-signed message:
{
    "enSign": {
        "a": "sha512", (there is no performance or memory penalty for sha512 over other options, so this isn't selectable)
        "t": llGetTimestamp(),
        "p": llGetKey(),
        "n": llGetScriptName(),
        "j": any JSON object,
        "s": RSA signature of llGetTimestamp() + (string)llGetKey() + llGetScriptName() + key_identifier + json_object, using private_key
    }
}
@param string json_object Any JSON object.
@param string private_key RSA private key. You may omit newlines, but not the header/footer.
@return string JSON object with portable signed message.
*/
string enSign_RSA(
    string json_object,
    string private_key
)
{
    string timestamp = llGetTimestamp();
    return "{\"a\":\"sha512\",\"t\":\"" + timestamp + "\",\"p\":\"" + (string)llGetKey() + "\",\"n\":\"" + enString_EscapeQuotes(llGetScriptName()) + "\",\"j\":" + json_object + ",\"s\":\"" + llSignRSA(private_key, timestamp + (string)llGetKey() + llGetScriptName() + json_object, "sha512") + "\"}";
}

/*!
Validates a JSON object as a valid enSign signature created using enSign_RSA() and returns various information verified by the signature.
@param string ensign_object JSON object created by enSign_RSA().
@param string public_key RSA public key.
@param integer expiry Seconds to allow for timestamp fluctuation.
@return list [prim_uuid, script_name, key_identifier, json_object]
*/
list enSign_ExtractAll(
    string ensign_object,
    integer expiry
)
{
    string t = llJsonGetValue(ensign_object, ["t"]);
    string p = llJsonGetValue(ensign_object, ["p"]);
    string n = llJsonGetValue(ensign_object, ["n"]);
    string j = llJsonGetValue(ensign_object, ["j"]);
    string h = llJsonGetValue(ensign_object, ["h"]);
    string s = llJsonGetValue(ensign_object, ["s"]);
    string a = llJsonGetValue(ensign_object, ["a"]);

    integer expired = llAbs(enDate_TimestampDiffToSeconds(t, llGetTimestamp())) > expiry; // expired

    // iterate through all known keys until we find one that works
    integer valid;
    integer index;
    integer max = llGetListLength(_ENSIGN_KEYS) / 2;
    string use_key;
    do
    {
        use_key = llList2String(_ENSIGN_KEYS, index * 2 + 1);
        if (use_key != "")
        {
            // if "s" is set, we are using RSA signing; otherwise, presume "h" is set for HMAC signing
            // only attempt llVerifyRSA() if it looks like we're using an RSA public key, since it's slow
            if (s != JSON_INVALID && llGetSubString(use_key, 0, 0) == "-") valid = llVerifyRSA(use_key, t + p + n + j, s, a);
            else valid = (llHMAC(use_key, t + p + n + j, a) == h);
        }
    }
    while (!valid && ++index < max);

    if (expired || !valid)
    {
        enLog_Warn("Received " + enString_If(expired, "expired", "unknown/invalid") + " enSign message from " + enPrim_Elem(p) + ": " + ensign_object);
        return [];
    }

    return [p, n, llList2String(_ENSIGN_KEYS, (index - 1) * 2), j]; // prim_uuid, script_name, key_identifier, json_object
}

/*!
Enrolls a key.
For HMAC keys, use the single shared key.
For RSA key pairs, use the RSA PUBLIC key.
@param string key_identifier The identifer for this key sent to enSign_HMAC() or enSign_RSA() to sign messages.
@param string key_data The HMAC shared or RSA public key.
@return integer TRUE for enrolled, FALSE if already enrolled (the key must be removed using enSign_Unenroll() first)
*/
integer enSign_Enroll(
    string key_identifier,
    string key_data
)
{
    if (llListFindList(llList2ListSlice(_ENSIGN_KEYS, 0, -1, 2, 0), [key_identifier]) != -1)
    {
        enLog_Warn("enSign_Enroll attempted on existing key pair: " + key_identifier);
        return FALSE;
    }
    _ENSIGN_KEYS += [key_identifier, key_data];
    return TRUE;
}

/*!
Unenrolls a key.
@param string key_identifier The identifer for this key.
@return integer TRUE for unenrolled, FALSE if not currently enrolled.
*/
integer enSign_Unenroll(
    string key_identifier
)
{
    integer index = llListFindList(llList2ListSlice(_ENSIGN_KEYS, 0, -1, 2, 0), [key_identifier]);
    if (index == -1) return FALSE;
    _ENSIGN_KEYS = llDeleteSubList(_ENSIGN_KEYS, index * 2, index * 2 + 1);
    return TRUE;
}

/*!
Gets an enrolled key.
@param string key_identifier The identifer for this key.
@return string HMAC shared or RSA public key. WARNING: It's possible to leak HMAC shared keys if you are exposing RSA public keys and also use HMAC!
*/
string enSign_GetKey(
    string key_identifier
)
{
    integer index = llListFindList(llList2ListSlice(_ENSIGN_KEYS, 0, -1, 2, 0), [key_identifier]);
    if (index == -1) return "";
    return llList2String(_ENSIGN_KEYS, index * 2 + 1);
}
