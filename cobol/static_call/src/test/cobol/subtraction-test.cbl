           TESTSUITE 'subtraction tests for module subtraction.cbl'

           TESTCASE 'three minus two equals one'
           MOVE 3 TO VALUE-1
           MOVE 2 TO VALUE-2
           PERFORM SUBTRACTION
           EXPECT RESULT TO BE NUMERIC 1

           TESTCASE 'minus ten minus five equals minus fifteen'
           MOVE -10 TO VALUE-1
           MOVE  5 TO VALUE-2
           PERFORM SUBTRACTION
           EXPECT RESULT TO BE NUMERIC -15
