/*
enDate
Copyright (C) 2025  Northbridge Business Systems
https://docs.northbridgesys.com/en-lsl-framework
*/

list enDate_DayPartToHMS(
    float day_part
)
{
    integer seconds = (integer)(86400 * day_part); // get total number of seconds in a day represented by this day_part
    integer hours = seconds / 3600;
    integer minutes = (seconds / 60) % 60;
    seconds -= (hours * 3600) + (minutes * 60);
    return [
        hours,
        minutes,
        seconds
    ];
}

list enDate_EnvironmentTimeHere()
{ // note: this shouldn't be used in attachments maybe because of llGetPos?
    list e = llGetEnvironment(llGetPos(), [ENVIRONMENT_DAYINFO]);
    return enDate_DayPartToHMS((float)llList2String(e, 2) / (float)llList2String(e, 0));
}

//  converts an hour,minutes,seconds list to a prettified string
string enDate_PrettyHMS(
    list hms,
    integer flags
)
{
    string xm;
    if (flags & FLAG_ENDATE_12_HOUR)
    {
        xm = "A";
        integer h = (integer)llList2String(hms, 0);
        if (h == 0) h = 12;
        else
        {
            if (h >= 12) xm = "P"; // if hour 12-23, P
            if (h > 12) h -= 12; // if hour 13-23, go back to 1-11
        }
        hms = llListReplaceList(hms, [(integer)llList2String(hms, 0) - 12], 0, 0);
    }
    if (flags & FLAG_ENDATE_PAD_ZEROES)
    {
        while (llStringLength(llList2String(hms, 0)) < 2) hms = llListReplaceList(hms, ["0" + llList2String(hms, 0)], 0, 0);
        while (llStringLength(llList2String(hms, 1)) < 2) hms = llListReplaceList(hms, ["0" + llList2String(hms, 1)], 1, 1);
        while (llStringLength(llList2String(hms, 2)) < 2 || (llSubStringIndex(llList2String(hms, 2), ".") < 2 && llSubStringIndex(llList2String(hms, 2), ".") > -1)) hms = llListReplaceList(hms, ["0" + llList2String(hms, 2)], 2, 2); // TODO: MAKE LESS BAD
    }
    return llList2String(hms, 0) + ":" + llList2String(hms, 1) + ":" + llList2String(hms, 2) + xm;
}

//  gets an integer that represents the current millisecond of a month
integer enDate_MS(
    string timestamp // llGetTimestamp string (use enDate_MSNow() for the current value)
    )
{
    return 0x80000000 + // start at -2147483648
        (integer)llGetSubString( timestamp, 8, 9 ) * 86400000 + // days * ms_per_day (-2147483648 + (31 * 86400000) = 530916352)
        (integer)llGetSubString( timestamp, 11, 12 ) * 3600000 + // hours * ms_per_hour (530916352 + (23 * 3600000) = 613716352)
        (integer)llGetSubString( timestamp, 14, 15 ) * 60000 + // minutes * ms_per_minute (613716352 + (59 * 60000) = 617256352)
        (integer)( (float)llGetSubString( timestamp, 17, -2 ) * 1000.0 ); // seconds.ms * ms_per_second (617256352 + 60000 = 617316352)
    // total range is 2764800000 ms, or ms in 31 days
}

//  adds a number of milliseconds to an enDate_MS integer to safely wrap milliseconds at the ends of a month
integer enDate_MSAdd(
    integer ms, // enDate_MS result
    integer add // milliseconds to add - note this is limited to +/- 1530167295, otherwise you will overflow
)
{
    // check if adding takes us into the "dead zone" of 617316352 to 2147483647
    if ( ms + add > 617316352 ) return ( ms + add ) + 2764800000 * ( -1 * ( add > 0 ) ); // if we are adding +, subtract the entire range; otherwise, add it
    return ms + add; // no adjustment needed
}

integer enDate_DaysInMonth(
    integer month,
    integer year
)
{
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    else if (month == 2)
    {
        if (year % 4 == 0) return 29;
        else return 28;
    }
    else return 31;
}
