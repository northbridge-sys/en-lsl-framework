/*
enDate
Copyright (C) 2025  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework
*/

/*!
Adds a number of milliseconds to an enDate millisec integer to safely wrap milliseconds at the ends of a month.
@param integer ms Millisec. See enDate_NowToMillisec() or enDate_TimestampToMillisec().
@param integer add Millisec to add. Limited to +/- 1530167295, otherwise you will silently overflow.
@return integer New millisec.
*/
integer enDate_AddMillisec(
    integer ms,
    integer add
)
{
    // check if adding takes us into the "dead zone" of 617316352 to 2147483647
    if ( ms + add > 617316352 ) return ( ms + add ) + 2764800000 * ( -1 * ( add > 0 ) ); // if we are adding +, subtract the entire range; otherwise, add it
    return ms + add; // no adjustment needed
}

/*!
Converts current environment time (sun position) at specified location to a proportion.
@param vector p Region-scope position.
@return float Proportion of 24 hours starting at midnight (0.0-1.0).
*/
float enDate_EnvironmentToProportion(
    vector p
)
{
    list e = llGetEnvironment(p, [ENVIRONMENT_DAYINFO]);
    return (float)llList2String(e, 2) / (float)llList2String(e, 0);
}

/*!
Converts HMS list to pretty string.
@param list hms [h, m, s]. Do not include [Y, M, D].
@param integer flags FLAG_ENDATE_* flags.
@return string Pretty string.
*/
//  converts an hour,minutes,seconds list to a prettified string
string enDate_HMSToPretty(
    list hms,
    integer flags
)
{
    string xm;
    if (flags & (FLAG_ENDATE_12_HOUR | FLAG_ENDATE_12_HOUR_M))
    {
        xm = "A";
        integer h = (integer)llList2String(hms, 0);
        if (h == 0) h = 12;
        else
        {
            if (h >= 12) xm = "P"; // if hour 12-23, P
            if (h > 12) h -= 12; // if hour 13-23, go back to 1-11
        }
        if (flags & FLAG_ENDATE_12_HOUR_M) xm += "M";
        hms = llListReplaceList(hms, [(integer)llList2String(hms, 0) - 12], 0, 0);
    }
    if (flags & FLAG_ENDATE_PAD_ZEROES)
    {
        while (llStringLength(llList2String(hms, 0)) < 2) hms = llListReplaceList(hms, ["0" + llList2String(hms, 0)], 0, 0);
        while (llStringLength(llList2String(hms, 1)) < 2) hms = llListReplaceList(hms, ["0" + llList2String(hms, 1)], 1, 1);
        while (llStringLength(llList2String(hms, 2)) < 2) hms = llListReplaceList(hms, ["0" + llList2String(hms, 2)], 2, 2); // TODO: MAKE LESS BAD
    }
    return llList2String(hms, 0) + ":" + llList2String(hms, 1) + ":" + llList2String(hms, 2) + xm;
}

/*!
Gets number of days in a specific month from year and month as integers.
@param integer y Year.
@param integer m Month.
@return integer Number of days in specified month.
*/
integer enDate_IntegersToDays(
    integer y,
    integer m
)
{
    if (m == 4 || m == 6 || m == 9 || m == 11) return 30;
    else if (m == 2)
    {
        if (y % 4 == 0) return 29;
        else return 28;
    }
    else return 31;
}

/*!
Function wrapper for _enDate_Month() macro.
Can be called in multiple places with minimal memory impact.
This is used for optimization. If you only call enDate_Month() once in the script, it's slightly more efficient to use the _enDate_Month() macro directly.
@param integer month Month of year (1-12).
@return string Full textual representation of a month.
*/
string enDate_Month(
    integer month
)
{
    return _enDate_Month(month);
}

/*!
Converts proportion of the 24 hours starting at midnight to an HMS list.
@param float p Proportion of 24 hours starting at midnight (0.0-1.0).
@return list HMS list.
*/
list enDate_ProportionToHMS(
    float p
)
{
    integer s = (integer)(86400 * p); // get total number of seconds in a day represented by this percentage
    integer h = s / 3600;
    integer m = (s / 60) % 60;
    s -= (h * 3600) + (m * 60);
    return [h, m, s];
}

/*!
Converts a timestamp into an enDate millisec, an integer that can store a month's range of milliseconds.
enDate millisecs are not immediately related or aligned to any specific timeframe. They may only be compared with each other and modified using enDate functions.
@param string timestamp ISO 8601 timestamp from llGetTimestamp().
@return integer enDate millisec.
*/
integer enDate_TimestampToMillisec(
    string timestamp // llGetTimestamp string (use enDate_NowToMillisec() for the current value)
    )
{
    return 0x80000000 + // start at -2147483648
        (integer)llGetSubString( timestamp, 8, 9 ) * 86400000 + // days * ms_per_day (-2147483648 + (31 * 86400000) = 530916352)
        (integer)llGetSubString( timestamp, 11, 12 ) * 3600000 + // hours * ms_per_hour (530916352 + (23 * 3600000) = 613716352)
        (integer)llGetSubString( timestamp, 14, 15 ) * 60000 + // minutes * ms_per_minute (613716352 + (59 * 60000) = 617256352)
        (integer)( (float)llGetSubString( timestamp, 17, -2 ) * 1000.0 ); // seconds.ms * ms_per_second (617256352 + 60000 = 617316352)
    // total range is 2764800000 ms, or ms in 31 days
}

/*!
Converts ISO 8601 timestamp from llGetTimestamp() ("YYYY-MM-DDThh:mm:ss.ff..fZ") to [Y, M, D, h, m, s, µs].
Note that the enDate list format does not require µs (microseconds); this is the only function that returns it.
No validation is performed. All Z characters are removed, then the string is split into a list using all the possible separators.
Resultant enDate list DOES HAVE subsecond precision; other methods may not have subsecond precision. Round s if needed.
@param integer t ISO 8601 timestamp. See llGetTimestamp().
@return list YMDHMSU list.
*/
list enDate_TimestampToYMDHMSU(
    string t
)
{
    // parse out all elements of timestamp
    list r = llParseStringKeepNulls(llReplaceSubString(t, "Z", "", 0), ["-", "T", ":"], []);

    // get seconds + subseconds
    float s = (float)llList2String(r, -1);

    // calculate microseconds, combine [Y, M, D, h, m] + [whole seconds, microseconds] as integers
    return enList_AllToInteger(llList2List(r, 0, 4) + [(integer)s, (integer)((s - (integer)s) * 1000000)]);
}

/*!
Converts Unix time into a full textual representation of the day of week.
Shamelessly stolen from Void Singer as CC0-licensed on LSL Wiki.
@param integer u Unix time. See llGetUnixTime().
@return string Full textual representation of the day of the week.
*/
string enDate_UnixToDOW(
    integer u
)
{
    return llList2String(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], enDate_UnixToIOW(u));
}

/*!
Converts Unix time into an index of week (IOW, 0-6 for each index of a weekday).
After considerable consideration (about 5 minutes of research), I've decided that IOWs are zero-indexed to Monday in accordance with ISO standards.
I am aware this is not the convention in the Americas, China, Japan, South Korea, and others. I don't really care.
@param integer u Unix time. See llGetUnixTime().
@return integer Index of week.
*/
integer enDate_UnixToIOW(
    integer u
)
{
    return (u % 604800 / 86400 + (u >> 31) + 4) % 7;
}

/*!
Converts Unix time to enDate list [Y, M, D, h, m, s].
DOES NOT have subsecond precision. All elements are integers.
@param integer u Unix time. See llGetUnixTime().
@return list YMDHMS list.
*/
list enDate_UnixToYMDHMS(
    integer u
)
{
    if (u / 2145916800) u = 2145916800 * (1 | u >> 31);

    integer y = 1970 + ((((u %= 126230400) >> 31) + u / 126230400) << 2);
    u -= 126230400 * (u >> 31);
    integer d = u / 86400;
    list r = [u % 86400 / 3600, u % 3600 / 60, u % 60];
 
    if (789 == d)
    {
        y += 2;
        u = 2;
        d = 29;
    }
    else
    {
        y += (d -= (d > 789)) / 365;
        d %= 365;
        d += u = 1;
        integer temp;
        while (d > (temp = (30 | (u & 1) ^ (u > 7)) - ((u == 2) << 1)))
        {
            ++u;
            d -= temp;
        }
    }
    return [y, u, d] + r;
}

/*!
Converts enDate datetime list to Unix time.
@param list l enDate list. See enDate_*ToList().
@return integer Unix time. Comparable to llGetUnixTime().
*/
integer enDate_YMDHMSToUnix(
    list l
)
{
    integer y = llList2Integer(l, 0) - 1902;

    if (y >> 31 || y / 136) return 2145916800 * (1 | y >> 31);

    integer m = ~-llList2Integer(l, 1);
    integer d = ~-llList2Integer(l, 2);
    m += !~m;

    return 86400 * ((integer)(y * 365.25 + 0.25) - 24837 + m * 30 + (m - (m < 7) >> 1) + (m < 2) - (((y + 2) & 3) > 0) * (m > 1) + d + !~d)
        + llList2Integer(l, 3) * 3600
        + llList2Integer(l, 4) * 60 
        + llList2Integer(l, 5);
}

/*!
Gets number of days in a specific month from YM list.
@param list ym [Y, M]. May include [D, h, m, s, u].
@return integer Number of days in specified month.
*/
integer enDate_YMToDays(
    list ym
)
{
    return enDate_IntegersToDays(llList2Integer(ym, 0), llList2Integer(ym, 1));
}

/*!
*/
string enDate_YMDToPretty(
    list ymd,
    integer flags
)
{
    string m;
    string d;
    // generate month and day text if we're going to use it
    if (flags & (FLAG_ENDATE_TEXT_DMY | FLAG_ENDATE_TEXT_MDY))
    {
        // generate month
        if (flags & FLAG_ENDATE_TEXT_SHORT)
        { // we need a short month ("Jan")
            m = enDate_Month_Short(llList2Integer(ymd, 1));
            if (flags & FLAG_ENDATE_TEXT_SHORT_DOT) m += "."; // we need to add a dot ("Jan.")
        }
        else m = enDate_Month(llList2Integer(ymd, 1)); // we need a full month ("January")

        // generate day
        integer i_d = llList2Integer(ymd, 2);
        d = (integer)d; // start with raw digit ("1")
        if (flags & FLAG_ENDATE_TEXT_ORDINAL) d += enInteger_Ordinal(i_d); // we need to add an ordinal ("1st")
        if (flags & (FLAG_ENDATE_TEXT_DMY | FLAG_ENDATE_TEXT_OF)) d += " of";
    }

    // textual representation of date in DD Mmm YYYY
    if (flags & FLAG_ENDATE_TEXT_DMY)
        return d + " " + m + " " + llList2Integer(ymd, 0);

    // textual representation of date in Mmm DD, YYYY
    if (flags & FLAG_ENDATE_TEXT_MDY)
        return m + " " + d + ", " + llList2Integer(ymd, 0);
}

string enDate_YMDHMSToPretty(
    list ymdhms,
    integer flags
)
{
    return enDate_YMDToPretty(llList2List(ymdhms, 0, 2), flags) + enDate_HMSToPretty(llList2List(ymdhms, 3, -1), flags);
}
