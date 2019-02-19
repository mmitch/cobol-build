       IDENTIFICATION DIVISION.
       PROGRAM-ID. subtraction.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * empty, but needed for the tests to put a copybook in here
       LINKAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION USING IO.
           PERFORM SUBTRACTION
           GOBACK
           .

       SUBTRACTION SECTION.
           SUBTRACT VALUE-2 FROM VALUE-1 GIVING RESULT
       EXIT.
