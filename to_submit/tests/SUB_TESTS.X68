*-----------------------------------------------------------
* Title      : SUBROUTINE TESTS
* Written by : YOUSSEF BELTAGY
* Date       : 11/13/2020
* Description: More detailed tests for SUBROUTINE and the GET_EA subroutines.
*-----------------------------------------------------------
    ORG    $8000
START:                  ; first instruction of program

    *sub tests
    sub.b       d0,d0 * simple direct data register tests.
    sub.w       d0,d1
    sub.l       d0,d2
    sub.b       d0,d3
    sub.w       d0,d4
    sub.l       d0,d5
    sub.b       d0,d6
    sub.w       d0,d7
    
    sub.b       d0,d0
    sub.w       d1,d1
    sub.l       d2,d2
    sub.b       d3,d3
    sub.w       d4,d4
    sub.l       d5,d5
    sub.b       d6,d6
    sub.w       d7,d7
    
    sub.b       $8000,d2 * long absolute
    sub.w       $0021,d3 * short absolute
    sub.b       d4,$D040 * long absolute
    sub.w       d5,$5029 * short absolute
        
    sub.l       #$7,d3    *immediate
    sub.w       #$10,d7   *immediate word
    sub.b       #$60,d3   *immediate byte
    sub.l       #$00234,d4 * immediate long
    sub.l       #$ff234,d5 * immediate long
        
    sub.b       (a6),d0 * indirect tests
    sub.w       (a0),d5
    sub.w      (a7),d7
    sub.b       d2,(a7)
    sub.w       d7,(a5)
    sub.l       d6,(a1)
        
    sub.b       (a2)+,d4 * indirect tests with post-increment
    sub.w       (a3)+,d2
    sub.w      (a4)+,d6
    sub.b       d5,(a0)+
    sub.w       d1,(a6)+
    sub.l       d3,(a1)+
    
    sub.b       -(a5),d1 * indirect tests with pre-decrement
    sub.w       -(a4),d2
    sub.w      -(a2),d3
    sub.b       d4,-(a1)
    sub.w       d5,-(a6)
    sub.l       d6,-(a3)
    
    sub.l       (0,a3,d2),d4 * let's  break it.
    sub.l       d7,(5,a4,d0)
    sub.w       (3,pc,d6),d6
    sub.w       (7,PC,d4),d7

    suba.w      d2,a2
    suba.l      a3,a5
    subx.l      -(a3),-(a5)
    subx.l      d3,d2

    SIMHALT             ; halt simulator

* Put variables sub constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
