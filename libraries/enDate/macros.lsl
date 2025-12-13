/*
enDate
Copyright (C) 2025  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework
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

#define enDate_NowToMillisec() enDate_TimestampToMillisec(llGetTimestamp())

/*!
Converts current environment time (sun position) at specified location to an HMS list.
Environment sun positions are typically fast enough that subsecond precision is not accurate.
@param vector p Region-scope position.
*/
#define enDate_EnvironmentToHMS(p) \
    enDate_ProportionToHMS(enDate_EnvironmentToProportion(p))

/*!
Converts current environment time (sun position) at script's location to a percentage of day starting at midnight.
Environment sun positions are typically fast enough that subsecond precision is not accurate.
NOTE: this shouldn't be used in attachments maybe because of llGetPos?
*/
#define enDate_EnvironmentToHMS_Here() \
    enDate_EnvironmentToHMS(llGetPos())

/*!
Converts current environment time (sun position) at script's location to a percentage of day starting at midnight.
NOTE: this shouldn't be used in attachments maybe because of llGetPos?
*/
#define enDate_EnvironmentToProportion_Here() \
    enDate_EnvironmentToProportion(llGetPos())

/*!
Gets full textual representation of specified weekday using separate year, month, and day integers.
For YMD list input, see enDate_YMDToWeekday().
@param integer y Year.
@param integer m Month.
@param integer d Day.

/*!
Gets full textual representation of specified month.
Avoid calling this in multiple places in the same script, because the entire month list will be stored multiple times in the bytecode! Use enDate_Month() instead.
@param integer month Month of year (1-12).
*/
#define _enDate_Month(month) \
    llList2String(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], month - 1)

/*!
Gets short textual representation of specified month, limited to 3 characters.
Can be called in multiple places with minimal memory impact.
@param integer month Month of year (1-12).
*/
#define enDate_Month_Short(month) \
    llDeleteSubString(enDate_Month(month), 3, -1)

/*!
Gets short textual representation of specified month, limited to 3 characters.
Avoid calling this in multiple places in the same script, because the entire month list will be stored multiple times in the bytecode! Use enDate_Month_Short() instead.
@param integer month Month of year (1-12).
*/
#define _enDate_Month_Short(month) \
    llDeleteSubString(_enDate_Month(month), 3, -1)

/*!
Converts ISO 8601 timestamp from llGetTimestamp to Unix timestamp from llGetUnixTime.
No validation is performed. NO subsecond precision.
@param integer t ISO 8601 timestamp. See llGetTimestamp().
*/
#define enDate_TimestampToUnix(t) \
    enDate_ListToUnix(enDate_TimestampToList(t))

/*!
Gets current time as enDate list.
For subsecond precision, use enDate_NowToYMDHMSU().
*/
#define enDate_NowToYMDHMS() \
    enDate_UnixToYMDHMS(llGetUnixTime())

/*!
Gets current time as enDate list, with subsecond precision.
For integer precision, use enDate_NowToYMDHMS().
*/
#define enDate_NowToYMDHMSU() \
    enDate_TimestampToYMDHMSU(llGetTimestamp())

/*!
Gets current time as Unix timestamp.
Alias of llGetUnixTime().
*/
#define enDate_NowToUnix() \
    llGetUnixTime()

/*!
Gets current time as ISO 8601 timestamp.
Alias of llGetTimestamp().
*/
#define enDate_NowToTimestamp() \
    llGetTimestamp()
