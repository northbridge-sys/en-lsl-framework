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

- enLog - a standardized logging interface that can be configured for "in-the-field" debugging
- enLEP - heavily extended `llMessageLinked`-like functions
- enCLEP - `llListen`/`llRegionSayTo` encapsulation for enLEP or other raw data
- enLSD - functions to safely write, read, and manipulate key-value pairs in the `llLinksetData*` store
- enKVS - simple in-memory key-value store, particularly useful for backing up critical linkset data
- enTimer - `llSetTimerEvent` with string callbacks, multiple concurrent timers, and one-shot timers
- enTest - unit testing utilities
- Helper libraries for integers (including hex & bitwise), floats, vectors, rotations, strings, lists, and keys
- Miscellaneous additional libraries for avatars, environments, inventory, object parameters, and time/dates
- Complete utility scripts, as well as drop-in `#import`able snippets for special use cases

## Installation

If you haven't, enable the LSL preprocessor in your viewer and set the directory where the LSL preprocessor will check for include files.

For the latest **development** release:
- Create a directory called `northbridge-sys` in your LSL preprocessor include directory, if you haven't already.
- Inside the `northbridge-sys` directory, clone the repository into your preprocessor include directory using the command `git clone https://git.catlab.systems/northbridge-sys/en-lsl-framework.git`. This will create the `en-lsl-framework` directory and clone the latest commit into it.

Or, for the current **stable** release, or if you don't want to use git:
- Create a directory called `northbridge-sys` in your LSL preprocessor include directory, if you haven't already.
- Create a directory called `en-lsl-framework` in the `northbridge-sys` directory.
- [Download](https://git.catlab.systems/northbridge-sys/en-lsl-framework/archive/main.zip) and unpack the repository into the `en-lsl-framework` directory, so that `libraries.lsl` is located in `[preprocessor directory]/northbridge-sys/en-lsl-framework/libraries.lsl` (or with backslashes - \ - for Windows users). **Make sure you don't name the folder "en-lsl-framework-main"!**

Note that you'll need to repeat this process for each update; there is no auto-updater.

## Usage

**The complete reference guide for En is located on the [NBS Documentation portal](https://docs.northbridgesys.com/en-lsl-framework).**

The following information is only an overview meant to describe how the En framework works at a basic level. We strongly recommend using the reference guide when writing En scripts!

### Overview

Include the framework libraries by placing the following line at the top of your script:

```
#include "northbridge-sys/en-lsl-framework/libraries.lsl"
```

Then, in the script body, include the framework event handlers in each state

```
default
{
    #include "northbridge-sys/en-lsl-framework/event-handlers.lsl"
}
```

To run your own code on an event, most event handlers can forward them to user-defined functions upon request:

```
#define EN_STATE_ENTRY
#define EN_ON_REZ

#include "northbridge-sys/en-lsl-framework/libraries.lsl"

en_state_entry()
{
    // runs on state_entry if EN_STATE_ENTRY has been defined
}

en_on_rez( integer param )
{
    // runs on on_rez if EN_ON_REZ has been defined
}

// ...
```

En also injects its own trace logging if the following macros are defined:

- `EN_TRACE_LIBRARIES` enables all *library* logging
- `EN*_TRACE` enables logging for a *specific* library (such as `ENCLEP_TRACE`)
- `EN_TRACE_EVENT_HANDLERS` enables all *event* logging (**this will add ALL events to your script!**)
- `EN_*_TRACE` enables logging for a *specific* event (such as `EN_LINK_MESSAGE_TRACE`)

If you need to define any preprocessor values, make sure you do so *above* `#include "northbridge-sys/en-lsl-framework/libraries.lsl"`.

Here's an example of a script that does nothing but log En function calls and events used by En:

```
#define EN_TRACE_LIBRARIES
#define EN_TRACE_EVENT_HANDLERS

#include "northbridge-sys/en-lsl-framework/libraries.lsl"

default
{
    #include "northbridge-sys/en-lsl-framework/event-handlers.lsl"
}
```

## Frequently Asked Questions

### Why?

LSL is over twenty years old and still has no function that returns a random integer. While it's still fun, coding in any other language makes LSL feel barbaric.

While LSL does enjoy occasional improvements, a lot of code snippets end up copied and pasted across multiple projects, each with its own tweaks and bugs. Most LSL code is, as a result, ugly, incomprehensible, and unmaintainable.

Many Second Life viewers provide the ability to use an external LSL editor, and some also include the LSL preprocessor, a tool that allows developers to use a limited set of C preprocessor directives to manipulate LSL source code.

We develop a lot of different projects at the same time that share the same code or need to take advantage of the same tricks (or avoid the same pitfalls), so the preprocessor lets us call functions out of shared LSL libraries. If we need to add or change something in a library, all it takes is recompiling all the scripts that use that library instead of manually copying and pasting the code to each script. This simplifies development across multiple product lines and facilitates rapid prototyping and development of complex LSL scripts.

The overarching strategy of En is to focus on the code, not the infrastructure. Thanks to the LSL preprocessor, these additional functions and background routines just work.

### How does it work?

The LSL preprocessor makes all of the helper functions defined in the En libraries available within LSL scripts. Since the LSL preprocessor can automatically remove functions that aren't referenced in the final script, these functions are only compiled into the script if they are called; otherwise, they don't take any script memory.

Additionally, the En framework creates and redirects event handlers (`state_entry`, `link_message`, etc.) dynamically based on the functionality you enable to optimize script performance. If you need to handle certain events yourself, En can do so by passing them through to user-defined functions. If an event handler isn't needed for an En feature and you don't specifically request it, it won't be added to the compiled script.

Certain En features require that you define certain flags or variables before they work to minimize unnecessary memory usage and script time; see [the documentation](https://docs.northbridgesys.com/en-lsl-framework) for more information.

### Why "En"?

"En" is a reference to the Sumerian cuneiform of the same name, particularly the term's thematic presence throughout *Snow Crash*, the novel that directly inspired the creation of Second Life.

>" . . . Primitive societies were controlled by verbal rules called *me*. The *me* were like little programs for humans. They were a necessary part of the transition from caveman society to an organized, agricultural society. For example, there was a program for plowing a furrow in the ground and planting grain. There was a program for baking bread and another one for making a house. There were also *me* for higher-level functions such as war, diplomacy, and religious ritual. All the skills required to operate a self-sustaining culture were contained in these *me*, which were written down on tablets or passed around in an oral tradition. In any case, the repository for the *me* was the local temple, which was a database of *me*, controlled by a priest/king called an *en*. When someone needed bread, they would go to the *en* or one of his underlings and download the bread-making *me* from the temple. Then they would carry out the instructions -- run the program -- and when they were finished, they'd have a loaf of bread.
>
>"A central database was necessary, among other reasons, because some of the *me* had to be properly timed. If people carried out the plowing-and-planting *me* at the wrong time of year, the harvest would fail and everyone would starve. The only way to make sure that the *me* were properly timed was to build astronomical observatories to watch the skies for the changes of season. So the Sumerians built towers 'with their tops with the heavens' -- topped with astronomical diagrams. The *en* would watch the skies and dispense the agricultural *me* at the proper times of year to keep the economy running."

- Neal Stephenson, *Snow Crash* (1992).

The En framework provides a "central database" of "little programs" for all sorts of "functions" in the "society" of LSL, of which many need to be "properly timed" to run on certain events... so the name just made sense.

### Why use En compared to raw LSL?

En is intended for complex projects, especially "networked" scripts - that is, one or more objects with multiple scripts that need a standardized and efficient way to communicate with each other. The performance impact of multiple scripts in an object is trivial, but LSL is not designed to handle these sorts of scenarios well at runtime.

For example, if an object has multiple scripts in a prim and you need to use `llMessageLinked` to send a message to one of them, there is simply no way to do that without triggering `link_message` in every single script in the prim. enLEP, therefore, includes a filter to optionally target a specific script, so if/when a different script receives that message, the enLEP handler in the other script will drop the event as quickly as possible to reduce script time instead of wasting time processing the message further.

While we use En for most of our projects, there are still some limited circumstances where raw LSL is good enough or provides a slight edge in performance. Generally, En is designed for scaling at the expense of script memory and some limited performance in certain scenarios in simple scripts. It is primarily efficient in a code-factoring sense - that is, by using En functions, En scripts do not unnecessarily duplicate code that could be consolidated into a single function.

### Why use En compared to Lua/Luau?

Luau support in Second Life is currently in beta and does not have a preprocessor. It is, therefore, difficult to write and maintain Lua scripts "at scale" since the scripts need to be individually copied into the viewer and compiled manually. The LSL preprocessor, instead, lets you `#include` entire LSL/En scripts off your local computer, meaning you can mass recompile many scripts and they will all pull the latest copy from your computer instead of needing each to be manually copy-pasted and recompiled. From a development perspective - especially if you use version control - LSL is still a lot easier. For example, scripts in the `utilities` folder can be `#include`d directly into an empty LSL script and compiled.

If this ever changes, we hope to port En to Lua to take advantage of the significant performance improvements; however, until then, LSL/En is still significantly easier from a development perspective.

### Why redirect events? Don't the additional function definitions increase script memory?

En dynamically adds code in event handlers depending on the flags you defined in the script. For example, defining `ENCLEP_ENABLE` creates a `listen` event (if it doesn't already exist) and passes its events to an internal enCLEP function for processing CLEP messages. If a message is determined to not be a CLEP message and the `EN_LISTEN` flag is defined, the script then passes the message to the `en_listen` user-defined function.

Since there is no way for the LSL preprocessor to easily inject this code into a user-written `listen` event handler, En manages the event handler itself.

Passing events to user-defined functions only adds a trivial amount of memory usage. (Functions have not implicitly allocated 512 bytes in Mono since at least 2013.)

### If I don't need any of the En functions, why use En at all?

En provides a limited set of basic functionality that is always enabled unless specifically disabled via flags. For example, if the `"stop"` linkset data pair contains a truthy value, En will automatically stop the script on `state_entry`. This can be used for, e.g., updater and script distribution tools that have scripts inside them that must never run until added to another object.

## Examples

enLog enables in-the-field debugging out-of-the-box. With En, just write:

```
someFunction(integer x, integer y)
{
    enLog_TraceParams("someFunction", ["x", "y"], [x, y] );
    enLog_Debug("This will only appear if loglevel is DEBUG or above.");
    enLog_Info("Function called with parameters " + (string)x + " and " + (string)y + ".");
    if (x) enLog_Warn("Non-zero values of x are discouraged.");
    if (y) enLog_Error("Non-zero values of y are prohibited (normally you would return at this point).");
    if (x && y) enLog_FatalStop("Everything is terrible."); // script will stop when enLog_FatalStop is called
}
```

and when you call `someFunction(1, 2);`, you'll see the following sent to you via `llOwnerSay` by default:

```
💬 Function called with parameters 1 and 2.
🚩 WARNING: Non-zero values of x are discouraged.
❌ ERROR: Non-zero values of y are prohibited (normally you would return at this point).
🛑 FATAL ERROR: Script stopped: Everything is terrible.
```

or, if you change the runtime loglevel to TRACE (such as with `enLog_SetLoglevel(TRACE);`), you'll not only get additional relevant logs, but a header that shows the exact time, the first 4 digits of the object's UUID (handy for distinguishing between objects with the same name), the current memory usage, the preprocessed source line number, and the name of the script logging the message:

```
🔽 [12:11:24.81] (16% 13a1 @25) New Script
🚦 someFunction(
        x = 1,
        y = 2
    )
🔽 [12:11:24.86] (16% 13a1 @26) New Script
🪲 This will only appear if loglevel is DEBUG or above.
🔽 [12:11:24.89] (16% 13a1 @27) New Script
💬 Function called with parameters 1 and 2.
🔽 [12:11:24.91] (16% 13a1 @28) New Script
🚩 WARNING: Non-zero values of x are discouraged.
🔽 [12:11:24.98] (16% 13a1 @29) New Script
❌ ERROR: Non-zero values of y are prohibited (normally you would return at this point).
🔽 [12:11:25.05] (16% 13a1 @30) New Script
🛑 FATAL ERROR: Script stopped: Everything is terrible.
```

You can also send a copy of all logs as they are written to a separate object by writing the object's UUID to the `"logtarget"` linkset data value.

En also implements a structured request-response protocol, standard linkset data structures, and other methods for modular multi-script objects. For example, you can send a message to a specific script like so:

```
enLEP_Send(
    LINK_THIS,
    "Target Script Name",
    ENLEP_TYPE_REQUEST,
    ["ping"], // parameters passed to target
    "" // data string passed to target
);
```

and the other script - if compiled with En - will call the `enlep_message` function defined by the script:

```
#define ENLEP_MESSAGE

#include "northbridge-sys/en-lsl-framework/libraries.lsl"

enlep_message(
    integer source_link,
    string source_script,
    string target_script,
    integer flags,
    list parameters,
    string data
)
{
    if (~flags & ENLEP_TYPE_REQUEST) return; // only respond to requests
    if (llList2String( parameters, 0) != "ping") return; // only respond if first element of params is "ping"
    enLEP_Send( // respond via enLEP
        source_link,
        source_script,
        ENLEP_TYPE_RESPONSE,
        ["ping"],
        data // send data back, just in case
    );
}

default
{
    #include "northbridge-sys/en-lsl-framework/event-handlers.lsl"
}
```

and all other En scripts in the object will ignore the message.

## License

The En LSL Framework is licensed under the GNU Lesser General Public License v3.0. In short, you (yes, you!) may use the En LSL Framework in any LSL scripts - whether commercial or non-commercial - but you may not redistribute the En LSL Framework itself, in whole or in part, as a derivative work under any other license. Northbridge Business Systems and contributors to the En LSL Framework cannot be held liable for legal issues or damages due to its use.
