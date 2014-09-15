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

# The "b" namespace

After sourcing the `bangsh.sh` file, several functions namespaced by `b` will be available, for instance:

* use `b.module.require unittest` to require modules from bangsh or from your modules folder
* use `b.get bang.working_dir` to get information, like where the command was called from: 

In the next sections there's more detailed information with some examples that will let you understand how the `b` namespace is used.

# Modules

A module is a bunch of functions that have a certain domain. It works like a
namespace for aggregating functions. The general idea is to have it isolated,
so it could be copied and pasted into another project in a such way it would
not rely on any other dependency but Bang, for example:

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

This will lookup into `modules/` path looking for the module and source it, hence every function defined in a module will be available inside the file where the module was required.

More directories can be added to the list with
`b.module.prepend_module_dir` and `b.module.append_module_dir`. The difference is the precedence of the indicated path during the lookup process.

When a module cannot be found, a `ModuleNotFound` exception will be raised. You can use this to control flow using with exception handling (explained below).

Remember that exactly like your own modules, those included with bang by default must be required before using them. e.g: `b.module.require path`


# Tasks

A task is like an action your executable will perform. It is how `bang new` and `bang test` work. 

Every task file should include at least one function (the entrypoint) following the pattern:

```bash
# tasks/<name>.sh
function btask.<name>.run () {
  # code to run on 'yourprogram <name>'
}
```

Additionally, as a convention, the other functions defined in the task files should be named with a preceding underscore, e.g:

```bash
function _create_module_path () {
  # task helper functions start with _
}
```

This is useful to distinguish "where" a given function comes from and to avoid name collisions with executables in the path.

To see more about tasks, check [bang's executable](https://github.com/bellthoven/bangsh/blob/master/bin/bang) to get an idea of how to use the task module in the main executable of your program as a way to create subcommands.

Keep in mind that you can trigger tasks from withing other tasks, allowing you to create nested subcommands for very expressive CLI tools. Related to this, the `opt` module allows you to have a configuration layer for each task, allowing to have this king of calls: `bang test --test-specific-option` and `bang new --new-task-option`

# Tests

The unittest module provides useful functions for testing. In order to peform assertions, you can use the following functions:

* `b.unittest.assert_error`: Asserts a function exit code is 1
* `b.unittest.assert_equal`: Asserts a function output is the same as required
* `b.unittest.assert_raise`: Asserts a function will raise a given exception
* `b.unittest.assert_success`: Asserts a function exit code is zero

There are a few extra functions for more complex scenarios, you can learn about them in the [unittest module source](https://github.com/bellthoven/bangsh/blob/master/src/modules/unittest.sh)

There's a [great test task](https://github.com/bellthoven/bangsh/blob/master/bin/tasks/test.sh) used by the bang binary itself. It prints colors and have some nice defaults that you can use in your project during development. Simply execute the `bang test` command inside your project's root path. If you put that path in your PATH env var, you can simply run bang test:

```
$ exprot PATH="$PATH:/path/to/bang.sh/bin/"
$ cd my_project/
$ bang test
```

# `str` module

Provides three helpers to work with strings: replace, part and trim. You can see details on how to use these in the http://bangsh.com/api/#String

# path module

Exposes functions to simplify common checks on paths, like: doest this file exists? The API docs can be found in http://bangsh.com/api/#Path

# opt module

Helps you parse options. You can define flags, option aliases and define required arguments. The module can generate usage information if a required argument was missing. You can see the code in the [parsing arguments example](https://github.com/bellthoven/bangsh/blob/master/samples/parsing_argv.sh) or check [the source](https://github.com/bellthoven/bangsh/blob/master/src/modules/opt.sh) that is pretty expressive about the exposed API.

# Misc. utils

By sourcing bang.sh you get by default some useful utils, e.g:

* Check if a value is inside an array: `in_array? "one" (one two)`
* Check for a key in an associative hash: `declare -A TEST_HASH=(["foo"]="bar"); key_exists? "foo" TEST_HASH`
* Check if something is a function: `is_function? foo`
* Raise and error and exit with code 2: `b.abort`
* Print to stderr `print_e`
* Sanitize an argument with `sanitize_arg` this is useful to remove semicolons, pipes, ampersands, etc. that could lead to code injections. Examples can be found in the [bang tests](https://github.com/bellthoven/bangsh/blob/master/tests/bang_test.sh#L27-L32)
* Escape argument: `escape_arg` (turns -- into \--)
* Check whether the argument is a valid module: `is_module?` 

All this helpers together with others (like the global scope variables), are defined in the [bang.sh source](https://github.com/bellthoven/bangsh/blob/master/src/bang.sh)

# Checking for dependencies

If your program uses external dependencies you can define them and execute a fallback function if the command's missing. For example, check if git is present and print the confirmation or run `print_how_to_install_git` otherwise:

```
b.try.do b.depends_on git
b.catch DependencyNotMetException print_how_to_install_git
b.try.end

echo 'You have git installed!'
```

# Handling exceptions

You can handle custom exceptions inside your functions: `b.raise FileNotFoundException`. You can make `WhateverException` name you want!

To work with exceptions you define the function to run, the functions that catch specific exceptions and, optionally, a `finally` clause that gets executed even if no exception was raised. Here's an example:

```
b.try.do run "$1"
b.catch FileNotFoundException file_not_found
b.catch IDontKnowException i_dont_know_what_it_is
b.finally try_again
b.try.end
```

In the previos example `i_dont_know_what_it_is` and `file_not_found` are simply functions triggered on the applicable cases. `try_again` however will _always_ run.

# Global scope variables

To store information accessible from anywhere in the program during it's excution, you can use `b.set` using the format: `b.set <registry>.<key> <value>`.

As a convention, the `bang` registry is reserved for things like: `b.set bang.working_dir $(pwd)` (allows you to know exactly from what folder the program executiong began). 

The bang registry also stores information about added tasks, e.g: `b.get bang.tasks.taskname` would return the description of `taskname`.

You can use other "registries" for your own programs, e.g: `b.set "myprogram.version" "1.0"`

Here's a list of useful methods related to globally scoped data storage:

* `b.set`
* `b.get`
* `b.is_set?`
* `b.unset`
