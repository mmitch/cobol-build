cobol-travis
============

[![Build Status](https://travis-ci.org/mmitch/cobol-travis.svg?branch=master)](https://travis-ci.org/mmitch/cobol-travis)

This repository contains a template for a COBOL development
environment with the following features:

- basic Makefiles with ``build``, ``test`` and ``clean`` targets
- [Cobol unit testing framework](https://github.com/neopragma/cobol-unit-test)
  included
- ready-to-use [TravisCI integration](https://travis-ci.org)


how to use
----------
 
1. clone or fork this repository
2. put your code in ``cobol/$PROJECT/src``
   - use ``*.cbl`` or ``*.cob`` as extension
   - ``$PROJECT`` will be the name of the generated executable
   - multiple source files will be combined into the executable, but
     the tests currently only run correctly with a single source file
3. put your tests in ``cobol/$PROJECT/test``
   - use ``*.cbl`` or ``*.cob`` as extension
4. remove the demo project at ``cobol/helloworld``
5. update this ``README.md``
   - at least switch the build status button to _your_ repository


dependencies
------------

You need [GNU make](http://www.gnu.org/software/make/) and
[bash](http://tiswww.case.edu/php/chet/bash/bashtop.html) (at least
version 4).  Debian/Ubuntu users get both via ``apt install make
bash`` if they are not already installed.

You need a recent version of [GnuCOBOL](https://savannah.gnu.org/projects/gnucobol).
Debian/Ubuntu users could try ``apt install open-cobol``.

If your version is too old or you want to build GnuCOBOL from source,
you can run ``sudo make install-gnucobol``.  This will install
GnuCOBOL to ``/usr/local``.

Older versions might work, but 

### switching the version of GnuCOBOL

If you want to use another version of GnuCOBOL, change the variable
``GNUCOBOL_SRC`` in the ``Makefile`` before running ``sudo make
install-gnucobol``.

The TravisCI integration will always install and use the version given
in ``GNUCOBOL_SRC`` (while using a cache to reduce the build times).

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
removed on ``make clean``:

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

The file ``build.txt`` tells the build system what to build.  It is a
line based text file that ignores empty lines.  Comments are
prefixed with ``#``.

Available commands are:

### `BUILD BINARY` statement

The `BUILD BINARY` statement builds an executable program
from one or multiple source files.

```
|-- Format -----------------------------------------------------------
|                                                                    |
|                                      <-------------                |
| >>--BUILD BINARY--binary-name--USING--source-file-|------------->< |
|                                                                    |
|---------------------------------------------------------------------
```

* `binary-name` is the name of the generated binary without any extension.
  It will be put into the `target/` directory.
 

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
|                                      <-------------                |
| >>--BUILD MODULE--module-name--USING--source-file-|------------->< |
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
|           <-----------                                             |
| >---USING--test-case-|------------------------------------------>< |
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
