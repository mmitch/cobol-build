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

You need a recent version of [GnuCOBOL](https://savannah.gnu.org/projects/gnucobol).
Debian/Ubuntu users could try ``apt install open-cobol``.

If your version is too old or you want to build GnuCOBOL from source,
you can run ``sudo make install-gnucobol``.  This will install
GnuCOBOL to ``/usr/local``.

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
