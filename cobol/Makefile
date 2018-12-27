SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)
COBC    := cobc
CUTCOPY := $(CUTPATH)/src/main/cobol/copy

define make_subdirs
	for SUBDIR in $(SUBDIRS); do \
		if [ -e $$SUBDIR/Makefile ]; then \
			make -C $$SUBDIR $(1); \
		else \
			make -C $$SUBDIR -f ../Makefile $(1) BINARY=$$SUBDIR; \
		fi \
	done
endef

.PHONY: build-all clean-all test-all build clean test

build-all:
	$(call make_subdirs,build)

clean-all:
	rm -f *~
	rm -f ZUTZCPC
	$(call make_subdirs,clean)

test-all: ZUTZCPC
	$(call make_subdirs,test)

# precompiler for unit-tests
ZUTZCPC: $(CUTPATH)/src/main/cobol/ZUTZCPC.CBL
	$(COBC) -x --std=ibm -o $@ $<


# targets for projekt subdirectories when no Makefile exists

SRCS = $(wildcard src/*.cbl)

build:	$(BINARY)

$(BINARY): $(SRCS)
	$(COBC) -x --std=ibm -o $(BINARY) $(SRCS)

clean:
	rm -f $(BINARY)
	rm -f unittest SRCPRG UTSTCFG UTESTS TESTPRG
	rm -f src/*~
	rm -f test/*~

TESTS = $(wildcard test/*.cbl)

test:
	echo ZUTZCWS > UTSTCFG
	for TEST in $(TESTS); do \
		cp $(SRCS) SRCPRG && \
		cp $$TEST UTESTS && \
		../ZUTZCPC && \
		$(COBC) -x --std=ibm -o unittest -I $(CUTCOPY) TESTPRG && \
		./unittest; \
	done
