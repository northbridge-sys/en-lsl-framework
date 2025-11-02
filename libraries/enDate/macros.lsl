/*
enDate
Copyright (C) 2025  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework
*/

#define FLAG_ENDATE_12_HOUR 0x1
#define FLAG_ENDATE_PAD_ZEROES 0x2

#if defined TRACE_EN
    #define TRACE_ENDATE
#endif

#define enDate_MSNow() enDate_MS(llGetTimestamp())

#define enDate_Weekday(year, month, day) \
    llList2String(["Friday", "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"], (year + (year >> 2) - ((month < 3) & !(year & 3)) + day + (integer)llGetSubString("_033614625035", month, month)) % 7)

#define enDate_Month(month) \
    llList2String(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], month - 1)
