# GNUCOBOL installation

GNUCOBOL_SRC := http://gnu.c3sl.ufpr.br/alpha/gnucobol/gnucobol-3.0-rc1.tar.xz

export GNUCOBOL_SRC

# build system directories

BUILDROOT  := cobol
SOURCEDIR  := src/main/cobol
COPYDIR    := src/main/cobol/copy
TESTDIR    := src/test/cobol
BUILDDIR   := build/main/
TESTRUNDIR := build/test/
TARGETDIR  := target

export SOURCEDIR COPYDIR BUILDDIR TARGETDIR TESTDIR TESTRUNDIR

# COBOL compiler and flags

COBC     ?= cobc
COBFLAGS ?= --std=ibm -I $(COPYDIR)

export COBC COBFLAGS

# COBOL Unit Test Framework

CUTPATH := cobol-unit-test/src/main/cobol
CUTCOPY := $(abspath $(CUTPATH)/copy)
ZUTZCPC := $(abspath ZUTZCPC)

export CUTCOPY ZUTZCPC

# Makefile recursion

RECIPES     := $(wildcard $(BUILDROOT)/*/build.txt)
MAKEFILES   := $(RECIPES:/build.txt=/build/Makefile)
SUBDIRS     := $(RECIPES:/build.txt=)
SUBMAKEFILE := $(abspath Makefile.sub)
GENMK       := $(abspath genmk.sh)

export GENMK

define make_subdirs
	for SUBDIR in $(SUBDIRS); do \
		$(MAKE) -C $$SUBDIR -f $(SUBMAKEFILE) $(1) || exit; \
	done
endef

define make_builddirs
	for SUBDIR in $(SUBDIRS); do \
		$(MAKE) -C $$SUBDIR/ -f $(BUILDDIR)/Makefile $(1) || exit; \
	done
endef

# targets

.PHONY: all build genmk clean test install-cobol

all: build test

build: genmk
	$(call make_builddirs,build)

genmk:
	$(call make_subdirs,genmk)
clean:
	rm -f *~
	rm -f ZUTZCPC
	$(call make_subdirs,clean)

test:	check-submodules ZUTZCPC genmk
	$(call make_builddirs,test)

check-submodules:
	git submodule init
	git submodule update

# precompiler for unit-tests
$(ZUTZCPC): $(CUTPATH)/ZUTZCPC.CBL
	$(COBC) -x $(COBFLAGS) -o $@ $<

install-gnucobol:
	$(MAKE) -C gnucobol3 download install
