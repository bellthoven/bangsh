Bang.sh - Framework for easy Shell Scripting
============================================

This framework is intended to help on easy bash script development. It is totally modularized.
It helps you developing new Bash Script programs by forcing you to modularize and organize
your code in functions, so that your program can be tested.

It is pretty easy to write your first project.

    $ mkdir your_project
	$ cd your_project
	$ git clone git://github.com/bellthoven/bangsh.git
	$ vim your_project.sh

Now, you just have to source *bang.sh* with:

    #!/bin/bash
	source bangsh/src/bang.sh
    echo "My first bang.sh app"

And run it!

    $ bash your_project.sh

Or make it executable

	$ chmod +x your_project.sh
	$ ./your_project.sh

To make sure everything is fine, you can run all framework tests by typing:

    $ cd bangsh ; make test ; cd -

Now you can start developing your own modules and use it in your application.

    $ mkdir modules
	$ vim modules/my_first_module.sh

Create some function there. It is a good practice to prefix your functions, just to be sure
it will not override any other already defined.

    #!/bin/bash

	function my_first_module_says () {
		echo "My first module says: $*"
	}

Now, will end up with some tree like this:

    bangsh/
	  |- src/
	    |- modules/
		|- bang.sh
	  |- tests/
	    |- a lot of files
	  |- a lot of files
	modules/
	  |- my_first_module.sh
	your_project.sh

You can now source your module with *resolve_module_path* function. It'll lookup firstly in your modules directory,
then it'll lookup into bangsh/src/modules/ directory. Like this:

    source $(resolve_module_path my_first_module)
	my_first_module_says "Hello, World"

More directories can be added to the list with
*prepend_module_dir* and *append_module_dir*. Unfortunelly, the framework is not fully documented, so you may have
to dig into its code to see what you can do. A good start point are the unit tests !
