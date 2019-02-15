       IDENTIFICATION DIVISION.
       PROGRAM-ID. addition.

       DATA DIVISION.
       LINKAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION USING IO.
           ADD VALUE-1 TO VALUE-2 GIVING RESULT
           GOBACK
           .
