*-----------------------------------------------------------
* Title      : ANDROUTINE TESTS
* Written by : YOUSSEF BELTAGY
* Date       : 11/13/2020
* Description: More detailed tests for ANDROUTINE and the GET_EA subroutines.
*-----------------------------------------------------------
    ORG    $8000
START:                  ; first instruction of program

    *AND tests
    and.b       d0,d0 * simple direct data register tests.
    and.w       d0,d1
    and.l       d0,d2
    and.b       d0,d3
    and.w       d0,d4
    and.l       d0,d5
    and.b       d0,d6
    and.w       d0,d7
    
    exg         d2,d4 * can you distinguish and from other op-codes?

    and.b       d0,d0
    and.w       d1,d1
    and.l       d2,d2
    and.b       d3,d3
    and.w       d4,d4
    and.l       d5,d5
    and.b       d6,d6
    and.w       d7,d7
    
    exg         a5,d7 *can you distinguish and from other op-codes?

    
    and.b       $8000,d2 * long absolute
    and.w       $0021,d3 * short absolute
    and.b       d4,$D040 * long absolute
    and.w       d5,$5029 * short absolute
    
    abcd        d2,d3 *can you distinguish and from other op-codes?
    
    and.l       #$7,d3    *immediate
    and.w       #$10,d7   *immediate word
    and.b       #$60,d3   *immediate byte
    and.l       #$00234,d4 * immediate long
    and.l       #$ff234,d5 * immediate long
    
    muls        d2,d5 *can you distinguish and from other op-codes?
    
    and.b       (a6),d0 * indirect tests
    and.w       (a0),d5
    and.w      (a7),d7
    and.b       d2,(a7)
    and.w       d7,(a5)
    and.l       d6,(a1)
    
    mulu        d2,d5 *can you distinguish and from other op-codes?
    
    and.b       (a2)+,d4 * indirect tests with post-increment
    and.w       (a3)+,d2
    and.w      (a4)+,d6
    and.b       d5,(a0)+
    and.w       d1,(a6)+
    and.l       d3,(a1)+
    
    and.b       -(a5),d1 * indirect tests with pre-decrement
    and.w       -(a4),d2
    and.w      -(a2),d3
    and.b       d4,-(a1)
    and.w       d5,-(a6)
    and.l       d6,-(a3)
    
    and.l       (0,a3,d2),d4 * let's  break it.
    and.l       d7,(5,a4,d0)
    and.w       (3,pc,d6),d6
    and.w       (7,PC,d4),d7
    


    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
