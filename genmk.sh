#!/bin/bash

HAVE_TPUT="$(command -v tput || true)"

echo_tput()
{
    [ "$HAVE_TPUT" ] || return 0
    echo "$*"
}

abend()
{
    local MESSAGE="$*"
    local POSITION="[$SUBDIR/build.txt:$LINE_NUMBER]"
    exec 1>&2
    [ "$HAVE_TPUT" ] && tput setaf 1 && tput bold
    [ "$LINE" ] && echo "$POSITION $LINE"
    echo "$POSITION ${MESSAGE:-'unkown error'}"
    [ "$HAVE_TPUT" ] && tput sgr0

    [ "$OUTPUT" != '-stdout' ] && rm "$OUTPUT"
	
    exit 1
}

ensure_file_exists()
{
    local FILE="$1" TYPE="$2"

    [ -e "$FILE" ] || abend "$TYPE \`$FILE' referenced in \`$LINE' does not exist"
    [ -r "$FILE" ] || abend "$TYPE \`$FILE' referenced in \`$LINE' is not readable"
}

check_token()
{
    TOKEN="${1^}"
    local TOKEN_ORIG="$1" TOKEN_TYPE="$2"
    shift 2

    for T in $*; do
	if [ "$TOKEN" = "$T" ]; then
	    return
	fi
    done

    abend "unknown $TOKEN_TYPE: $TOKEN_ORIG   valid ${TOKEN_TYPE}s: $*"
}

check_not_empty()
{
    local TOKEN="$1" TYPE="$2"

    if [ -z "$TOKEN" ]; then
	abend "expected $TYPE, but none given"
    fi
}

parse_build()
{
    check_token "$1" 'build target type' EXECUTABLE MODULE
    TYPE="$TOKEN"
    shift

    case "$TYPE" in

	EXECUTABLE)
	    TARGET="$1"
	    check_not_empty "$TARGET" 'executable filename'
	    LINKFLAG=-x
	    ;;

	MODULE)
	    TARGET="$1.so"
	    check_not_empty "$TARGET" 'module filename'
	    LINKFLAG=-b
	    ;;

	*)
	    abend "broken type token check for $TYPE"
	;;
    esac
    shift

    [ "${1^^}" = USING ] || abend "expected USING, but got: $1"
    shift

    echo -n "\$(TARGETDIR)/$TARGET:"
    FIRSTOBJECT=""
    for SOURCE in "$@"; do
	ensure_file_exists "$SOURCEDIR/$SOURCE" SOURCE-FILE

	OBJECT="\$(BUILDDIR)/${SOURCE%.*}.o"
	OBJECTS[$OBJECT]="$SOURCE"
	echo -n " $OBJECT"

	if [ -z "$FIRSTOBJECT" ]; then
	    FIRSTOBJECT="$OBJECT"
	fi
    done
    echo
    echo "	@echo [LINK] \$(SUBDIR)/\$@"
    echo "	\$(Q)\$(COBC) $LINKFLAG \$(COBFLAGS) -o \$@ \$^"
    echo
    TARGETS[$TARGET]="$*"

    if [ "$TYPE" = EXECUTABLE ]; then
	# main program needs both -c and -x, otherwise <undefined reference to `main'>
	OBJECTFLAGS[$FIRSTOBJECT]="-x"
    fi
}

write_test()
{
    TEST="$1"
    shift

    echo "\$(TESTRUNDIR)/$TEST:"
    echo "	\$(Q)cp \$(SOURCEDIR)/$TEST \$(TESTRUNDIR)/SRCPRG"
    for SOURCE in "$@"; do
	ensure_file_exists "$TESTDIR/$SOURCE" TEST-SOURCE

	echo "	\$(call prepare_test,$SOURCE,-x,unittest)"
	echo "	\$(call execute_test,unittest)"
    done
    echo

    TESTS[$TEST]="$*"
}

write_test_with_driver()
{
    TEST="$1"
    DRIVER="$2"
    shift 2

    echo "\$(TESTRUNDIR)/$TEST: \$(COPYBOOKS)"
    echo "	@echo [COBC,LINK] \$(SUBDIR)/\$(TESTDIR)/$DRIVER"
    echo "	\$(Q)\$(COBC) -x \$(COBFLAGS) -o \$(TESTRUNDIR)/driver \$(TESTDIR)/$DRIVER"
    echo "	\$(Q)cp \$(SOURCEDIR)/$TEST \$(TESTRUNDIR)/SRCPRG"
    for SOURCE in "$@"; do
	ensure_file_exists "$TESTDIR/$SOURCE" TEST-SOURCE

	MODULE="${TEST%.*}.so"
	echo "	\$(call prepare_test,$SOURCE,-b,$MODULE)"
	echo "	\$(call execute_test,driver)"
    done
    echo

    TESTS[$TEST]="$*"
}

parse_test()
{
    check_token "$1" 'test target type' SOURCE
    shift

    SOURCE="$1"
    check_not_empty "$SOURCE" 'test source filename'
    shift

    if [ "${1^^}" = WITH ] && [ "${2^^}" = DRIVER ]; then
	DRIVER="$3"
	shift 3

	ensure_file_exists "$TESTDIR/$DRIVER" DRIVER
    else
	DRIVER=
    fi

    [ "${1^^}" = USING ] || abend "expected USING or WITH DRIVER, but got: $2"
    shift

    if [ $DRIVER ]; then
	write_test_with_driver "$SOURCE" "$DRIVER" "$@"
    else
	write_test "$SOURCE" "$@"
    fi
}

###########

trap abend ERR
set -e

if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
    abend 'need at least bash v4 for associative arrays'
fi

OUTPUT="$1"
if [ "$OUTPUT" ]; then
    exec > "$OUTPUT"
else
    OUTPUT="-stdout"
fi


echo '# $(1) executable to run'
echo 'define execute_test'
echo      "	@echo '[TEST]     ' \$(SUBDIR)/\$@"
echo_tput "	@tput setaf 3"
echo      "	\$(Q)cd \$(TESTRUNDIR) && if ./\$(1); then \\"
echo_tput "		tput bold;tput setaf 2; \\"
echo      "		echo 'TEST PASS'; \\"
echo      "		echo '\$@' >> \$(TESTPASS); \\"
echo_tput "		tput sgr0; \\"
echo      "	else \\"
echo_tput "		tput bold;tput setaf 1; \\"
echo      "		echo 'TEST FAILED'; \\"
echo      "		echo '\$@' >> \$(TESTFAIL); \\"
echo_tput "		tput sgr0; \\"
echo      "	fi"
echo 'endef'

cat <<'EOF'

# $(1) source file  $(2) compile flag (-x or -b)  $(3) target file
define prepare_test
	$(Q)cp $(TESTDIR)/$(1) $(TESTRUNDIR)/UTESTS
	@echo '[ZUTZCPC]  ' $(SUBDIR)/$@
	$(Q)cd $(TESTRUNDIR) && ./ZUTZCPC
	@echo '[COBC,LINK]' $(SUBDIR)/$@
	$(Q)$(COBC) $(2) $(COBFLAGS) -I $(CUTCOPY) -o $(TESTRUNDIR)/$(3) $(TESTRUNDIR)/TESTPRG
endef

COPYBOOKS := $(BUILDBASE)/copybook.timestamp

.PHONY: build test update-copybooks prepare-test

update-copybooks:
	$(Q)if [ -d $(COPYDIR) ]; then \
	    touch -r "$$(find -L $(COPYDIR) build.txt -type f -printf "%T@ %p\n" | sort -rn | head -1 | (read -r TIME FILE; echo $$FILE))" $(COPYBOOKS); \
	else \
	    touch -r build.txt $(COPYBOOKS); \
	fi

EOF

declare -A TARGETS OBJECTS OBJECTFLAGS TESTS

LINE_NUMBER=0
while IFS= read -r LINE; do

    LINE_NUMBER=$(( LINE_NUMBER + 1 ))
    
    # remove comments
    LINE="${LINE%%#*}"

    # remove CRLF if from windows
    LINE="${LINE%$'\r'}"

    # skip empty lines
    [[ $LINE =~ ^[[:space:]]*$ ]] && continue

    set -- $LINE

    check_token "$1" 'verb' BUILD TEST
    VERB="$TOKEN"
    shift
    
    case "$VERB" in

	BUILD)
	    parse_build "$@"
	    ;;

	TEST)
	    parse_test "$@"
	    ;;
	
	*)
	    abend "broken verb check for $VERB"
	;;
    esac
    
done

for OBJECT in ${!OBJECTS[*]}; do
    SOURCE="${OBJECTS[$OBJECT]}"
    EXTRAFLAGS="${OBJECTFLAGS[$OBJECT]}"
    echo "$OBJECT: \$(SOURCEDIR)/$SOURCE \$(COPYBOOKS)"
    echo "	@echo [COBC] \$(SUBDIR)/\$<"
    echo "	\$(Q)\$(COBC) -c $EXTRAFLAGS \$(COBFLAGS) -o \$@ \$<"
    echo
done

echo -n "build: update-copybooks"
for TARGET in ${!TARGETS[*]}; do
    echo -n " \$(TARGETDIR)/$TARGET"
done
echo
echo

echo -n "test: build prepare-test"
for TEST in ${!TESTS[*]}; do
    echo -n " \$(TESTRUNDIR)/$TEST"
done
echo
echo

cat <<'EOF'
prepare-test: $(TESTRUNDIR)/ZUTZCPC
	$(Q)echo ZUTZCWS > $(TESTRUNDIR)/UTSTCFG

$(TESTRUNDIR)/ZUTZCPC: $(CUTPATH)/ZUTZCPC.CBL
	@echo [COBC] $(SUBDIR)/$@
	$(Q)$(COBC) -x $(COBFLAGS) -o $@ $<
EOF
