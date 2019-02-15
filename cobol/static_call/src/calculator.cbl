       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCULATOR.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 ARGUMENTS  PIC X(128).
       01 OPERATION  PIC X(1).
           88 ADDITION    VALUE '+'.
           88 SUBTRACTION VALUE '-'.
       01 IO.
       COPY data.

       PROCEDURE DIVISION.
           ACCEPT ARGUMENTS FROM COMMAND-LINE END-ACCEPT
           UNSTRING ARGUMENTS DELIMITED BY ALL SPACES
               INTO VALUE-1 OPERATION VALUE-2
           END-UNSTRING

           EVALUATE TRUE
               WHEN ADDITION
                   CALL 'addition' USING IO
                   PERFORM DISPLAY-RESULT
               WHEN SUBTRACTION
                   CALL 'subtraction' USING IO
                   PERFORM DISPLAY-RESULT
               WHEN OTHER
                   DISPLAY "unknown operation"
           END-EVALUATE
           GOBACK
           .

       DISPLAY-RESULT SECTION.
           DISPLAY "the result is " RESULT
           EXIT.
           
