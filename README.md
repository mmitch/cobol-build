cobol-build
===========

[![Build Status](https://travis-ci.org/mmitch/cobol-build.svg?branch=master)](https://travis-ci.org/mmitch/cobol-build)

This repository contains a COBOL build system for use with
[GnuCOBOL](https://savannah.gnu.org/projects/gnucobol) under Linux.
Main features are:

 - Makefiles with `build`, `test` and `clean` targets
 - [Cobol unit testing framework](https://github.com/neopragma/cobol-unit-test)
   included
 - ready-to-use [TravisCI integration](https://travis-ci.org)
 - easy to integrate into your project


how to install
--------------

1. Add _cobol-build_ to your project:

   - If you have a git based project, add _cobol-build_ as a
     submodule to your existing repository:
	 - `git submodule add git@github.com:mmitch/cobol-build.git`
	 - `git commit`
	 - add an extra parameter to `git submodule add` to check out to a
       different directory

   - Otherwise just download _cobol-build_ and put it in a
     subdirectory in your project.

2. Copy `template/Makefile` to the root directory of your project
   and edit it to your needs.  Most important are the variables
   `BUILDROOT` and `PROJECTROOT`.

3. Structure your COBOL source code in the predefined directory
   layout (see `PROJECTROOT` or _build projects_ below).

4. Write a `build.txt` for your project(s), see _build.txt_ below.

5. If you want [TravisCI integration](https://travis-ci.org), copy
   `template/.travis.yml` to the root directory of your project.

   - If you put _cobol-build_ in a directory _not_ named
     `cobol-build`, you need change all instances of `cobol-build` in
     `.travis.yml` to that directory.


how to use
----------

Run `make build`, `make test` or `make clean` as needed ;-)

The output of `make` is stripped down to be easier to read.  If you
run into an error or want to see what is really going on, run `make`
with the parameter `V=1`, eg. `make build V=1`.

Run `make autotest` to enable continuous testing: If any file in your
source projects changes, `make test` will be run automatically.  This
needs `inotifywait` from the _inotify tools_.


how to update
-------------

If you use a git submodule, do `git submodule update --remote cobol-build`
(or whatever you named the directory for _cobol-build_).

Otherwise just delete the existing _cobol-build_ directory,
download a newer version and install it into a subdirectory just as on
original installation.


a note on filenames
-------------------

While COBOL is notoriously case-insensitive, Unix/Linux filesystems
are not, so you must ensure that the case of your filenames matches in
all places:

 - the names of your files
 - the filenames given in `build.txt`
 - your `PROGRAM-ID.`
 - filenames in `COPY` statements
 - module names in `CALL` statements
 
If you work with on a case-insensitive filesystem (eg. on Windows),
you can ignore this, but you will run into problems later when using
TravisCI (because the build runs on Linux and case matters).
 
Beware: changing the case of a filename under Windows will give you
some headaches because for the system both filenaes will still be the
same.


dependencies
------------

You need [GNU make](http://www.gnu.org/software/make/),
[bash](http://tiswww.case.edu/php/chet/bash/bashtop.html) (at least
version 4) and optionally
[inotifywait](https://github.com/rvoicilas/inotify-tools/wiki) for
continuous testing.  Debian/Ubuntu users get everything via `apt
install make bash inotify-tools` if they are not already installed.

You need a recent version of [GnuCOBOL](https://savannah.gnu.org/projects/gnucobol).
Debian/Ubuntu users could try `apt install open-cobol`.

_cobol-build_ has mostly been tested on GnuCOBOL 3.0.0-rc1.  Older
versions should work for the easy cases (eg. static compiles), but
more complicated things (eg. dynamic modules) might fail because of
different compiler options.

If your version is too old or you want to build GnuCOBOL from source,
you can run `sudo make install-gnucobol`.  This will install
GnuCOBOL to `/usr/local`.

Older versions might work, but 

### switching the version of GnuCOBOL

If you want to use another version of GnuCOBOL, change the variable
`GNUCOBOL_SRC` in the `Makefile` before running `sudo make install-gnucobol`.

The TravisCI integration will always install and use the version given
in `GNUCOBOL_SRC` (while using a cache to reduce the build times).

It is probably a good idea to use the same version of GnuCOBOL in both
your local development environment and TravisCI, so change the
Makefile accordingly if you install GnuCOBOL from distribution
packages.


build projects
--------------

Every project to be built should have the following layout:

```
 project/
 +-- build.txt
 `-- src/
     +-- main/
     |   `-- cobol/
     |       +-- source file 1
     |       +-- source file 2
     |       `-- source file ...
     `-- test/
         `-- cobol/
             +-- test case 1
             +-- test case 2
             `-- test driver ...
```

The build process will create some additional directories that will be
removed on `make clean`:

```
 project/
 +-- build.txt
 +-- build/
 |   +-- main/
 |   |   +-- Makefile
 |   |   +-- object file 1
 |   |   +-- object file 2
 |   |   `-- object file ...
 |   `-- test/
 |       +-- UTESTS
 |       +-- UTESTCFG
 |       +-- TESTPRG
 |       +-- SRCPRG
 |       +-- unittest
 |       `-- driver
 +-- src/
 |   +-- main/
 |   |   `-- cobol/
 |   |       +-- source file 1
 |   |       +-- source file 2
 |   |       `-- source file ...
 |   `-- test/
 |       `-- cobol/
 |           +-- test case 1
 |           +-- test case 2
 |           `-- test driver ...
 `-- target/
     +-- binary 1
     +-- module 1
     `-- module ...
```


`build.txt`
-----------

The file `build.txt` tells the build system what to build.  It is a
line based text file that ignores empty lines.  Comments are
prefixed with `#`.

Available commands are:

### `BUILD EXECUTABLE` statement

The `BUILD EXECUTABLE` statement builds an executable program
from one or multiple source files.

```
|-- Format -----------------------------------------------------------
|                                                                    |
|                                               <-------------       |
| >>--BUILD EXECUTABLE--executable-name--USING---source-file-|---->< |
|                                                                    |
|---------------------------------------------------------------------
```

* `executable-name` is the name of the generated executable binary
  without any extension.  It will be put into the `target/` directory.
 

* `source-file` is the name (including the extension) of a source file.
  It will be read from the `src/main/cobol/` directory and can use Copybooks
  from the `src/main/cobol/copy/` directory.
  Source files can be COBOL (`*.cob`,  `*.cbl`) or C (`*.c`).


### `BUILD MODULE` statement

The `BUILD MODULE` statement builds a module that can be loaded 
dynamically from one or multiple source files.

```
|-- Format -----------------------------------------------------------
|                                                                    |
|                                       <-------------               |
| >>--BUILD MODULE--module-name--USING---source-file-|------------>< |
|                                                                    |
|---------------------------------------------------------------------
```

* `module-name` is the name of the generated module without any extension.
  It will be put into the `target/` directory with an extension of `.so`.

* `source-file` is the name (including the extension) of a source file.
  It will be read from the `src/main/cobol/` directory and can use Copybooks
  included in the `src/main/cobol/copy/` directory.
  Source files can be COBOL (`*.cob`,  `*.cbl`) or C (`*.c`).

### `TEST SOURCE` statement

The `TEST SOURCE` statement executes one or more unit tests
that test a given source file.

The unit tests work by first replacing the `PROCEDURE DIVISION` of the
`source-file` by test code generated from every `test-case` and then
compiling and running the resulting executable.

To test dynamically loadable modules, a `driver-program` is needed to
call the module.  `source-file` and `test-case`s are handled as
before, but when running the test the `driver-program` is executed
instead of the module.

```
|-- Format -----------------------------------------------------------
|                                                                    |
| >>--TEST SOURCE--source-file-------------------------------------> |
|                               |-WITH DRIVER--driver-program--      |
|                                                                    |
|            <-----------                                            |
| >---USING---test-case-|----------------------------------------->< |
|                                                                    |
|---------------------------------------------------------------------
```

* `source-file` is the name (including the extension) of the source file
  to test.
  It will be read from the `src/main/cobol/` directory and can use Copybooks
  included in the `src/main/cobol/copy/` directory.
  Source files for tests can only be COBOL (`*.cob`,  `*.cbl`).

* When `WITH DRIVER` specifies the name of the `driver-program`,
  `source-file` is expected to compile to a dynamically loadable module.
  `driver-program` is the name of source file (including the extension)
  of the driver.
  It will be read from the `src/test/cobol/` directory and can use Copybooks
  included in the `src/main/cobol/copy/` directory.
  A driver can be COBOL (`*.cob`,  `*.cbl`) or C (`*.c`).

* `test-case` is the name of a test case (including the extension)
  to be executed.
  It will be read from the `src/test/cobol/` directory.
  Test cases can only be COBOL (`*.cob`,  `*.cbl`).
