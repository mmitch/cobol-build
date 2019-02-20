export GNUCOBOL_SRC := http://gnu.c3sl.ufpr.br/alpha/gnucobol/gnucobol-3.0-rc1.tar.xz
export CUTPATH=$(abspath cobol-unit-test/)

all: build test

check-submodules:
	git submodule init
	git submodule update

build:
	$(MAKE) -C cobol build

clean:
	rm -f *~
	$(MAKE) -C cobol clean

test:	check-submodules
	$(MAKE) -C cobol test

install-gnucobol:
	$(MAKE) -C gnucobol3 download install
