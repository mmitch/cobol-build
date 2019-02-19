SOURCEDIR  := src/main/cobol
COPYDIR    := src/main/cobol/copy
BUILDDIR   := build/main/
TARGETDIR  := target
TESTDIR    := src/test/cobol
TESTRUNDIR := build/test/

export SOURCEDIR COPYDIR BUILDDIR TARGETDIR TESTDIR TESTRUNDIR

COBC       := cobc
COBFLAGS   := --std=ibm -I $(COPYDIR)
CUTCOPY    := $(CUTPATH)/src/main/cobol/copy

export COBC COBFLAGS CUTCOPY

RECIPES    := $(wildcard */build.txt)
MAKEFILES  := $(RECIPES:/build.txt=/build/Makefile)
SUBDIRS    := $(RECIPES:/build.txt=)

define make_subdirs
	for SUBDIR in $(SUBDIRS); do \
		$(MAKE) -C $$SUBDIR -f ../Makefile.sub $(1) || exit; \
	done
endef

define make_builddirs
	for SUBDIR in $(SUBDIRS); do \
		$(MAKE) -C $$SUBDIR/ -f $(BUILDDIR)/Makefile $(1) || exit; \
	done
endef

.PHONY: build clean test

build: genmk
	$(call make_builddirs,build)

clean:
	rm -f *~
	rm -f ZUTZCPC
	$(call make_subdirs,clean)

test: ZUTZCPC genmk
	$(call make_builddirs,test)

genmk:
	$(call make_subdirs,genmk)

# precompiler for unit-tests
ZUTZCPC: $(CUTPATH)/src/main/cobol/ZUTZCPC.CBL
	$(COBC) -x $(COBFLAGS) -o $@ $<
