# COBOL build system main Makefile


# GnuCOBOL installation
#
GNUCOBOL_SRC ?= http://gnu.c3sl.ufpr.br/alpha/gnucobol/gnucobol-3.0-rc1.tar.xz

export GNUCOBOL_SRC


# what to build
#
PROJECTROOT ?= examples


# verbosity (run `make V=1' for extra output)
#
ifeq ("$(origin V)", "command line")
  VERBOSE := $(V)
else
  VERBOSE := 0
endif
ifeq ($(VERBOSE),1)
  Q :=
  SILENT :=
else
  Q := @
  SILENT := -s
endif

export Q


# per project subdirectories
#
SOURCEDIR  := src/main/cobol
COPYDIR    := src/main/cobol/copy
TESTDIR    := src/test/cobol
BUILDBASE  := build
BUILDDIR   := build/main
TESTRUNDIR := build/test
TARGETDIR  := target

export SOURCEDIR COPYDIR TESTDIR BUILDBASE BUILDDIR TESTRUNDIR TARGETDIR


# COBOL compiler and flags
#
COBC     ?= cobc
COBFLAGS ?= --std=ibm -I $(COPYDIR)

export COBC COBFLAGS


# COBOL Unit Test Framework
#
CUTPATH := $(abspath cobol-unit-test/src/main/cobol)
CUTCOPY := $(CUTPATH)/copy

export CUTPATH CUTCOPY


# Makefile recursion
#
SUBMAKEFILE := $(abspath Makefile.sub)
GENMK       := $(abspath genmk.sh)
GENMAKEFILE := build/Makefile

RECIPES     := $(wildcard $(PROJECTROOT)/*/build.txt)
SUBDIRS     := $(RECIPES:/build.txt=)

FIRSTSUBDIR := $(word 1, $(SUBDIRS))
TESTPASS    := $(abspath $(FIRSTSUBDIR)/build/test-ok)
TESTFAIL    := $(abspath $(FIRSTSUBDIR)/build/test-fail)

export GENMK GENMAKEFILE TESTPASS TESTFAIL

define make_subdirs
	$(Q)for SUBDIR in $(SUBDIRS); do \
		SUBDIR=$$SUBDIR $(MAKE) $(SILENT) -C $$SUBDIR -f $(SUBMAKEFILE) $(1) || exit; \
	done
endef

define make_builddirs
	$(Q)for SUBDIR in $(SUBDIRS); do \
		SUBDIR=$$SUBDIR $(MAKE) -C $$SUBDIR/ $(SILENT) -f $(GENMAKEFILE) $(1) || exit; \
	done
endef


# targets
#
.PHONY: all build genmk clean test install-cobol init-test-counters

all: build test

build: genmk
	$(call make_builddirs,build)

genmk:
	$(call make_subdirs,genmk)
clean:
	@echo [CLEAN] $(BUILDROOT)
	$(Q)rm -f *~
	$(call make_subdirs,clean)

test:	build check-submodules init-test-counters
	$(call make_builddirs,test)
	@./teststats.sh "$(TESTPASS)" "$(TESTFAIL)"

init-test-counters:
	$(Q)echo -n > $(TESTPASS)
	$(Q)echo -n > $(TESTFAIL)

autotest: test
	@echo
	@echo
	@echo "watching for changes..."
	@echo
	$(Q)while inotifywait --recursive --quiet --quiet --event modify --event move --event delete $(PROJECTROOT); do \
		$(MAKE) test; \
		echo ; \
		echo ; \
		echo "watching for changes..."; \
		echo ; \
	done

check-submodules:
	$(Q)git submodule init
	$(Q)git submodule update

install-gnucobol:
	$(MAKE) -C gnucobol3 download install
