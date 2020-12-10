*-----------------------------------------------------------
* Title      : MOVEROUTINE TESTS
* Written by : YOUSSEF BELTAGY
* Date       : 11/13/2020
* Description: More detailed tests for MOVEROUTINE and the GET_EA moveroutines.
*-----------------------------------------------------------
    ORG    $8000
START:                  ; first instruction of program

    *test every destination with all possible source types
    move.b      d2,d2
    move.w      a6,d5
    move.l      (a7),d4
    move.b      (a3)+,d6
    move.w      -(a5),d7
    move.l      $67,d5
    move.b      $f320,d3
    move.w      #10,d3
    move.l      #502,d3
    move.b      #89,d4
    move.w      (10,a5),d5
    move.l      (0,a4,d2),d6
    move.b      (0,a4,a4),d7
*    move.w      (5,PC),d5
    move.l      (0,PC,d2),d4
    move.b      (0,PC,a6),d5

    move.b      d2,(a1)
    move.w      a3,(a6)
    move.l      (a2),(a3)
    move.b      (a4)+,(a5)
    move.w      -(a4),(a5)
    move.l      $12,(a6)
    move.b      $f320,(a7)
    move.w      #10,(a6)
    move.l      #502,(a6)
    move.b      #89,(a6)
    move.w      (10,a5),(a4)
    move.l      (0,a4,d2),(a7)
    move.b      (0,a4,a4),(a7)
*    move.w      (5,PC),(a4)
    move.l      (0,PC,d2),(a7)
    move.b      (0,PC,a6),(a7)

    move.b      d4,(a1)+
    move.w      a5,(a6)+
    move.l      (a3),(a3)+
    move.b      (a6)+,(a5)+
    move.w      -(a6),(a5)+
    move.l      $17,(a6)+
    move.b      $f3a0,(a7)+
    move.w      #10,(a6)+
    move.l      #502,(a6)+
    move.b      #89,(a6)+
    move.w      (10,a5),(a4)+
    move.l      (0,a4,d2),(a7)+
    move.b      (0,a4,a4),(a7)+
*    move.w      (5,PC),(a4)+
    move.l      (0,PC,d2),(a7)+
    move.b      (0,PC,a6),(a7)+

    move.b      d2,-(a1)
    move.w      a3,-(a6)
    move.l      (a2),-(a3)
    move.b      (a4)+,-(a5)
    move.w      -(a4),-(a5)
    move.l      $12,-(a6)
    move.b      $f320,-(a7)
    move.w      #10,-(a6)
    move.l      #502,-(a6)
    move.b      #89,-(a6)
    move.w      (10,a5),-(a4)
    move.l      (0,a4,d2),-(a7)
    move.b      (0,a4,a4),-(a7)
*    move.w      (5,PC),-(a4)
    move.l      (0,PC,d2),-(a7)
    move.b      (0,PC,a6),-(a7)

    move.b      d2,$104
    move.w      a3,$103
    move.l      (a2),$107
    move.b      (a4)+,$103
    move.w      -(a4),$1e0
    move.l      $12,$1f0
    move.b      $f320,$1a0
    move.w      #10,$510
    move.l      #502,$810
    move.b      #89,$190
    move.w      (10,a5),$170
    move.l      (0,a4,d2),$610
    move.b      (0,a4,a4),$910
*    move.w      (5,PC),$f10
    move.l      (0,PC,d2),$10ff
    move.b      (0,PC,a6),$10f6

    move.b      d2,$13104
    move.w      a3,$34103
    move.l      (a2),$43107
    move.b      (a4)+,$f103
    move.w      -(a4),$123e0
    move.l      $12,$1f230
    move.b      $f320,$1a670
    move.w      #10,$51090
    move.l      #502,$81780
    move.b      #89,$19640
    move.w      (10,a5),$16770
    move.l      (0,a4,d2),$67610
    move.b      (0,a4,a4),$96710
*    move.w      (5,PC),$f1670
    move.l      (0,PC,d2),$190ff
    move.b      (0,PC,a6),$103f6

    *fail gracefully
    move.w      d2,a0
    move.w      a3,a1
    move.l      (a2),a2
    move.l      (a4)+,a3
    move.w      -(a4),a4
    move.l      $12,a7
    move.w      $f320,a6
    move.w      #10,a1
    move.l      #502,a0
    move.l      #89,a2
    move.w      (10,a5),a0
    move.l      (0,a4,d2),a3
    move.l      (0,a4,a4),a4
*    move.w      (10,PC),a0
    move.l      (0,PC,d2),a5
    move.w      (0,PC,a6),a6

    *fail gracefully
    move.b      d2,(10,a5)
    move.w      a3,(10,a5)
    move.l      (a2),(10,a5)
    move.b      (a4)+,(10,a5)
    move.w      -(a4),(10,a5)
    move.l      $12,(10,a5)
    move.b      $f320,(10,a5)
    move.w      #10,(10,a5)
    move.l      #502,(10,a5)
    move.b      #89,(10,a5)
    move.w      (10,a5),(10,a5)
    move.l      (0,a4,d2),(10,a5)
    move.b      (0,a4,a4),(10,a5)
*    move.w      (5,PC),(10,a5)
    move.l      (0,PC,d2),(10,a5)
    move.b      (0,PC,a6),(10,a5)

    *fail gracefully
    move.b      d2,(0,a4,a4)
    move.w      a3,(0,a4,a4)
    move.l      (a2),(0,a4,a4)
    move.b      (a4)+,(0,a4,a4)
    move.w      -(a4),(0,a4,a4)
    move.l      $12,(0,a4,a4)
    move.b      $f320,(0,a4,a4)
    move.w      #10,(0,a4,a4)
    move.l      #502,(0,a4,a4)
    move.b      #89,(0,a4,a4)
    move.w      (10,a5),(0,a4,a4)
    move.l      (0,a4,d2),(0,a4,a4)
    move.b      (0,a4,a4),(0,a4,a4)
*    move.w      (5,PC),(0,a4,a4)
    move.l      (0,PC,d2),(0,a4,a4)
    move.b      (0,PC,a6),(0,a4,a4)


    *other tests
    move.b      d0,d0 * simple direct data register tests.
    move.w      d0,d1
    move.l      d0,d2
    move.b      d0,d3
    move.w      d0,d4
    move.l      d0,d5
    move.b      d0,d6
    move.w      d0,d7

    move.b      d0,d0
    move.w      d1,d1
    move.l      d2,d2
    move.b      d3,d3
    move.w      d4,d4
    move.l      d5,d5
    move.b      d6,d6
    move.w      d7,d7
    
    move.b      $8000,d2 * long absolute
    move.w      $0021,d3 * short absolute
    move.b      d4,$D040 * long absolute
    move.w      d5,$5029 * short absolute
        
    move.l      #$7,d3    *immediate
    move.w      #$10,d7   *immediate word
    move.b      #$60,d3   *immediate byte
    move.l      #$00234,d4 * immediate long
    move.l      #$ff234,d5 * immediate long
        
    move.b      (a6),d0 * indirect tests
    move.w      (a0),d5
    move.w      (a7),d7
    move.b      d2,(a7)
    move.w      d7,(a5)
    move.l      d6,(a1)
        
    move.b      (a2)+,d4 * indirect tests with post-increment
    move.w      (a3)+,d2
    move.w      (a4)+,d6
    move.b      d5,(a0)+
    move.w      d1,(a6)+
    move.l      d3,(a1)+
    
    move.b      -(a5),d1 * indirect tests with pre-decrement
    move.w      -(a4),d2
    move.w     -(a2),d3
    move.b      d4,-(a1)
    move.w      d5,-(a6)
    move.l      d6,-(a3)

    move.      a4,d2
    move.w      a5,d4


    *fail gracefully
    move.l       (0,a3,d2),d4 * let's  break it.
    move.l       d7,(5,a4,d0)
    move.w       (3,pc,d6),d6
    move.w       (7,PC,d4),d7

    movea.w      d2,a2
    movea.l      a3,a5



    SIMHALT             ; halt simulator

* Put variables move constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
