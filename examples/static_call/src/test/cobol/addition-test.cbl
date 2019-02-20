           TESTSUITE 'addition tests for module addition.cbl'

           TESTCASE 'one plus two equals three'
           MOVE 1 TO VALUE-1
           MOVE 2 TO VALUE-2
           PERFORM ADDITION
           EXPECT RESULT TO BE NUMERIC 3

           TESTCASE 'minus five plus fifteen equals ten'
           MOVE -5 TO VALUE-1
           MOVE 15 TO VALUE-2
           PERFORM ADDITION
           EXPECT RESULT TO BE NUMERIC 10
