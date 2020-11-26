*-----------------------------------------------------------
* Title      : ADDROUTINE TESTS
* Written by : YOUSSEF BELTAGY
* Date       : 11/13/2020
* Description: More detailed tests for ADDROUTINE and the GET_EA subroutines.
*-----------------------------------------------------------
    ORG    $8000
START:                  ; first instruction of program

    *add tests
    add.b       d0,d0 * simple direct data register tests.
    add.w       d0,d1
    add.l       d0,d2
    add.b       d0,d3
    add.w       d0,d4
    add.l       d0,d5
    add.b       d0,d6
    add.w       d0,d7
    
    exg         d2,d4 * can you distinguish add from other op-codes?

    add.b       d0,d0
    add.w       d1,d1
    add.l       d2,d2
    add.b       d3,d3
    add.w       d4,d4
    add.l       d5,d5
    add.b       d6,d6
    add.w       d7,d7
    
    exg         a5,d7 *can you distinguish add from other op-codes?

    
    add.b       $8000,d2 * long absolute
    add.w       $0021,d3 * short absolute
    add.b       d4,$D040 * long absolute
    add.w       d5,$5029 * short absolute
    
    abcd        d2,d3 *can you distinguish add from other op-codes?
    
    add.l       #$7,d3    *immediate
    add.w       #$10,d7   *immediate word
    add.b       #$60,d3   *immediate byte
    add.l       #$00234,d4 * immediate long
    add.l       #$ff234,d5 * immediate long
    
    muls        d2,d5 *can you distinguish add from other op-codes?
    
    add.b       (a6),d0 * indirect tests
    add.w       (a0),d5
    add.w      (a7),d7
    add.b       d2,(a7)
    add.w       d7,(a5)
    add.l       d6,(a1)
    
    mulu        d2,d5 *can you distinguish add from other op-codes?
    
    add.b       (a2)+,d4 * indirect tests with post-increment
    add.w       (a3)+,d2
    add.w      (a4)+,d6
    add.b       d5,(a0)+
    add.w       d1,(a6)+
    add.l       d3,(a1)+
    
    add.b       -(a5),d1 * indirect tests with pre-decrement
    add.w       -(a4),d2
    add.w      -(a2),d3
    add.b       d4,-(a1)
    add.w       d5,-(a6)
    add.l       d6,-(a3)
    
    add.l       (0,a3,d2),d4 * let's  break it.
    add.l       d7,(5,a4,d0)
    add.w       (3,pc,d6),d6
    add.w       (7,PC,d4),d7

    adda.w      d2,a2
    adda.l      a3,a5
    addx.l      -(a3),-(a5)
    addx.l      d3,d2

    SIMHALT             ; halt simulator

* Put variables add constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
