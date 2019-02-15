       IDENTIFICATION DIVISION.
       PROGRAM-ID. subtraction.

       DATA DIVISION.
       LINKAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION USING IO.
           SUBTRACT VALUE-2 FROM VALUE-1 GIVING RESULT
           GOBACK
           .
