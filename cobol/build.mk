COBFLAGS := --std=ibm -O2

%: %.o

%.o: %.cbl
