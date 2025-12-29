/*
enDate
Copyright (C) 2025  Northbridge Business Systems
https://docs.northbridgesys.com/en-framework
*/

#define FLAG_ENDATE_12_HOUR 0x1
#define FLAG_ENDATE_12_HOUR_M 0x2
#define FLAG_ENDATE_PAD_ZEROES 0x4
#define FLAG_ENDATE_DMY 0x8
#define FLAG_ENDATE_MDY 0x10
#define FLAG_ENDATE_TEXT 0x20
#define FLAG_ENDATE_TEXT_MONTH_SHORT 0x40
#define FLAG_ENDATE_TEXT_MONTH_SHORT_DOT 0x80
#define FLAG_ENDATE_TEXT_DAY_ORDINAL 0x100
#define FLAG_ENDATE_TEXT_DAY_OF 0x200

#if defined TRACE_EN
    #define TRACE_ENDATE
#endif

/*!
Converts current environment time (sun position) at script's location to a percentage of day starting at midnight.
NOTE: this shouldn't be used in attachments maybe because of llGetPos?
@return float Daypart of 24 hours starting at midnight (0.0-1.0).
*/
#define enDate_EnvironmentToDaypart_Here() \
    enDate_EnvironmentToDaypart(llGetPos())

/*!
Converts current environment time (sun position) at specified location to an HMS list.
Environment sun positions are typically fast enough that subsecond precision is not accurate.
@param vector p Region-scope position.
@return list [h, m, s].
*/
#define enDate_EnvironmentToHMS(p) \
    enDate_DaypartToHMS(enDate_EnvironmentToDaypart(p))

/*!
Converts current environment time (sun position) at script's location to a percentage of day starting at midnight.
Environment sun positions are typically fast enough that subsecond precision is not accurate.
NOTE: this shouldn't be used in attachments maybe because of llGetPos?
@return list [h, m, s].
*/
#define enDate_EnvironmentToHMS_Here() \
    enDate_EnvironmentToHMS(llGetPos())

/*!
Gets short textual representation of specified month, limited to 3 characters.
Can be called in multiple places with minimal memory impact.
@param integer month Month of year (1-12).
@return string Month of year as 3-character text.
*/
#define enDate_MToPrettyShort(month) \
    llDeleteSubString(enDate_MToPretty(month), 3, -1)

/*!
Gets the current datetime in enDate's millisec format.
@return integer Millisecs.
*/
#define enDate_NowToMillisec() \
    enDate_TimestampToMillisec(llGetTimestamp())

/*!
Gets current time as ISO 8601 timestamp.
Alias of llGetTimestamp().
@return string ISO 8601 timestamp.
*/
#define enDate_NowToTimestamp() \
    llGetTimestamp()

/*!
Gets current time as Unix timestamp.
Alias of llGetUnixTime().
@return integer Unix time.
*/
#define enDate_NowToUnix() \
    llGetUnixTime()

/*!
Gets current time as enDate list.
For subsecond precision, use enDate_NowToYMDHMSU().
@return list [Y, M, D, h, m, s].
*/
#define enDate_NowToYMDHMS() \
    enDate_UnixToYMDHMS(llGetUnixTime())

/*!
Gets current time as enDate list, with subsecond precision.
For integer precision, use enDate_NowToYMDHMS().
@return list [Y, M, D, h, m, s, u].
*/
#define enDate_NowToYMDHMSU() \
    enDate_TimestampToYMDHMSU(llGetTimestamp())

/*!
Get difference between two timestamps in integer seconds, discarding microseconds.
This is imprecise because second 0.999999 is considered 1 second away from 1.000000, but 1.000000 is considered 0 seconds away from 1.999999.
Probably faster and more efficient than enDate_TimestampDiffToSecondsPrecise(). TODO: test this
@param string ts_a First timestamp.
@param string ts_b Second timestamp.
@return integer Difference in seconds.
*/
#define enDate_TimestampDiffToSeconds(ts_a, ts_b) \
    (enDate_TimestampToUnix(ts_a) - enDate_TimestampToUnix(ts_b))

/*!
Get difference between two timestamps in float seconds.
@param string ts_a First timestamp.
@param string ts_b Second timestamp.
@return float Difference in seconds, with subseconds.
*/
#define enDate_TimestampDiffToSecondsPrecise(ts_a, ts_b) \
    (enDate_TimestampDiffToSeconds(ts_a, ts_b) + (llList2Integer(enDate_TimestampToYMDHMSU(ts_a), 6) - llList2Integer(enDate_TimestampToYMDHMSU(ts_b), 6)) * 0.000001)

/*!
Converts ISO 8601 timestamp to pretty datetime.
@param string t ISO 8601 timestamp. See llGetTimestamp().
@param integer flags FLAG_ENDATE_* flags.
@return string Pretty datetime.
*/
#define enDate_TimestampToPretty(t, flags) \
    enDate_YMDHMSUToPretty(enDate_TimestampToYMDHMSU(t), flags)

/*!
Converts ISO 8601 timestamp from llGetTimestamp to Unix timestamp from llGetUnixTime.
No validation is performed. NO subsecond precision.
@param string t ISO 8601 timestamp. See llGetTimestamp().
@return integer Unix time.
*/
#define enDate_TimestampToUnix(t) \
    enDate_YMDHMSToUnix(enDate_TimestampToYMDHMSU(t))

/*!
Converts Unix time to pretty datetime.
@param string Unix time. See llGetUnixTime().
@param integer flags FLAG_ENDATE_* flags.
@return string Pretty datetime.
*/
#define enDate_UnixToPretty(u, flags) \
    enDate_YMDHMSToPretty(enDate_UnixToYMDHMS(u), flags)

/*!
Converts Unix time to ISO 8601 timestamp.
@param string Unix time. See llGetUnixTime().
@return string ISO 8601 timestamp.
*/
#define enDate_UnixToTimestamp(u) \
    enDate_YMDHMSUToTimestamp(enDate_UnixToYMDHMS(u))

/*!
Gets full textual representation of specified month.
Avoid calling this in multiple places in the same script, because the entire month list will be stored multiple times in the bytecode! Use enDate_MToPretty() instead.
@param integer month Month of year (1-12).
@return string Month of year as full text.
*/
#define _enDate_MToPretty(month) \
    llList2String(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], month - 1)

/*!
Gets short textual representation of specified month, limited to 3 characters.
Avoid calling this in multiple places in the same script, because the entire month list will be stored multiple times in the bytecode! Use enDate_MToPrettyShort() instead.
@param integer month Month of year (1-12).
@return string Month of year as 3-character text.
*/
#define _enDate_MToPrettyShort(month) \
    llDeleteSubString(_enDate_MToPretty(month), 3, -1)
