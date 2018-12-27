COBC    := cobc
SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)

build-all:
	for SUBDIR in $(SUBDIRS); do \
		if [ -e $$SUBDIR/Makefile ]; then \
			make -C $$SUBDIR build; \
		else \
			make -C $$SUBDIR -f ../Makefile build BINARY=$$SUBDIR; \
		fi \
	done

clean-all:
	rm -f *~
	for SUBDIR in $(SUBDIRS); do \
		if [ -e $$SUBDIR/Makefile ]; then \
			make -C $$SUBDIR clean; \
		else \
			make -C $$SUBDIR -f ../Makefile clean BINARY=$$SUBDIR; \
		fi \
	done

SRCS = $(wildcard src/*.cbl)

build:
	$(COBC) -x -o $(BINARY) $(SRCS)

clean:
	rm -f $(BINARY)
	rm -f src/*~
