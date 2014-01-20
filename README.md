Bang.sh - for easy Shell Scripting
==================================

[![Build Status](https://travis-ci.org/bellthoven/bangsh.png)](https://travis-ci.org/bellthoven/bangsh)

This framework is intended to help on easy bash script development. It is totally modularized.
It helps you developing new Bash Script programs by forcing you to modularize and organize
your code in functions, so that your program can be tested.

# Installation

You can clone the bang repository in any path. For instance,

```bash
cd /usr/local/
git clone git://github.com/bellthoven/bangsh.git
```

You can `cd bangsh` and then `bin/bang test`. It will run all test suites.
If all tests pass, you're good to go. In order to have a better experience,
add the `bin/` path to your `$PATH` environment variable, something like:

```bash
export PATH="$PATH:/usr/local/bangsh/bin/"
```

# Creating a new project

Since `bang` is now executable from any directory, you can create your own
project by typing:

```bash
bang new my_project
```

This command will create a directory called `my_project/`. There will be some
directories which are intended to place some specific files. They are listed below.

## Modules

A module is a bunch of functions that have a certain domain. It works like a
namespace for aggregating functions. The general idea is to have it isolated,
so it could be copied and pasted into another project in a such way it would
not rely on any other dependency but Bang.

### Example:

```bash
# modules/my_first_module.sh

function my_first_module_says () {
  echo "My first module says: $*"
}
```

Now, you can use the module in your executable file:

```bash
#!/usr/bin/env bash
source "/usr/local/bangsh/src/bang.sh"

b.module.require my_first_module

my_first_module_says "Hey!"
```

This will lookup into `modules/` path looking for the module and source it.
More directories can be added to the list with
*prepend_module_dir* and *append_module_dir*. Unfortunately, the framework is not fully documented, so you may have
to dig into its code to see what you can do. A good start point are the unit tests !

## Tasks

A task is like an action your executable will perform. It is how `bang new` and `bang test` work.
To see more about tasks, check [bang's executable](https://github.com/bellthoven/bangsh/blob/master/bin/bang)
