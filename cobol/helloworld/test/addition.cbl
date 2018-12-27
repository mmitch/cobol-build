           TESTSUITE 'simple addition tests for helloworld.cob'

           TESTCASE 'one plus two equals three'
           MOVE 1 TO SUMMAND-1
           MOVE 2 TO SUMMAND-2
           PERFORM U01-CALCULATION
           EXPECT RESULT TO BE NUMERIC 3

           TESTCASE 'ten plus five equals fifteen'
           MOVE 10 TO SUMMAND-1
           MOVE  5 TO SUMMAND-2
           PERFORM U01-CALCULATION
           EXPECT RESULT TO BE NUMERIC 15
