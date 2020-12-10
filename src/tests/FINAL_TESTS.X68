*****************************
*
* demo_test.X68
*
* Created 12/05/2018
*
* Test program for CSS 422 Disassembler Project Demo
*
*****************************

start		EQU	$00009000	* ORG and END address

* ORG the program so that it straddles the address boundary $00007FFF to $00008000

	ORG	start

    bra         label2
    
    movem.w         (a1)+,d4-a5
    movem.l         d1-a7,-(a1)
    movem.w         $1000,d0-a0
    movem.l         d0-a3,$2000
    movem.w         d0-a3,$f000
    movem.l         a7/d6/d2,$f000

    ext             d3

    movem.w         d0-a3,(0,a6)
    movem.w         d0-a6,(0,a6,d5)

    bra         $9050
    bra         $9050

    jsr         label1
    jmp         label1
    jmp         label1
    jsr         label1

    asr         (a0)
    asr         (a1)+
    asr         -(a2)
    asr         $ab
    asr         $fd20
    asr         (0,a3)
    asr         (2,a4,d0)
    asr.b       #1,d1
    asr.w       #2,d2
    asr.l       #3,d3
    asr.b       #4,d4
    asr.w       #5,d5
    asr.l       #6,d6
    asr.b       #7,d7
    asr.w       #8,d0
    asr.l       d0,d0
    asr.b       d1,d0
    asr.w       d2,d0
    asr.l       d4,d0

    asl         (a0)
    asl         (a1)+
    asl         -(a2)
    asl         $ab
    asl         $fd20
    asl         (0,a3)
    asl         (2,a4,d0)
    asl.b       #1,d1
    asl.w       #2,d2
    asl.l       #3,d3
    asl.b       #4,d4
    asl.w       #5,d5
    asl.l       #6,d6
    asl.b       #7,d7
    asl.w       #8,d0
    asl.l       d0,d0
    asl.b       d1,d0
    asl.w       d2,d0
    asl.l       d4,d0

    lsl         (a0)
    lsl         (a1)+
    lsl         -(a2)
    lsl         $ab
    lsl         $fd20
    lsl         (0,a3)
    lsl         (2,a4,d0)
    lsl.b       #1,d1
    lsl.w       #2,d2
    lsl.l       #3,d3
    lsl.b       #4,d4
    lsl.w       #5,d5
    lsl.l       #6,d6
    lsl.b       #7,d7
    lsl.w       #8,d0
    lsl.l       d0,d0
    lsl.b       d1,d0
    lsl.w       d2,d0
    lsl.l       d4,d0

    lsr         (a0)
    lsr         (a1)+
    lsr         -(a2)
    lsr         $ab
    lsr         $fd20
    lsr         (0,a3)
    lsr         (2,a4,d0)
    lsr.b       #1,d1
    lsr.w       #2,d2
    lsr.l       #3,d3
    lsr.b       #4,d4
    lsr.w       #5,d5
    lsr.l       #6,d6
    lsr.b       #7,d7
    lsr.w       #8,d0
    lsr.l       d0,d0
    lsr.b       d1,d0
    lsr.w       d2,d0
    lsr.l       d4,d0


    muls        d0,d1
    muls.w      d2,d3
    muls        (a0),d4
    muls        (a1)+,d5
    muls        -(a2),d6
    muls        $F0F0,d7
    muls        $01,d0
    muls        #$01,d1
    muls        #$20,d2
    muls        #$aefa,d3
    muls        #$1102,d4
    muls        (10,a2,d3),d5
    muls        ($a,a4),d6
    muls        (10,pc,d3),d7
    *muls        (0,pc),d0

    lea         START,a0
    lea         $00,a1
    lea         $ff,a2
    lea         $1000,a3
    lea         $abcd,a4
    lea         $8000,a5
    lea         (a6),a7
    lea         (a7),a2
    lea         (a4),a2
    lea         (0,a2,d2),a5
    lea         (20,a4),a7

    not.b       d0
    not.w       d1
    not.l       d2
    not.b       (a3)
    not.w       (a4)
    not.l       (a5)
    not.b       (a6)+
    not.w       (a7)+
    not.l       (a0)+
    not.b       -(a0)
    not.w       -(a1)
    not.w       -(a2)
    not.b       $00
    not.w       $ff
    not.l       $A000
    not.b       $00000fff
    not.w       $00aabbcc
    not.b       (5,a2)
    not.w       (3,a2,d2)
    not.l       (3,a5)
    not.b       (10,a6,d5)
    jsr         (a0)
    jsr         (a1)
    jsr         (a2)
    jsr         (a3)
    jsr         (a4)
    jsr         (a5)
    jsr         (a6)
    jsr         (a7)
    jsr         (a3)
    jsr         (a4)
    jsr         $8000
    jsr         $90
    jsr         $ff
    jsr         $ffff
    jsr         $ffffffff
    jsr         (10,a5)
    jsr         (5,a4,d2)
    *jsr         (0,PC)
    jsr         (2,PC,d4)
    * write your opcodes
    bra         start
    nop *
    and.l       #4,d3
    jsr         label1
    jsr         label2
    jsr         label3
    jsr         label4
    beq         label1
    bra         label2
    beq         label3
    bra         label1
    blt         label2
    beq         label3
    bgt         label4
    bge         label1
    rts
    swap        d0
    adda.l      #1,a0
    add.l       #3,d0
    add.b       #23,d1
    move.l      #32,a2
    nop *
    bra         label3
    beq         label3
    jsr         label3
    rts
    nop *
    movem.l     d0-a7,-(sp)
    movem.l     d0-a7,(sp)
    movem.l     (sp)+,d0-a7
    movem.l     (sp)+,d0-a7
    nop *

    NOP
    RTS
    NOP
    RTS
    LEA     (A0),A0
    LEA     (A5),A0
    LEA     (A7),A0
    LEA     (A0),A7
    LEA     (A5),A7
    LEA     (A7),A7
    MOVE.B    D0,D1
    MOVE.B    D0,(A0)
    MOVE.B    D0,(A0)+
    MOVE.B    D0,-(A0)
    MOVE.B    (A0),D0
    MOVE.B    (A0),(A1)
    MOVE.B    (A0),(A1)+
    MOVE.B    (A0),-(A1)
    MOVE.B    (A0)+,D0
    MOVE.B    (A0)+,(A1)
    MOVE.B    (A0)+,(A1)+
    MOVE.B    (A0)+,-(A1)
    MOVE.B    -(A0),D0
    MOVE.B    -(A0),(A1)
    MOVE.B    -(A0),(A1)+
    MOVE.B    -(A0),-(A1)
    MOVE.W    D0,D1
    MOVE.W    D0,(A0)
    MOVE.W    D0,(A0)+
    MOVE.W    D0,-(A0)
    MOVE.W    A0,D0
    MOVE.W    A0,(A1)
    MOVE.W    A0,(A1)+
    MOVE.W    A0,-(A1)
    MOVE.W    (A0),D0
    MOVE.W    (A0),(A1)
    MOVE.W    (A0),(A1)+
    MOVE.W    (A0),-(A1)
    MOVE.W    (A0)+,D0
    MOVE.W    (A0)+,(A1)
    MOVE.W    (A0)+,(A1)+
    MOVE.W    (A0)+,-(A1)
    MOVE.W    -(A0),D0
    MOVE.W    -(A0),(A1)
    MOVE.W    -(A0),(A1)+
    MOVE.W    -(A0),-(A1)
    MOVE.L    D0,D1
    MOVE.L    D0,(A0)
    MOVE.L    D0,(A0)+
    MOVE.L    D0,-(A0)
    MOVE.L    A0,D0
    MOVE.L    A0,(A1)
    MOVE.L    A0,(A1)+
    MOVE.L    A0,-(A1)
    MOVE.L    (A0),D0
    MOVE.L    (A0),(A1)
    MOVE.L    (A0),(A1)+
    MOVE.L    (A0),-(A1)
    MOVE.L    (A0)+,D0
    MOVE.L    (A0)+,(A1)
    MOVE.L    (A0)+,(A1)+
    MOVE.L    (A0)+,-(A1)
    MOVE.L    -(A0),D0
    MOVE.L    -(A0),(A1)
    MOVE.L    -(A0),(A1)+
    MOVE.L    -(A0),-(A1)
    MOVEM.W   A1-A7,-(A1)
    MOVEM.L   D1-D7,-(A1)
    MOVEM.W   A1/D7,-(A1)
    MOVEM.L   A1/D7,-(A1)
    MOVEM.W   A1-A7,(A1)
    MOVEM.L   D1-D7,(A1)
    MOVEM.W   A1/D7,(A1)
    MOVEM.L   A1/D7,(A1)
    MOVEM.W   (A1)+,A1-A7
    MOVEM.L   (A1)+,D1-D7
    MOVEM.W   (A1)+,A1/D7
    MOVEM.L   (A1)+,A1/D7
    MOVEM.W   (A1),A1-A7
    MOVEM.L   (A1),D1-D7
    MOVEM.W   (A1),A1/D7
    MOVEM.L   (A1),A1/D7
    MOVEA.L    D0,A0
    MOVEA.L    A0,A0
    MOVEA.L    (A0),A0
    MOVEA.L    (A0)+,A0
    MOVEA.L    -(A0),A0  
    ADD.B     D1,D2
    ADD.B     D1,(A1)
    ADD.B     D1,(A1)+
    ADD.B     D1,-(A1)
    ADD.B     (A1),D1
    ADD.B     (A1)+,D1
    ADD.B     -(A1),D1
    ADD.W     D1,D2
    ADD.W     D1,(A1)
    ADD.W     D1,(A1)+
    ADD.W     D1,-(A1)
    ADD.W     (A1),D1
    ADD.W     (A1)+,D1
    ADD.W     -(A1),D1
    ADD.L     D1,D2
    ADD.L     D1,(A1)
    ADD.L     D1,(A1)+
    ADD.L     D1,-(A1)
    ADD.L     (A1),D1
    ADD.L     (A1)+,D1
    ADD.L     -(A1),D1
    ADDA.L        (A1)+,A2
    ADDA.L        -(A1),A2
    SUB.B     D1,D2
    SUB.B     D1,(A1)
    SUB.B     D1,(A1)+
    SUB.B     D1,-(A1)
    SUB.B     (A1),D1
    SUB.B     (A1)+,D1
    SUB.B     -(A1),D1
    SUB.W     D1,D2
    SUB.W     D1,A1
    SUB.W     D1,(A1)
    SUB.W     D1,(A1)+
    SUB.W     D1,-(A1)
    SUB.W     A1,D1
    SUB.W     (A1),D1
    SUB.W     (A1)+,D1
    SUB.W     -(A1),D1
    SUB.L     D1,D2
    SUB.L     D1,A1
    SUB.L     D1,(A1)
    SUB.L     D1,(A1)+
    SUB.L     D1,-(A1)
    SUB.L     A1,D1
    SUB.L     (A1),D1
    SUB.L     (A1)+,D1
    SUB.L     -(A1),D1    
    MULS.W    D0,D1
    MULS.W    (A0),D1
    MULS.W    -(A0),D1
    MULS.W    (A0)+,D1
    DIVU.W    D0,D1
    DIVU.W    (A0),D1
    DIVU.W    -(A0),D1
    DIVU.W    (A0)+,D1
    AND.B     D1,D2
    AND.B     D1,(A1)
    AND.B     D1,(A1)+
    AND.B     D1,-(A1)
    AND.B     (A1),D1
    AND.B     (A1)+,D1
    AND.B     -(A1),D1
    AND.W     D1,D2
    AND.W     D1,(A1)
    AND.W     D1,(A1)+
    AND.W     D1,-(A1)
    AND.W     (A1),D1
    AND.W     (A1)+,D1
    AND.W     -(A1),D1
    AND.L     D1,D2
    AND.L     D1,(A1)
    AND.L     D1,(A1)+
    AND.L     D1,-(A1)
    AND.L     (A1),D1
    AND.L     (A1)+,D1
    AND.L     -(A1),D1  
    BGT.B     label1
    BGT.B     label2
    BLE.B     label1
    BLE.B     label2
    BGE.B     label1
    BEQ.B     label2
    BEQ.W     label1
    JSR       (A0)
    JSR       $1234
    JSR       $12345678
    JSR       label1
    JSR       label2
    JSR       label3
    NOP
    RTS
label1
    NOP
    RTS
    LEA       $12,A0
    LEA       $1234,A0
    LEA       $12345678,A0
label2
    LSL.B     D1,D2
    LSL.W     D1,D2
    LSL.W     (A1)
    LSL.W     (A1)+
    LSL.W     -(A1)
    LSL.L     D1,D2
    ASL.B     D1,D2
    ASL.W     D1,D2
    ASL.W     (A1)
    ASL.W     (A1)+
    ASL.W     -(A1)
    ASL.L     D1,D2
label3
    MOVEM.W   A1-A7,$12
    MOVEM.L   D1-D7,$12
    MOVEM.W   A1/D7,$12
    MOVEM.L   A1/D7,$12
    MOVEM.W   A1-A7,$1234
    MOVEM.L   D1-D7,$1234
    MOVEM.W   A1/D7,$1234
    MOVEM.L   A1/D7,$1234
    MOVEM.W   A1-A7,$12345678
    MOVEM.L   D1-D7,$12345678
    MOVEM.W   A1/D7,$12345678
    MOVEM.L   A1/D7,$12345678
    MOVEM.W   $12,A1-A7
    MOVEM.L   $12,D1-D7
    MOVEM.W   $12,A1/D7
    MOVEM.L   $12,A1/D7
    MOVEM.W   $1234,A1-A7
    MOVEM.L   $1234,D1-D7
    MOVEM.W   $1234,A1/D7
    MOVEM.L   $1234,A1/D7
    MOVEM.W   $12345678,A1-A7
    MOVEM.L   $12345678,D1-D7
    MOVEM.W   $12345678,A1/D7
    MOVEM.L   $12345678,A1/D7
    MULS.W    $12,D1
    MULS.W    $1234,D1
    MULS.W    $12345678,D1
    MULS.W    #$1234,D1
    DIVU.W    $12,D1
    DIVU.W    $1234,D1
    DIVU.W    $12345678,D1
    DIVU.W    #$1234,D1
label4
    BGT.B     label4
    BGT.B     label4
    BGT.B     label4
    BLE.W     label1
    BLE.W     label2
    BLE.W     label3
    BEQ.W     label1
    BEQ.W     label2
    BEQ.W     label3
    BRA       label2
    BRA       label3
    JSR       label1
    JSR       label2
    JSR       label3


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

    *add tests
    add.b       d0,d0 * simple direct data register tests.
    add.w       d0,d1
    add.l       d0,d2
    add.b       d0,d3
    add.w       d0,d4
    add.l       d0,d5
    add.b       d0,d6
    add.w       d0,d7
    
    add.b       d0,d0
    add.w       d1,d1
    add.l       d2,d2
    add.b       d3,d3
    add.w       d4,d4
    add.l       d5,d5
    add.b       d6,d6
    add.w       d7,d7
    
    add.b       $8000,d2 * long absolute
    add.w       $0021,d3 * short absolute
    add.b       d4,$D040 * long absolute
    add.w       d5,$5029 * short absolute
        
    add.l       #$7,d3    *immediate
    add.w       #$10,d7   *immediate word
    add.b       #$60,d3   *immediate byte
    add.l       #$00234,d4 * immediate long
    add.l       #$ff234,d5 * immediate long
        
    add.b       (a6),d0 * indirect tests
    add.w       (a0),d5
    add.w      (a7),d7
    add.b       d2,(a7)
    add.w       d7,(a5)
    add.l       d6,(a1)
        
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
    
    *movem tests
    movem.w         (a1)+,d4-a5
    movem.l         d1-a7,-(a1)
    movem.w         $1000,d0-a0
    movem.l         d0-a0,$2000
    movem.w         d0-a6,$f000
    movem.l         a7/d6/d2,$f000

    ext             d3

    movem.w         d0-a3,(0,a6)
    movem.w         d0-a6,(0,a6,d5)

    
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



* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
