#!/bin/bash

abend()
{
    exec 1>&2
    HAVE_TPUT="$(command -v tput || true)"
    [ "$HAVE_TPUT" ] && tput setaf 1 && tput bold
    echo "$0: $*"
    [ "$HAVE_TPUT" ] && tput sgr0

    [ $OUTPUT != '-stdout' ] && rm "$OUTPUT"
	
    exit 1
}

parse_build()
{
    TYPE="$1"
    shift

    case "$TYPE" in

	BINARY|binary)
	    TARGET="$1"
	    LINKFLAG=-x
	    TYPE=BINARY
	    ;;

	MODULE|module)
	    TARGET="$1.so"
	    LINKFLAG=-b
	    TYPE=MODULE
	    ;;

	*)
	    abend "unknown build target type: $TYPE"
	;;
    esac
    shift

    [ "$1" = USING ] || abend "expected USING, but got: $2"
    shift

    echo -n "\$(TARGETDIR)/$TARGET:"
    FIRSTOBJECT=""
    for SOURCE in "$@"; do
	OBJECT="\$(BUILDDIR)/${SOURCE%.*}.o"
	OBJECTS[$OBJECT]="$SOURCE"
	echo -n " $OBJECT"

	if [ -z "$FIRSTOBJECT" ]; then
	    FIRSTOBJECT="$OBJECT"
	fi
    done
    echo
    echo "	\$(COBC) $LINKFLAG \$(COBFLAGS) -o \$@ \$^"
    echo
    TARGETS[$TARGET]="$*"

    if [ $TYPE = BINARY ]; then
	# main program needs both -c and -x, otherwise <undefined reference to `main'>
	OBJECTFLAGS[$FIRSTOBJECT]="-x"
    fi
}

###########

if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
    abend 'need at least bash v4 for associative arrays'
fi

OUTPUT="$1"
if [ $OUTPUT ]; then
    exec > "$OUTPUT"
else
    OUTPUT="-stdout"
fi

echo ".PHONY: build test prepare-test"
echo

declare -A TARGETS OBJECTS OBJECTFLAGS TESTS

while IFS= read -r LINE; do

    # remove comments
    LINE="${LINE%%#*}"

    # skip empty lines
    [[ $LINE =~ ^[[:space:]]*$ ]] && continue

    set -- $LINE

    VERB="$1"
    shift
    
    case "$VERB" in

	BUILD|build)
	    parse_build "$@"
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
	    abend "unknown verb: $VERB"
	;;
    esac
    
done

for OBJECT in ${!OBJECTS[*]}; do
    SOURCE="${OBJECTS[$OBJECT]}"
    OBJECTFLAGS="${OBJECTFLAGS[$OBJECT]}"
    echo "$OBJECT: \$(SOURCEDIR)/$SOURCE"
    echo "	\$(COBC) -c $OBJECTFLAGS \$(COBFLAGS) -o \$@ \$<"
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
	
