#!/bin/bash

abend()
{
    echo "$0: $*" 1>&2
    exit 1
}

if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
    abend 'need at least bash v4 for associative arrays'
fi

echo ".PHONY: build test prepare-test"
echo

declare -A TARGETS OBJECTS MAINS TESTS

while IFS= read -r LINE; do

    # remove comments
    LINE="${LINE%%#*}"

    # skip empty lines
    [[ $LINE =~ ^[[:space:]]*$ ]] && continue

    set -- $LINE

    COMMAND="$1"
    shift
    
    case "$COMMAND" in
	
	BINARY|binary)
	    TARGET="$1"
	    shift 2
	    echo -n "\$(TARGETDIR)/$TARGET:"
	    MAIN=""
	    for SOURCE in "$@"; do
		OBJECT="\$(BUILDDIR)/${SOURCE%.*}.o"
		OBJECTS[$OBJECT]="$SOURCE"
		echo -n " $OBJECT"

		if [ -z "$MAIN" ]; then
		    MAIN="$OBJECT"
		fi
	    done
	    echo
	    echo '	$(COBC) -x $(COBFLAGS) -o $@ $^'
	    echo
	    TARGETS[$TARGET]="$*"

	    # main program needs both -c and -x, otherwise <undefined reference to `main'>
	    MAINS[$MAIN]="-x"
	    ;;
	
	MODULE|module)
	    TARGET="$1.so"
	    shift 2
	    echo -n "\$(TARGETDIR)/$TARGET:"
	    for SOURCE in "$@"; do
		OBJECT="\$(BUILDDIR)/${SOURCE%.*}.o"
		OBJECTS[$OBJECT]="$SOURCE"
		echo -n " $OBJECT"
	    done
	    echo
	    echo '	$(COBC) -b $(COBFLAGS) -o $@ $^'
	    echo
	    TARGETS[$TARGET]="$*"
	    ;;
	
	TEST|test)
	    TEST="$1"
	    shift 2
	    echo "\$(TESTRUNDIR)/$TEST:"
	    echo "	cp \$(SOURCEDIR)/$TEST \$(TESTRUNDIR)/SRCPRG"
	    for SOURCE in "$@"; do
		cat <<EOF
	cp \$(TESTDIR)/$SOURCE \$(TESTRUNDIR)/UTESTS
	( \\
		cd \$(TESTRUNDIR) && \\
		../../ZUTZCPC && \\
		\$(COBC) -x \$(COBFLAGS) -o unittest -I \$(CUTCOPY) TESTPRG && \\
		./unittest \\
	)
EOF
	    done
	    echo
	    TESTS[$TEST]="$*"
	    ;;
	
	*)
	    abend "$0: unknown command word: $COMMAND"
	;;
    esac
    
done

for OBJECT in ${!OBJECTS[*]}; do
    SOURCE="${OBJECTS[$OBJECT]}"
    MAIN="${MAINS[$OBJECT]}"
    echo "$OBJECT: \$(SOURCEDIR)/$SOURCE"
    echo "	\$(COBC) -c $MAIN \$(COBFLAGS) -o \$@ \$<"
    echo
done

echo -n "build:"
for TARGET in ${!TARGETS[*]}; do
    echo -n " \$(TARGETDIR)/$TARGET"
done
echo
echo

echo -n "test: prepare-test"
for TEST in ${!TESTS[*]}; do
    echo -n " \$(TESTRUNDIR)/$TEST"
done
echo
echo

echo 'prepare-test:'
echo '	mkdir -p $(TESTRUNDIR)'
echo '	echo ZUTZCWS > $(TESTRUNDIR)/UTSTCFG'
	
