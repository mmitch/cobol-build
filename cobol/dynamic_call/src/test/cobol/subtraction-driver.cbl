       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUBTRACTION-DRIVER.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 IO.
       COPY data.

       PROCEDURE DIVISION.
           CALL 'subtraction' USING IO
           GOBACK
           .
