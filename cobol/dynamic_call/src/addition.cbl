       IDENTIFICATION DIVISION.
       PROGRAM-ID. addition.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * empty, but needed for the tests to put a copybook in here
       LINKAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION USING IO.
           PERFORM ADDITION
           GOBACK
           .

       ADDITION SECTION.
           ADD VALUE-1 TO VALUE-2 GIVING RESULT
       EXIT.
