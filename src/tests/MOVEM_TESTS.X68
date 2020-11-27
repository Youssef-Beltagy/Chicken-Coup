*-----------------------------------------------------------
* Title      : MOVEMROUTINE TESTS
* Written by : YOUSSEF BELTAGY
* Date       : 11/13/2020
* Description: More detailed tests for MOVEROUTINE and the GET_EA moveroutines.
*-----------------------------------------------------------
    ORG    $8000
START:                  ; first instruction of program

    movem.w         (a1)+,d4-a5
    movem.l         d1-a7,-(a1)
    movem.w         $1000,d0-a0
    movem.l         d0-a0,$2000
    movem.w         d0-a7,$f000
    movem.l         a7/d6/d2,$f000

    ext             d3

    movem.w         d0-a3,(0,a6)
    movem.w         d0-a6,(0,a6,d5)


    SIMHALT             ; halt simulator

* Put variables move constants here

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
