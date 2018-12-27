export GNUCOBOL_SRC := http://gnu.c3sl.ufpr.br/alpha/gnucobol/gnucobol-3.0-rc1.tar.xz

all:	build test

build:
	make -C cobol build-all

clean:
	rm -f *~
	make -C cobol clean-all

test:
	echo running tests - coming soon

install-gnucobol:
	make -C gnucobol3 download install
