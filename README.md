<h1 align="center"> Xi LSL Framework </h1> <br>

<p align="center">
  Libraries, snippets, and utilities for Second Life scripters.
</p>

## Introduction

A framework for the [Linden Scripting Language](https://wiki.secondlife.com/wiki/LSL_Portal) in [Second Life](https://secondlife.com/).

LSL is the native scripting language used to control Second Life objects. Certain third-party viewers incorporate an [LSL preprocessor](https://wiki.firestormviewer.org/fs_preprocessor) that provides C-style preprocessor macros via the built-in script editor. The Xi LSL Framework leverages the `#include` and `#define` macros, along with the built-in script optimizer, to make dozens of helper functions available to LSL scripts.

## Key Features

Some of the useful features Xi provides:

- XiLog - a standardized logging interface that encourages better scripting
- XiChat - `llListen`/`llRegionSayTo` with hash channels, packetization, and LSD/KVP/inventory transfers
- XiIMP - `llMessageLinked` (or XiChat) with lists, script filtering, and a request-response protocol
- XiLSD - functions to safely write, read, and manipulate key-value pairs in the `llLinksetData*` store
- XiKVP - simple in-memory key-value pair database, particularly useful for backing up critical linkset data
- XiTimer - `llSetTimerEvent` with string callbacks, multiple concurrent timers, and one-shot timers
- XiTest - unit testing utilities
- Helper libraries for integers (including hex & bitwise), floats, vectors, rotations, strings, lists, and keys
- Other helper libraries for time functions, object manipulation, and inventory management
- Complete utility scripts, as well as drop-in `#import`able snippets for special use cases

## Instructions

- If you haven't, enable the LSL preprocessor in your viewer and set the directory where the LSL preprocessor will check for include files.
- Create a directory called `xi-lsl-framework` in your LSL preprocessor include directory.
- Unpack the repository into the `xi-lsl-framework`, so that `libraries.lsl` is located in `[preprocessor directory]/xi-lsl-library/libraries.lsl`.
- Include the framework libraries by placing the following line at the top of your script:

```
#include "xi-lsl-framework/libraries.lsl"
```

- Then, in the script body, include the framework event handlers in each state

```
default
{
    #include "xi-lsl-framework/event-handlers.lsl"
}

state abc   // if you use multiple states, make sure to #include the event handlers again, just be aware of memory!
{
    #include "xi-lsl-framework/event-handlers.lsl"
}
```

- To run your own code on an event, most event handlers can forward them to user-defined functions upon request:

```
#define XI_STATE_ENTRY
Xi_state_entry()
{
    // runs on state_entry if XI_STATE_ENTRY has been defined
}

#define XI_ON_REZ
Xi_on_rez( integer param )
{
    // runs on on_rez if XI_ON_REZ has been defined
}

// ...
```

However, it's possible to exclusively use custom Xi "event functions" - for example, here's a script that responds to any "ping" requests made to it over XiIMP:

```
Xi_imp_message(
    string prim, // source prim
    string target, // target script
    string status, // status string
    integer ident, // IMP ident (optional)
    list params, // IMP request parameters
    string data, // IMP data (optional)
    integer linknum, // -1 if not part of linkset
    string source // source script name
    )
{
    if ( status != "" ) return; // only respond to requests
    if ( llList2String( params, 0 ) != "ping" ) return; // only respond if first element of params is "ping"
    XiIMP_Send( // respond via IMP
        prim,
        source,
        "ok",
        ident,
        params,
        "Hello, \"" + source + "\"!"
        );
}

#include "xi-lsl-framework/libraries.lsl"

default
{
    #include "xi-lsl-framework/event-handlers.lsl"
}
```

Xi only injects its own trace logging if the following macros are defined:

- `XIALL_ENABLE_XILOG_TRACE` enables all *library* logging
- `XI*_ENABLE_XILOG_TRACE` enables logging for a *specific* library (such as `XICHAT_ENABLE_XILOG_TRACE`)
- `XI_ALL_ENABLE_XILOG_TRACE` enables all *event* logging (but see note below)
- `XI_*_ENABLE_XILOG_TRACE` enables logging for a *specific* event (such as `XI_LINK_MESSAGE_ENABLE_XILOG_TRACE`)

The following events are used by Xi: `attach`, `changed`, `dataserver`, `link_message`, `listen`, `on_rez`, `state_entry`, `timer`. If you define the `XI_*` option to pass through these events, you *also* need to enable `XI_*_ENABLE_XILOG_TRACE` or `XI_ALL_ENABLE_XILOG_TRACE` to log these events. For all other events, logging is *automatically enabled* - if you don't want logging, define the event handler yourself.

If you need to define any preprocessor values *other* than event definitions, make sure you do so *above* `#include "xi-lsl-framework/libraries.lsl"`.

Here's an example of a script that does nothing but log Xi function calls and events used by Xi:

```
#define XIALL_ENABLE_XILOG_TRACE
#define XI_ALL_ENABLE_XILOG_TRACE

#include "xi-lsl-framework/libraries.lsl"

default
{
    #include "xi-lsl-framework/event-handlers.lsl"
}
```

## Function Reference

TBD - moving to wiki

## Why?

LSL is over twenty years old and still has no function that returns a random integer. While it's still fun, coding in any other language makes LSL feel... barbaric.

Xi augments LSL with features that should have been in LSL a decade ago, but aren't. While LSL does enjoy occasional improvements, a lot of code snippets end up copied and pasted across multiple projects, each with its own tweaks and bugs. Most LSL code is, as a result, ugly, incomprehensible, and unmaintainable.

Xi is an attempt to centralize all of these handy snippets into one omnibus framework. With all the hacks at your fingertips, there's no need to reinvent the wheel in every new script. Focus on the code, not the infrastructure.

No need to stress over which delineator character to use when dumping a list to a string, use `XiList_ToString`, which requires no escaping. Need to interpolate between two rotations, just call `XiRotation_Slerp`. Want to append the prim UUID and a special header to all of your linkset data pairs so they don't conflict with other scripts in the linkset? Put `#define XILSD_HEADER "myheader"` and `#define XILSD_ENABLE_UUID_HEADER` at the top of your script, include some event handlers, and use `XiLSD_Write` - Xi will even update all of your linkset data pairs automatically when the key changes.

Thanks to the LSL preprocessor, these additional functions are always available to you while you script. For example, XiLog enables in-the-field debugging out-of-the-box. With Xi, just write:

```
XiLog_TraceParams( "someFunction", [ "x", "y" ], [ x, y ] );
XiLog( DEBUG, "Performing action..." );
XiLog( INFO, "You have just called the function with values " + (string)x + " and " + (string)y + "." );
if ( x ) XiLog( WARN, "Non-zero values of x are discouraged." );
else XiLog( ERROR, "Hey, how are you reading both of these at once?" );
XiLog_Fatal( "The script will send this message and stop." );
```

and you'll see:

```
💬 You have just called the function with values 1 and 2.
🚩 WARNING: Non-zero values of x are discouraged.
❌ ERROR: Hey, how are you reading both of these at once?
🛑 FATAL ERROR: The script will send this message and stop.
```

or, if you enable TRACE logging, you'll not only get additional relevant logs, but a header that shows the exact time, the first 4 digits of the object's UUID (handy for distinguishing between objects with the same name), the current memory usage, and the name of the script logging the message:

```
🔽 [12:11:24.81] (13a1 17%) New Script
🚦 someFunction(
        x=1,
        y=2
    )
🔽 [12:11:24.86] (13a1 16%) New Script
🪲 Performing action...
🔽 [12:11:24.89] (13a1 16%) New Script
💬 You have just called the function with values 1 and 2.
🔽 [12:11:24.91] (13a1 17%) New Script
🚩 WARNING: Non-zero values of x are discouraged.
🔽 [12:11:24.98] (13a1 16%) New Script
❌ ERROR: Hey, how are you reading both of these at once?
🔽 [12:11:25.05] (13a1 16%) New Script
🛑 FATAL ERROR: The script will send this message and stop.
```

Since you can change the loglevel at runtime, you can get a treasure trove of diagnostic information without needing anything more than a script with a single line of code! (Or the ManageLoglevel.lsl and SetLoglevel.lsl utility scripts, which are a little easier to use.)
