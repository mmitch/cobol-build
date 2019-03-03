#!/bin/bash

TESTPASS="$1"
TESTFAIL="$2"

HAVE_TPUT="$(command -v tput || true)"

count()
{
    local FILE="$1"
    COUNT=0

    [ -r "$FILE" ] || return

    while read -r; do
	COUNT=$(( COUNT + 1 ))
    done < "$FILE"
}

TPUT()
{
    [ "$HAVE_TPUT" ] && tput "$@"
}

count "$TESTPASS"
PASS=$COUNT

count "$TESTFAIL"
FAIL=$COUNT

TPUT setaf 3
echo
echo "--------------------------------"
echo "    TEST SUMMARY:"
TPUT bold
if [ $PASS = 0 ] && [ $FAIL = 0 ]; then
    TPUT setaf 1
    echo "    NO TEST SUITES RUN"
else
    if [ $PASS -gt 0 ]; then
	TPUT setaf 2
	printf "  %8d TEST SUITES PASSED\n" $PASS
    fi
    if [ $FAIL -gt 0 ]; then
	TPUT setaf 1
	printf "  %8d TEST SUITES FAILED\n" $FAIL
    fi
fi
TPUT sgr0
TPUT setaf 3
echo "--------------------------------"
TPUT sgr0
echo
