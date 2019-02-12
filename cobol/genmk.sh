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

declare -A TARGETS TESTS

while IFS= read -r LINE; do

    # remove comments
    LINE="${LINE%%#*}"

    # skip empty lines
    [[ $LINE =~ ^[[:space:]]*$ ]] && continue

    set -- $LINE

    COMMAND="$1"
    shift
    
    case "$COMMAND" in
	
	STATIC|static)
	    TARGET="$1"
	    shift 2
	    echo -n "\$(TARGETDIR)/$TARGET:"
	    for SOURCE in "$@"; do
		echo -n " \$(SOURCEDIR)/$SOURCE"
	    done
	    echo
	    echo '	$(COBC) -x $(COBFLAGS) -o $@ $<'
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

echo -n "build:"
for TARGET in ${!TARGETS[*]}; do
    echo -n " \$(TARGETDIR)/$TARGET"
done
echo

echo -n "test: prepare-test"
for TEST in ${!TESTS[*]}; do
    echo -n " \$(TESTRUNDIR)/$TEST"
done
echo

echo 'prepare-test:'
echo '	mkdir -p $(TESTRUNDIR)'
echo '	echo ZUTZCWS > $(TESTRUNDIR)/UTSTCFG'
	
