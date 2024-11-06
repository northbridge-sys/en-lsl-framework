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

## Why?

The Linden Scripting Language is over twenty years old and does not have any function that gives you a random integer.

Xi augments LSL with features that should have been in LSL a decade ago, but aren't. While LSL does enjoy occasional improvements, a lot of code snippets end up copied and pasted across multiple projects, each with its own tweaks and bugs. Most LSL code is, as a result, ugly, incomprehensible, and unmaintainable.

Xi is an attempt to centralize all of these handy snippets into one omnibus framework. With all the hacks at your fingertips, there's no need to reinvent the wheel in every new script. Focus on the code, not the infrastructure.

No need to stress over which delineator character to use when dumping a list to a string, just use `XiList_ToString`. Want to append the prim UUID and a special header to all of your linkset data pairs so they don't conflict with other scripts in the linkset? Put `#define XILSD_HEADER "myheader"` and `#define XILSD_ENABLE_UUID_HEADER` at the top of your script, include some event handlers, and use `XiLSD_Write` - Xi will even update all of your linkset data pairs automatically when the key changes.

Thanks to the LSL preprocessor, these additional functions are always available to you while you script. For example, XiLog enables in-the-field debugging out-of-the-box. It lets you write:

```
XiLog_TraceParams( "function", [ "x", "y" ], [ x, y ] );
XiLog( DEBUG, "Performing action..." );
XiLog( INFO, "You have just called the function with values " + (string)x + " and " + (string)y + "." );
if ( x ) XiLog( WARN, "Non-zero values of x are discouraged." );
else XiLog( ERROR, "Hey, how are you reading both of these at once?" );
XiLog_Fatal( "The script will send this message and stop." );
```

but you'll actually see:

```
💬 You have just called the function with values 1 and 2.
🚩 WARNING: Non-zero values of x are discouraged.
❌ ERROR: Hey, how are you reading both of these at once?
🛑 FATAL ERROR: The script will send this message and stop.
```

or, if you enable TRACE logging at runtime, you'll not only get additional logs, but a header that shows the exact time, the first 4 digits of the object's UUID (for distinguishing objects in logs), the current memory used, and the name of the script logging the message:

```
🔽 [12:11:24.81] (13a1 17%) New Script
🚦 function(
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

## Instructions

Unpack the "xi-lsl-library" directory inside your LSL preprocessor include directory.

Include the libraries by adding the following line to the top of your script:

```
#include "xi-lsl-framework/main.lsl"
```

Then, in the script body, include the event handlers:

```
default
{
    #include "xi-lsl-framework/event-handlers/state_entry.lsl"
    #include "xi-lsl-framework/event-handlers/on_rez.lsl"
    #include "xi-lsl-framework/event-handlers/attach.lsl"
    #include "xi-lsl-framework/event-handlers/changed.lsl"
    #include "xi-lsl-framework/event-handlers/link_message.lsl"
    #include "xi-lsl-framework/event-handlers/listen.lsl"
    #include "xi-lsl-framework/event-handlers/timer.lsl"
}
```

Which event handlers you need depends on which functions you use. Generally, it's recommended to use all of the event handlers unless you have a reason not to (like not wanting to clog the event queue with `link_message` events in an environment with heavy `link_message` traffic that you don't need to process, or being extremely memory-limited). Omitting an event handler can cause certain functions to not work properly, so make sure you understand the code you're omitting.

If you want to run your own code on an event, most event handlers can forward them to user-defined functions upon request:

```
#define XI_STATE_ENTRY
Xi_state_entry()
{
	// runs on state_entry if XI_STATE_ENTRY has been defined
}
```

If you need to define any preprocessor values *other* than event definitions, make sure you do so *above* the `main.lsl` `#include` line:

```
#define XI_ALL_ENABLE_XILOG
#include "xi-lsl-framework/main.lsl"
```

## Function Reference

TBD - moving to wiki
