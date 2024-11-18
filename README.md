<h1 align="center"> Xi LSL Framework </h1> <br>

<p align="center">
  Libraries, snippets, and utilities for Second Life scripters.
</p>

## Introduction

**Xi is under active and ongoing development; many functions have not been fully tested. Do not use this framework in your projects until this message is removed! It is experimental and highly unstable!**

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

state abc   // if you use multiple states, make sure to #include the event handlers again, just be aware that all necessary event handlers will be included in all states
{
    #include "xi-lsl-framework/event-handlers.lsl"
}
```

- To run your own code on an event, most event handlers can forward them to user-defined functions upon request:

```
#define XI$STATE_ENTRY
Xi$state_entry()
{
    // runs on state_entry if XI$STATE_ENTRY has been defined
}

#define XI$ON_REZ
Xi$on_rez( integer param )
{
    // runs on on_rez if XI$ON_REZ has been defined
}

// ...
```

However, it's possible to exclusively use custom Xi "event functions" - for example, here's a script that responds to any "ping" requests made to it over XiIMP:

```
#define XIIMP_ENABLE

#include "xi-lsl-framework/libraries.lsl"

Xi$imp_message(
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
    XiIMP$Send( // respond via IMP
        prim,
        source,
        "ok",
        ident,
        params,
        "Hello, \"" + source + "\"!"
        );
}

default
{
    #include "xi-lsl-framework/event-handlers.lsl"
}
```

Xi only injects its own trace logging if the following macros are defined:

- `XI$TRACE_LIBRARIES` enables all *library* logging
- `XI*$TRACE` enables logging for a *specific* library (such as `XICHAT$TRACE`)
- `XI$TRACE_EVENT_HANDLERS` enables all *event* logging (**this will add ALL events to your script!**)
- `XI$*_TRACE` enables logging for a *specific* event (such as `XI$LINK_MESSAGE_TRACE`)

If you need to define any preprocessor values *other* than event definitions, make sure you do so *above* `#include "xi-lsl-framework/libraries.lsl"`.

Here's an example of a script that does nothing but log Xi function calls and events used by Xi:

```
#define XI$TRACE_LIBRARIES
#define XI$TRACE_EVENT_HANDLERS

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

Xi is centralizes all of these handy snippets into one omnibus framework. With all the tricks at your fingertips, there's no need to reinvent the wheel in every new script. Focus on the code, not the infrastructure. Thanks to the LSL preprocessor, these additional functions and background routines just work.

For example, XiLog enables in-the-field debugging out-of-the-box. With Xi, just write:

```
someFunction( integer x, integer y )
{
    XiLog$TraceParams( "someFunction", [ "x", "y" ], [ x, y ] );
    XiLog$Debug( "This will only appear if loglevel is DEBUG or above." );
    XiLog$Info( "Function called with parameters " + (string)x + " and " + (string)y + "." );
    if ( x ) XiLog$Warn( "Non-zero values of x are discouraged." );
    if ( y ) XiLog$Error( "Non-zero values of y are prohibited (normally you would return at this point)." );
    if ( x && y ) XiLog$FatalStop( "Everything is terrible." ); // script will stop when XiLog$FatalStop is called
}
```

and when you call `someFunction( 1, 2 );`, you'll see:

```
💬 Function called with parameters 1 and 2.
🚩 WARNING: Non-zero values of x are discouraged.
❌ ERROR: Non-zero values of y are prohibited (normally you would return at this point).
🛑 FATAL ERROR: Everything is terrible. Script stopped.
```

or, if you change the runtime loglevel to TRACE (such as with `XiLog$SetLoglevel( TRACE );`), you'll not only get additional relevant logs, but a header that shows the exact time, the first 4 digits of the object's UUID (handy for distinguishing between objects with the same name), the current memory usage, and the name of the script logging the message:

```
🔽 [12:11:24.81] (13a1 17%) New Script
🚦 someFunction(
        x = 1,
        y = 2
    )
🔽 [12:11:24.86] (13a1 16%) New Script
🪲 This will only appear if loglevel is DEBUG or above.
🔽 [12:11:24.89] (13a1 16%) New Script
💬 Function called with parameters 1 and 2.
🔽 [12:11:24.91] (13a1 17%) New Script
🚩 WARNING: Non-zero values of x are discouraged.
🔽 [12:11:24.98] (13a1 16%) New Script
❌ ERROR: Non-zero values of y are prohibited (normally you would return at this point).
🔽 [12:11:25.05] (13a1 16%) New Script
🛑 FATAL ERROR: Everything is terrible. Script stopped.
```
