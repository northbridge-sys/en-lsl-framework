<h1 align="center"> En LSL Framework </h1> <br>

<p align="center">
  Libraries, snippets, and utilities for Second Life scripters.
</p>

## Introduction

**En is under active and ongoing development; many functions have not been fully tested. Do not use this framework in your projects until this message is removed! It is experimental and highly unstable!**

A framework for the [Linden Scripting Language](https://wiki.secondlife.com/wiki/LSL_Portal) in [Second Life](https://secondlife.com/).

LSL is the native scripting language used to control Second Life objects. Certain third-party viewers incorporate an [LSL preprocessor](https://wiki.firestormviewer.org/fs_preprocessor) that provides C-style preprocessor macros via the built-in script editor. The En LSL Framework leverages the `#include` and `#define` macros, along with the built-in script optimizer, to make dozens of helper functions available to LSL scripts.

## Key Features

Some of the useful features En provides:

- enLog - a standardized logging interface that encourages better scripting
- enChat - `llListen`/`llRegionSayTo` with hash channels, packetization, and LSD/KVP/inventory transfers
- enIMP - `llMessageLinked` (or enChat) with lists, script filtering, and a request-response protocol
- enLSD - functions to safely write, read, and manipulate key-value pairs in the `llLinksetData*` store
- enKVP - simple in-memory key-value pair database, particularly useful for backing up critical linkset data
- enTimer - `llSetTimerEvent` with string callbacks, multiple concurrent timers, and one-shot timers
- enTest - unit testing utilities
- Helper libraries for integers (including hex & bitwise), floats, vectors, rotations, strings, lists, and keys
- Other helper libraries for time functions, object manipulation, and inventory management
- Complete utility scripts, as well as drop-in `#import`able snippets for special use cases

## Installation

If you haven't, enable the LSL preprocessor in your viewer and set the directory where the LSL preprocessor will check for include files.

For the latest **development** release:
- Clone the repository directly into your preprocessor include directory using the command `git clone https://github.com/northbridge-sys/en-lsl-framework`. This will create the `en-lsl-framework` directory and clone the latest commit into it.

Or, for the latest **stable** release, or if you don't want to use git:
- Create a directory called `en-lsl-framework` in your LSL preprocessor include directory.
- [Download](https://github.com/northbridge-sys/en-lsl-framework/archive/refs/heads/main.zip) and unpack the repository into the `en-lsl-framework` directory, so that `libraries.lsl` is located in `[preprocessor directory]/en-lsl-framework/libraries.lsl`. **Do not** name the folder "en-lsl-framework-main"!

## Usage

**The complete reference guide for En is located on the [NBS Documentation portal](https://docs.northbridgesys.com/en-lsl-framework).**

The following information is only an overview meant to describe how the En framework works at a basic level. We strongly recommend using the reference guide when writing En scripts!

### Overview

Include the framework libraries by placing the following line at the top of your script:

```
#include "en-lsl-framework/libraries.lsl"
```

Then, in the script body, include the framework event handlers in each state

```
default
{
    #include "en-lsl-framework/event-handlers.lsl"
}
```

To run your own code on an event, most event handlers can forward them to user-defined functions upon request:

```
#define EN$STATE_ENTRY
#define EN$ON_REZ

#include "en-lsl-framework/libraries.lsl"

en$state_entry()
{
    // runs on state_entry if EN$STATE_ENTRY has been defined
}

en$on_rez( integer param )
{
    // runs on on_rez if EN$ON_REZ has been defined
}

// ...
```

En also injects its own trace logging if the following macros are defined:

- `EN$TRACE_LIBRARIES` enables all *library* logging
- `EN*$TRACE` enables logging for a *specific* library (such as `ENCHAT$TRACE`)
- `EN$TRACE_EVENT_HANDLERS` enables all *event* logging (**this will add ALL events to your script!**)
- `EN$*_TRACE` enables logging for a *specific* event (such as `EN$LINK_MESSAGE_TRACE`)

If you need to define any preprocessor values, make sure you do so *above* `#include "en-lsl-framework/libraries.lsl"`.

Here's an example of a script that does nothing but log En function calls and events used by En:

```
#define EN$TRACE_LIBRARIES
#define EN$TRACE_EVENT_HANDLERS

#include "en-lsl-framework/libraries.lsl"

default
{
    #include "en-lsl-framework/event-handlers.lsl"
}
```

## Frequently Asked Questions

### Why?

LSL is over twenty years old and still has no function that returns a random integer. While it's still fun, coding in any other language makes LSL feel... barbaric.

En augments LSL with features that should have been in LSL a decade ago, but aren't. While LSL does enjoy occasional improvements, a lot of code snippets end up copied and pasted across multiple projects, each with its own tweaks and bugs. Most LSL code is, as a result, ugly, incomprehensible, and unmaintainable.

En is centralizes all of these handy snippets into one omnibus framework. With all the tricks at your fingertips, there's no need to reinvent the wheel in every new script. Focus on the code, not the infrastructure. Thanks to the LSL preprocessor, these additional functions and background routines just work.

### How?

The LSL preprocessor makes all of the helper functions defined in the En libraries available within LSL scripts. Additionally, the En framework creates and redirects event handlers (`state_entry`, `link_message`, etc.) dynamically based on the functionality you enable to optimize script performance.

For example, enLog enables in-the-field debugging out-of-the-box. With En, just write:

```
someFunction( integer x, integer y )
{
    enLog$TraceParams( "someFunction", [ "x", "y" ], [ x, y ] );
    enLog$Debug( "This will only appear if loglevel is DEBUG or above." );
    enLog$Info( "Function called with parameters " + (string)x + " and " + (string)y + "." );
    if ( x ) enLog$Warn( "Non-zero values of x are discouraged." );
    if ( y ) enLog$Error( "Non-zero values of y are prohibited (normally you would return at this point)." );
    if ( x && y ) enLog$FatalStop( "Everything is terrible." ); // script will stop when enLog$FatalStop is called
}
```

and when you call `someFunction( 1, 2 );`, you'll see:

```
💬 Function called with parameters 1 and 2.
🚩 WARNING: Non-zero values of x are discouraged.
❌ ERROR: Non-zero values of y are prohibited (normally you would return at this point).
🛑 FATAL ERROR: Everything is terrible. Script stopped.
```

or, if you change the runtime loglevel to TRACE (such as with `enLog$SetLoglevel( TRACE );`), you'll not only get additional relevant logs, but a header that shows the exact time, the first 4 digits of the object's UUID (handy for distinguishing between objects with the same name), the current memory usage, and the name of the script logging the message:

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

You can also send a copy of all logs as they are written to a separate object by writing the object's UUID to the `"logtarget"` value.

En also implements a structured request-response protocol, standard linkset data structures, and other methods for modular multi-script objects. For example, you can send a message to a specific script like so:

```
enIMP$Send(
    "", // sends via link_message, but can also be sent to a specific link number, specific prim via chat, or all scripts listening to a specified channel
    "Target Script Name",
    "", // signals a request, as opposed to a broadcast or response
    0, // ident integer passed to target
    ["ping"], // params list passed to target
    "" // data string passed to target
    );
```

and the other script - if compiled with En - will call the `en$imp_message` function defined by the script:

```
#define ENIMP$ENABLE

#include "en-lsl-framework/libraries.lsl"

en$imp_message(
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
    enIMP$Send( // respond via IMP
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
    #include "en-lsl-framework/event-handlers.lsl"
}
```

and all other En scripts in the object will ignore the message.

### Why "En"?

"En" is a reference to the Sumerian cuneiform of the same name, inspired by the term's thematic presence in *Snow Crash*, the novel that directly inspired the creation of Second Life.

>" . . . Primitive societies were controlled by verbal rules called *me*. The *me* were like little programs for humans. They were a necessary part of the transition from caveman society to an organized, agricultural society. For example, there was a program for plowing a furrow in the ground and planting grain. There was a program for baking bread and another one for making a house. There were also *me* for higher-level functions such as war, diplomacy, and religious ritual. All the skills required to operate a self-sustaining culture were contained in these *me*, which were written down on tablets or passed around in an oral tradition. In any case, the repository for the *me* was the local temple, which was a database of *me*, controlled by a priest/king called an *en*. When someone needed bread, they would go to the *en* or one of his underlings and download the bread-making *me* from the temple. Then they would carry out the instructions -- run the program -- and when they were finished, they'd have a loaf of bread.
>
>"A central database was necessary, among other reasons, because some of the *me* had to be properly timed. If people carried out the plowing-and-planting *me* at the wrong time of year, the harvest would fail and everyone would starve. The only way to make sure that the *me* were properly timed was to build astronomical observatories to watch the skies for the changes of season. So the Sumerians built towers 'with their tops with the heavens' -- topped with astronomical diagrams. The *en* would watch the skies and dispense the agricultural *me* at the proper times of year to keep the economy running."

- Neal Stephenson, *Snow Crash* (1992).

In short, the En framework provides a repository of these "little programs" for all sorts of operations in the "society" of LSL, of which many need to be timed to run on certain events to keep the script running.
