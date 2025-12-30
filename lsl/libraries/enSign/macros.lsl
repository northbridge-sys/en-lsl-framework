/*
En LSL Framework
Copyright (C) 2024-25  Northbridge Business Systems
https://docs.northbridgesys.com/en-framework
*/

/*!
Validates a JSON object as a valid enSign signature created using enSign_RSA() and returns the message.
@param string ensign_object JSON object created by enSign_RSA().
@param string public_key RSA public key.
@param integer expiry Seconds to allow for timestamp fluctuation.
@return string Message, or "" if invalid/expired.
*/
#define enSign_ExtractMessage(ensign_object, public_key, expiry) \
    llList2String(enSign_ExtractAll(ensign_object, public_key, expiry), 3)

/*!
Validates a JSON object as a valid enSign signature created using enSign_Signature() and returns a boolean.
@param string ensign_object JSON object created by enSign_Signature().
@param string public_key RSA public key.
@param integer expiry Seconds to allow for timestamp fluctuation.
@return integer Boolean; TRUE for valid and unexpired, FALSE for invalid or expired.
*/
#define enSign_IsValid(ensign_object, public_key, expiry) \
    (enSign_ExtractAll(ensign_object, public_key, expiry) != [])

list _ENSIGN_KEYS;
