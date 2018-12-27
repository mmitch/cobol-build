COBC    := cobc
SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)

define make_subdirs
	for SUBDIR in $(SUBDIRS); do \
		if [ -e $$SUBDIR/Makefile ]; then \
			make -C $$SUBDIR $(1); \
		else \
			make -C $$SUBDIR -f ../Makefile $(1) BINARY=$$SUBDIR; \
		fi \
	done
endef

build-all:
	$(call make_subdirs,build)

clean-all:
	rm -f *~
	$(call make_subdirs,clean)

SRCS = $(wildcard src/*.cbl)

build:	$(BINARY)

$(BINARY): $(SRCS)
	$(COBC) -x -o $(BINARY) $(SRCS)

clean:
	rm -f $(BINARY)
	rm -f src/*~
