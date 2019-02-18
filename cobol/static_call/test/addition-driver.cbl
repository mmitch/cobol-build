       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADDITION-DRIVER.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION.
           CALL 'addition' USING IO
           GOBACK
           .
