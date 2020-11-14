*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Youssef Beltagy, Jasdeep
* Date       : 10/25/2020
* Description: A 68k Disassembler
*-----------------------------------------------------------

    ORG    $1000
START:                  ; first instruction of program

* FIXME: For Testing, DELETE LATER *============================
*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Youssef Beltagy
* Date       : 10/25/2020
* Description: A 68k Disassembler
*-----------------------------------------------------------

    ORG    $1000
START:                  ; first instruction of program

* FIXME: For Testing, DELETE LATER *============================
    movea.l     #$00008000, a4 
    move.w      #$4E71, (a4)+       *nop
    move.w      #$4642, (a4)+       *not dn
    move.w      #$4654, (a4)+       *not (an)
    move.w      #$4664, (a4)+       *not -(an)
    move.w      #$465C, (a4)+       *not (an)+
    move.w      #$46B9, (a4)+       *not (xxx).l
    move.l      #$0000A000, (a4)+ 

    bra         SKIP_TESTS * don't actually run the tests
    * write your opcodes here
    NOT         D2           * 4642
    NOT.W       (A4)         * 4654
    NOT.W       (A4)+        * 465C
    NOT.W       -(A4)        * 4664
    NOT.L       $0000A000    * 4679 0000A000       
    ADD.B       D0,D1        * D200
    ADD.B       D2, $FFFF1234 * D539 FFFF1234
    ADD.W       D1,D0        * D041
    ADD.L       $FFFF1234,D1 * D2B9
    SUB.B       D5,D4        * 9805
    ASR         $00001234    * E0F81234
    ASR         (A1)+        
    ASR         -(A2)
    ASR.B       #$1,D0
    ASR.L       #$1,D0
    LSL         $00001234    * E3F81234
    LEA         (A4),A5      * 4BD4

    bra         BCCROUTINE_END
    nop *
    beq         MAIN_LOOP
    bra         START
    beq         MAIN_LOOP_PRINT
    bra         DATAROUTINE
    blt         DATAROUTINE
    beq         DATAROUTINE
    bgt         DATAROUTINE
    bge         DATAROUTINE
    swap        d0
    adda.l      #1,a0
    add.l       #3,d0
    add.b       #23,d1
    move.l      #32,a2
    nop *
    bra         SKIP_TESTS
    beq         INPUT_OR_EXIT
    jsr         INPUT_OR_EXIT
    rts
    nop *
    movem.l     d0-a7,-(sp)
    movem.l     d0-a7,(sp)
    movem.l     (sp)+,d0-a7
    movem.l     (sp)+,d0-a7
    nop *
* FIXME: For Testing, DELETE LATER *============================

SKIP_TESTS:
    jsr         INPUT_OR_EXIT
    cmp.l       #-1,d7
    beq         EXIT_PROGRAM

* FIXME: For Testing, DELETE LATER *============================
    *prints the two hex digits
    *move.l      INPUT_START,d1 *
    *move.b      #15,d0 *
    *move.b      #16,d2 *
    *trap        #15 *
    *
    **starts a new line
    *lea         LINE_END,a1 *
    *move.b      #14,d0 *
    *trap        #15 *
*
    *move.l      INPUT_END,d1 *
    *move.b      #15,d0 *
    *move.b      #16,d2 *
    *trap        #15 * 
*
    **starts a new line
    *lea         LINE_END,a1 *
    *move.b      #14,d0 *
    *trap        #15 *

* FIXME: For Testing, DELETE LATER *============================

*TODO: IMPlement a subroutine for the loop if necessary
    *The Main Loop
    movea.l     INPUT_START,a6

MAIN_LOOP:
    cmp.l       INPUT_END,a6     
    BGT         EXIT_PROGRAM
    lea         BUFFER,a1

    *Inclusive of INPUT_END
    *Will read the op-code starting at INPUT_END
    *That op-code could be 80 bytes, and there won't be a problem.

    move.l      a6,d2
    jsr         STRING_FROM_LONG
    move.b      #9,(a1)+ * print a tab.

    cmp.w       #$4E71,(a6)
    bne         SKIP_NOPROUTINE
    jsr         NOPROUTINE
    bra         MAIN_LOOP_PRINT

SKIP_NOPROUTINE:
    cmp.w       #$4E75,(a6)
    bne         SKIP_RTSROUTINE
    jsr         RTSROUTINE
    bra         MAIN_LOOP_PRINT

SKIP_RTSROUTINE:
    move.w      (a6),d0
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.b       #4, d0
    bne         SKIP_NOTROUTINE
    jsr         NOTROUTINE
    bra         MAIN_LOOP_PRINT  


SKIP_NOTROUTINE 
    cmp.b       #6, d0
    bne         SKIP_BCCROUTINE
    jsr         BCCROUTINE
    bra         MAIN_LOOP_PRINT

SKIP_BCCROUTINE:
*put more op-code subroutine calls here.
*Just like NOPROUTINE
* the default subroutine if no other routines are called is
* the data ROUTINE
    jsr         DATAROUTINE

SKIP_CURRENT_ROUTINE
* when an error is detected in a middle of a opcode routine skip 
* to dataroutine
    movem.l     (sp)+,A0/A2-A5/D0-D7
    jsr         DATAROUTINE

MAIN_LOOP_PRINT:
    *TODO: Implement the window that waits
    * for the user to press enter before it shows more lines
    * of disassembled code
    *TODO: Possibly add error checking before you print
    lea         BUFFER,a1
    move.b      #14,d0
    trap        #15
    bra         MAIN_LOOP

EXIT_PROGRAM:
    lea         TERMINATION_MESSAGE,a1
    move.b      #14,d0
    trap        #15
        
    SIMHALT             ; halt simulator

* Utility Subroutines
*-----------------------------------------------------------
* Put your utility subroutines here

INPUT_OR_EXIT:
*Description:
*Ensures that INPUT_START and INPUT_END
*contain valid starting and ending addresses
*or returns -1 if the program should terminate.
*The addresses are valid if INPUT_END >= INPUT_START
*sets d7 to 0 for valid input and to -1 for exit.
*Nothing changes other than INPUT_START, INPUT_END, and d7
*Input: nothing
*Output: d7.l
    movem.l     d0-d6/a0-a6,-(sp)

INPUT_OR_EXIT_LOOP:
    *prompts for input
    lea         INPUT_START_MESSAGE,a1
    move.b      #14,d0
    trap        #15

    *get the input
    lea         BUFFER,a1
    move.b      #2,d0
    trap        #15

    *If the size of the string is less than 1
    cmp.w       #1,d1
    blt         INPUT_OR_EXIT_INVALID

    *program termination value
    cmp.b       #113,(a1) *113 is for 'q'
    beq         INPUT_OR_EXIT_TERMINATE *return error code

    *convert the string into a long
    jsr         LONG_FROM_STRING
    cmp.l       #-1,d7
    beq         INPUT_OR_EXIT_INVALID

    *Test that the start address is even
    btst        #0,d6 *TODO: Possibly print a special message for odd start input.
    bne         INPUT_OR_EXIT_INVALID 

    *copy the input
    move.l      d6,INPUT_START
    
    *prompt for input
    lea         INPUT_END_MESSAGE,a1
    move.b      #14,d0
    trap        #15

    *get the input
    lea         BUFFER,a1
    move.b      #2,d0
    trap        #15

    *convert the string into a long
    jsr         LONG_FROM_STRING
    cmp.l       #-1,d7
    beq         INPUT_OR_EXIT_INVALID

    *copy the input
    move.l      d6,INPUT_END

    *Check the validity of the addresses
    cmp.l       INPUT_START,d6
    blt         INPUT_OR_EXIT_INVALID
    *TODO: Print a unique message when the end address is 
    * is smaller than the start address

    *set the error flag to 0
    move.l      #0,d7

    *end the subroutine
    bra         INPUT_OR_EXIT_END

INPUT_OR_EXIT_INVALID:
    *prints invalid message
    *and prompts for input again
    lea         INVALID_MESSAGE,a1
    move.b      #14,d0
    trap        #15
    bra         INPUT_OR_EXIT_LOOP

INPUT_OR_EXIT_TERMINATE:
    move.l      #-1,d7
INPUT_OR_EXIT_END:
    movem.l     (sp)+,d0-d6/a0-a6
    rts
* End of INPUT_OR_EXIT


LONG_FROM_STRING:
*Description:
*Given a string at a1 and its size at d1.w, returns a hex number at 
*d6 and 0 at d7.l, or -1 at d7.l to represent an error.
*nothing other than d7 and d6 will change
*Input: a1, d1.w
*Output: d7.l, d6.l

    movem.l     d0-d5/a0-a6,-(sp)

    * The default value of d7
    * is 0.
    * If the program returns -1
    * there was an error
    move.l  #0,d7

    cmp.w   #8,d1
    BNE     LONG_FROM_STRING_ERROR *The string is too big
    

    move.l  #0,d6
    move.l  #8,d0

LONG_FROM_STRING_LOOP:
    cmp.b   #0,d0
    beq     LONG_FROM_STRING_END

    move.l  #0,d1
    move.b  (a1)+,d1

    cmp.b   #48,d1
    blt     LONG_FROM_STRING_ERROR
    cmp.b   #58,d1 * '0'-'9' are 48-57
    blt     LONG_FROM_STRING_DIGIT
    cmp.b   #65,d1
    blt     LONG_FROM_STRING_ERROR
    cmp.b   #71,d1 * 'A'-'F' are 65-70
    blt     LONG_FROM_STRING_CAPITAL_CHAR
    cmp.b   #97,d1
    blt     LONG_FROM_STRING_ERROR
    cmp.b   #103,d1 * 'a'-'f' are 65-70
    blt     LONG_FROM_STRING_SMALL_CHAR
    bra     LONG_FROM_STRING_ERROR

LONG_FROM_STRING_LOOP_CONTINUE:
    lsl.l   #4,d6
    add.l   d1,d6
    sub.b   #1,d0
    bra     LONG_FROM_STRING_LOOP

LONG_FROM_STRING_DIGIT:
    *map 48-57 to 0-9
    sub.b   #48,d1
    bra     LONG_FROM_STRING_LOOP_CONTINUE

LONG_FROM_STRING_CAPITAL_CHAR:
    *map 65-70 to 10-15
    sub.b   #55,d1
    bra     LONG_FROM_STRING_LOOP_CONTINUE

LONG_FROM_STRING_SMALL_CHAR:
    *map 97-102 to 10-15
    sub.b   #87,d1
    bra     LONG_FROM_STRING_LOOP_CONTINUE

LONG_FROM_STRING_ERROR:
    move.l      #-1,d7

LONG_FROM_STRING_END:
    movem.l     (sp)+,d0-d5/a0-a6
    rts
* End of LONG_FROM_STRING subroutine

STRING_FROM_WORD:
*Description:
*Given a word at d2.w, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.w
*Output: a1 and the memory it points to
    movem.l     d0/d1,-(sp)

    move.l      #0,d0 * loop variable. Used for shifting lift
    move.l      #0,d1 * temp register for the word

STRING_FROM_WORD_LOOP:
    move.w      d2,d1 * get the word
    cmp.b       #16,d0 * is the loop over?
    beq         STRING_FROM_WORD_END

    lsl.w       d0,d1  * gets rid of all excess more significant bits
    lsr.w       #6,d1  * gets rid of all excess less significant bits
    lsr.w       #6,d1  * and moves the wanted nibble to the Least significant nibble

    add.b       #4,d0  * Next time, shift to the lift 4 more bits

    cmp.b       #9,d1
    bgt         STRING_FROM_WORD_CHAR * is this byte A-F
    add.b       #48,d1 * this byte is 0-9
    move.b      d1,(a1)+
    bra         STRING_FROM_WORD_LOOP

STRING_FROM_WORD_CHAR: *this byte is A-F
    add.b       #55,d1
    move.b      d1,(a1)+
    bra         STRING_FROM_WORD_LOOP

STRING_FROM_WORD_END:
    movem.l     (sp)+,d0/d1
    rts
* End of STRING_FROM_WORD

STRING_FROM_LONG:
*Description:
*Given a long at d2.l, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.l
*Output: a1 and the memory it points to

    swap        d2
    jsr         STRING_FROM_WORD
    swap        d2
    jsr         STRING_FROM_WORD

    rts
* End of STRING_FROM_WORD

COPY_STRING_A2_TO_A1:
*Description:
*Given a null terminated string at a2, will
*copy th string to a1 except the terminating null.
*Nothing other than a1 will change
*Input: a1, a2
*Output: a1
    movem.l     d0/a2,-(sp)

    move.b      #0,d0

COPY_STRING_A2_TO_A1_LOOP:
    cmp.b       (a2),d0
    beq         COPY_STRING_A2_TO_A1_END 
    move.b      (a2)+,(a1)+
    bra         COPY_STRING_A2_TO_A1_LOOP 

COPY_STRING_A2_TO_A1_END
    movem.l     (sp)+,d0/a2
    rts
* End of COPY_STRING_A2_TO_A1  

* Op-cdoe Subroutines
*-----------------------------------------------------------
* Put your Op-Code Subroutine here

NOPROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "NOP" into BUFFER and increments a6 by two bytes
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     A0/A2-A5/D0-D7, -(sp)
    *If needed, could optimize memory by not copying anything except a2

    lea         NOP_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ *terminate the string
    adda.l      #2,a6


    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

RTSROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "RTS" into BUFFER and increments a6 by two bytes
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     A0/A2-A5/D0-D7, -(sp)
    *If needed, could optimize memory by not copying anything except a2

    lea         RTS_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ *terminate the string
    adda.l      #2,a6


    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

* End of RTSROUTINE subroutine

NOTROUTINE
    movem.l     A0/A2-A5/D0-D7, -(sp)
    move.w      (a6), d7
    lea         NOT_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    jsr         GET_SIZE
    adda.l      #2,a6
    jsr         SOURCE_JUMP

    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ * terminate with a null.
    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

DATAROUTINE:
*Description:
*Loads "DATA: $" then the hex value of the word at (a6)
*into buffer and increments a6 by two bytes.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     A0/A2-A5/D0-D7, -(sp)
    *if needed, could optimize memory by only copying a2 and d2

    lea         DATA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "DATA: $" into a1

    move.w      (a6),d2
    jsr         STRING_FROM_WORD     *Put the word into string from

    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1

    move.b      #0,(a1)+             *terminate the string

    adda.l      #2,a6                *Move forward two bytes with a6

    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

* End of DATAROUTINE subroutine

BCCROUTINE:
*Description:
*HANDLES BRA, BLT, BEQ, BGE
*IF it is any other BCC, this subroutine calls the data routine.
*TODO: Check with the professor if he wants us to print "UNKOWN BCC 0xdataaddress"
*or just regulary print the data.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     A0/A2-A5/D0-D7, -(sp)
    *if needed, could optimize memory by only copying a2

    move.l      #0,d0
    move.w      (a6),d0

    *GET the condition nibble
    lsl.w       #4,d0 *get rid of the most significant nibble
    lsr.w       #6,d0 *prepend with 12 zeros.
    lsr.w       #6,d0

    *Checks for BRA
    cmp.b       #$00,d0
    bne         BCCROUTINE_NOT_BRA
    lea         BRA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS


BCCROUTINE_NOT_BRA: *Checks for BLT
    cmp.b       #$0D,d0
    bne         BCCROUTINE_NOT_BLT
    lea         BLT_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS


BCCROUTINE_NOT_BLT: *Checks for BGE
    cmp.b       #$0C,d0
    bne         BCCROUTINE_NOT_BGE
    lea         BGE_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS


BCCROUTINE_NOT_BGE: *Checks for BEQ
    cmp.b       #$07,d0
    bne         BCCROUTINE_INVALID
    lea         BEQ_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS


BCCROUTINE_INVALID:*TODO: Check with the professor what behavior he wants here exactly
    jsr         DATAROUTINE
    bra         BCCROUTINE_END


BCCROUTINE_GET_ADDRESS:
    *TODO: Does the PC point to the next insturction as the professor said?
    *TODO: Or does it actually point to current instruction + 2. That would mean it points to data.
    *TODO: This edge case will only be apparent if the difference is 16bits or 32bits.
    *TODO: I must test those cases.
    *TODO: I tested with Word. I can't test with long yet because this file is not long enough.
    *TODO: The professor was wrong and the manual is right.
    *TODO: It is the current instruction + 2 even if the next word is the displacement.
    *TODO: For the sake of implementation, I will trust the professor's words for now.

    move.w      (a6),d0

    *If the least significant byte is 00, the difference is
    *in the next word.
    cmp.b       #$00,d0
    beq         BCCROUTINE_GET_ADDRESS_WORD

    *If the least significant byte is $ff, the difference is 
    *in the next long.
    cmp.b       #$ff,d0
    beq         BCCROUTINE_GET_ADDRESS_LONG

    *otherwise, the difference is a byte
    adda.l      #2,a6
    move.l      a6,d2

    *extend the displacement and add it to d2
    ext.w       d0
    ext.l       d0
    add.l       d0,d2
    jsr         STRING_FROM_LONG
    bra         BCCROUTINE_VALID_END


BCCROUTINE_GET_ADDRESS_WORD:
    adda.l      #2,a6 * increment a6
    move.l      a6,d2 * copy a6 before it is incremented further.


    move.w      (a6)+,d0 *increment a6 and get the word
    ext.l       d0 *extend the dispalcement

    add.l       d0,d2
    jsr         STRING_FROM_LONG
    bra         BCCROUTINE_VALID_END


BCCROUTINE_GET_ADDRESS_LONG:
    adda.l      #2,a6 *increment a6
    move.l      a6,d2 *copy a6 before it is incremented further.

    move.l      (a6)+,d0 *increment a6 and get the long

    add.l       d0,d2
    jsr         STRING_FROM_LONG

BCCROUTINE_VALID_END:
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ * terminate with a null.

BCCROUTINE_END:
    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

* End of BCCROUTINE subroutine

* Variables
*-----------------------------------------------------------
* Put variables and constants here

CR          equ $0D
LF          equ $0A

BUFFER
 * an input BUFFER
    ds.b   180 *A BUFFER of 180 bytes

INPUT_START
    ds.l    1

INPUT_END
    ds.l    1
               
Str_Byte            dc.w    '.B ', 0
Str_Word            dc.w    '.W ', 0
Str_Long            dc.w    '.L ', 0
Str_Space           dc.w    ' ', 0
Str_0               dc.w    '0', 0
Str_1               dc.w    '1', 0
Str_2               dc.w    '2', 0
Str_3               dc.w    '3', 0
Str_4               dc.w    '4', 0
Str_5               dc.w    '5', 0
Str_6               dc.w    '6', 0
Str_7               dc.w    '7', 0
Str_8               dc.w    '8', 0
Str_9               dc.w    '9', 0

Str_Open_Brack      dc.w    '(', 0  
Str_Close_Brack     dc.w    ')', 0  
Str_Slash           dc.w    '/', 0  
Str_Plus            dc.w    '+', 0  
Str_Minus           dc.w    '-', 0  
Str_Data_Reg        dc.w    'D', 0  
Str_Addr_Reg        dc.w    'A', 0  
Str_Comma           dc.w    ', ', 0  
Str_Bin             dc.w    '%', 0  
Str_Hex             dc.w    '$', 0  
Str_Hashtag         dc.w    '#', 0  

NOP_OPCODE
    dc.b    'NOP',CR,LF,0

RTS_OPCODE
    dc.b    'RTS',CR,LF,0

LEA_OPCODE
    dc.b    'LEA:   $',0

ADD_OPCODE
    dc.b    'ADD',0

SUB_OPCODE
    dc.b    'SUB',0

LSL_OPCODE
    dc.b    'LSL',0

NOT_OPCODE
    dc.b    'NOT',0

ASR_OPCODE
    dc.b    'ASR',0     

DATA_OPCODE
    dc.b    'DATA:  $',0 * must be null terminated

BRA_OPCODE
    dc.b    'BRA    $',0

BLT_OPCODE
    dc.b    'BLT    $',0

BGE_OPCODE
    dc.b    'BGE    $',0

BEQ_OPCODE
    dc.b    'BEQ    $',0

INPUT_START_MESSAGE
    dc.b   'Please Enter Starting Address: ',0

INPUT_END_MESSAGE
    dc.b   'Please Enter Ending Address: ',0

TERMINATION_MESSAGE
    dc.b    'Program Terminated',0

INVALID_MESSAGE
    dc.b    'Invalid input. Input must be 8-digit hex number',CR,LF,0
    
LINE_END
    dc.b    CR,LF,0

Check_Count_Or_Register
    JSR     B5
    CMP.B   #$0, D6
    BEQ     Shift_Count
    CMP.B   #$1, D6
    BEQ     Shift_Register
    BNE     SKIP_CURRENT_ROUTINE

Shift_Register
    move.w  #$0000, d5
    JSR     Print_Dn
    RTS

Shift_Count
    lea     Str_Hashtag,a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Hex,a2
    jsr     COPY_STRING_A2_TO_A1
    JSR     B11_TO_B9
    move.w  d6,d2
    jsr     STRING_FROM_WORD
    RTS

Print_ASRr
    lea     ASR_OPCODE,a2
    jsr     COPY_STRING_A2_TO_A1
    JSR     Get_Size_For_LSL_ASR
    JSR     Check_Count_Or_Register
    lea     Str_Comma,a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Space,a2
    jsr     COPY_STRING_A2_TO_A1
    move.w  #$1111, d5
    JSR     Print_Dn
    lea     LINE_END,a2
    jsr     COPY_STRING_A2_TO_A1
    move.b  #0,(a1)+ * terminate with a null.
    movem.l (sp)+,A0/A2-A5/D0-D7
    bra     MAIN_LOOP_PRINT

Get_Size_For_LSL_ASR
    JSR     B7_TO_B6
    CMP.B   #$0, D6
    BEQ     Print_Size_Byte
    CMP.B   #$1, D6
    BEQ     Print_Size_Word
    CMP.B   #$2, D6
    BEQ     Print_Size_Long
    BNE     SKIP_CURRENT_ROUTINE

* Get the size for opcodes
GET_SIZE
    JSR         B8_TO_B6
    CMP.B       #$0, D6
    BEQ         Print_Size_Byte
    CMP.B       #$1, D6
    BEQ         Print_Size_Word
    CMP.B       #$2, D6
    BEQ         Print_Size_Long
    CMP.B       #$4, D6
    BEQ         Print_Size_Byte
    CMP.B       #$5, D6
    BEQ         Print_Size_Word
    CMP.B       #$6, D6
    BEQ         Print_Size_Long
    BNE         SKIP_CURRENT_ROUTINE

* Put the size into the output string
Print_Size_Byte
    lea         Str_Byte,a2
    jsr         COPY_STRING_A2_TO_A1
    rts

Print_Size_Word
    lea         Str_Word,a2
    jsr         COPY_STRING_A2_TO_A1
    rts

Print_Size_Long
    lea         Str_Long,a2
    jsr         COPY_STRING_A2_TO_A1
    rts

* Check opmode for add, sub
Check_Opmode
    JSR     B8   
    CMP.B   #$0, D6
    BEQ     EffectiveAddress_To_Destination
    CMP.B   #$1, D6
    BEQ     Destination_To_EffectiveAddress

*   1101    000 001 000 001
EffectiveAddress_To_Destination
    JSR     SOURCE_JUMP
    lea     Str_Comma, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Space, a2
    jsr     COPY_STRING_A2_TO_A1
    move.w  #$0000, d5
    JSR     Print_Dn
    RTS

Destination_To_EffectiveAddress
    move.w  #$0000, d5
    JSR     Print_Dn
    lea     Str_Comma, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Space, a2
    jsr     COPY_STRING_A2_TO_A1
    JSR     SOURCE_JUMP
    RTS

DESTINATION_JUMP
    move.w  #$0000, d5
    JSR     B8_TO_B6
    bra     DEST_AND_SOURCE
    
SOURCE_JUMP
    move.w  #$1111, d5
    JSR     B5_TO_B3
    bra     DEST_AND_SOURCE

DEST_AND_SOURCE
    CMP.B   #$0, D6
    BEQ     Print_Dn
    CMP.B   #$1, D6
    BEQ     Print_An
    CMP.B   #$2, D6
    BEQ     Print_Indr_An
    CMP.B   #$3, D6
    BEQ     Print_Indr_Plus_An
    CMP.B   #$4, D6
    BEQ     Print_Indr_Minus_An
    CMP.B   #$7, D6
    BEQ     Print_MemAddr

* Put 'D' into the output string
Print_Dn
    lea     Str_Data_Reg, a2
    jsr     COPY_STRING_A2_TO_A1
    jsr     Find_DEST_or_SRC
    rts

* Put 'A' into the output string
Print_An
    lea     Str_Addr_Reg, a2
    jsr     COPY_STRING_A2_TO_A1
    jsr     Find_DEST_or_SRC
    RTS

* Put '(An)' into the output string
Print_Indr_An
    lea     Str_Open_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Addr_Reg, a2
    jsr     COPY_STRING_A2_TO_A1
    jsr     Find_DEST_or_SRC
    lea     Str_Close_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    RTS

* Put '(An)+' into the output string
Print_Indr_Plus_An
    lea     Str_Open_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Addr_Reg, a2
    jsr     COPY_STRING_A2_TO_A1
    jsr     Find_DEST_or_SRC
    lea     Str_Close_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Plus, a2
    jsr     COPY_STRING_A2_TO_A1
    RTS

* Put '-(An)' into the output string
Print_Indr_Minus_An
    lea     Str_Minus, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Open_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Addr_Reg, a2
    jsr     COPY_STRING_A2_TO_A1
    jsr     Find_DEST_or_SRC
    lea     Str_Close_Brack, a2
    jsr     COPY_STRING_A2_TO_A1
    RTS   

* Put the register number into the output string
Find_DEST_or_SRC
    cmp     #$0000, d5
    beq     Find_DR
    cmp     #$1111, d5
    beq     Find_SR

Find_DR
    JSR     B11_TO_B9
    bra     Print_Num

Find_SR
    JSR     B2_TO_B0
    bra     Print_Num

* Find and put the memory address into the output string
Print_MemAddr
    cmp     #$0000, d5
    beq     Print_MemAddr_DEST
    cmp     #$1111, d5
    beq     Print_MemAddr_SRC

Print_MemAddr_DEST
    jsr     B11_TO_B9
    bra     Find_Mem_Addr_Size

Print_MemAddr_SRC
    JSR     B2_TO_B0
    bra     Find_Mem_Addr_Size

Find_Mem_Addr_Size
    CMP.B   #$0, D6
    BEQ     Mem_Word
    CMP.B   #$1, D6
    BEQ     Mem_Long
    CMP.B   #$4, D6
    BEQ     Immedi_Data

Mem_Word
    lea     Str_Hex,a2
    jsr     COPY_STRING_A2_TO_A1
    JSR     Immedi_Data_Word
    rts
    
Mem_Long
    lea     Str_Hex,a2
    jsr     COPY_STRING_A2_TO_A1
    JSR     Immedi_Data_Long
    rts

Immedi_Data_Word
    move.w      (a6)+,d2
    jsr         STRING_FROM_WORD     
    rts

Immedi_Data_Long
    move.l      (a6)+,d2
    jsr         STRING_FROM_LONG
    rts

* Find and put the immediate data into the output string
Immedi_Data
    lea     Str_Hashtag, a2
    jsr     COPY_STRING_A2_TO_A1
    lea     Str_Hex, a2
    jsr     COPY_STRING_A2_TO_A1
    bra     Size_Arthm

Size_Arthm
    JSR     B7_TO_B6
    CMP.B   #$1, D6       * if equal to 3 that mean its Byte because 01 is 1 in hex
    BEQ     Immedi_Data_Word
    CMP.B   #$3, D6       * if equal to 3 that mean its Word because 11 is 3 in hex
    BEQ     Immedi_Data_Word
    CMP.B   #$2, D6       * if equal to 3 that mean its Long because 10 is 2 in hex
    BEQ     Immedi_Data_Long

* Utilities for adding numbers to the output string
Print_Num
    CMP.B   #$0, D6
    BEQ     Print_0
    CMP.B   #$1, D6
    BEQ     Print_1
    CMP.B   #$2, D6
    BEQ     Print_2
    CMP.B   #$3, D6
    BEQ     Print_3
    CMP.B   #$4, D6
    BEQ     Print_4
    CMP.B   #$5, D6
    BEQ     Print_5
    CMP.B   #$6, D6
    BEQ     Print_6
    CMP.B   #$7, D6
    BEQ     Print_7

Print_0
    lea     Str_0, a2
    jsr     COPY_STRING_A2_TO_A1
    rts
Print_1 
    lea     Str_1, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_2 
    lea     Str_2, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_3 
    lea     Str_3, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_4 
    lea     Str_4, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_5 
    lea     Str_5, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_6 
    lea     Str_6, a2
    jsr     COPY_STRING_A2_TO_A1
    rts 
Print_7 
    lea     Str_7, a2
    jsr     COPY_STRING_A2_TO_A1
    rts
   
B15_TO_B8
    MOVEM.L D7, -(SP)
    LSR.W   #8, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    RTS  
B4_TO_B3
    MOVEM.L D7, -(SP)
    LSL.W   #8, D7
    LSL.W   #3, D7
    LSR.W   #8, D7
    LSR.W   #6, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts
First_Nibble
    MOVEM.L D7, -(SP)
    LSR.W   #8, D7
    LSR.W   #4, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts
B7_TO_B6
    MOVEM.L D7, -(SP)
    LSL.W   #8, D7
    LSR.W   #8, D7
    LSR.W   #6, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts    

B8_TO_B6
    MOVEM.L D7, -(SP)
    LSL.W   #7, D7
    LSR.W   #8, D7
    LSR.W   #5, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts

B8    
    MOVEM.L D7, -(SP)
    LSL.W   #7, D7
    LSR.W   #8, D7
    LSR.W   #7, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts

B5_TO_B3
    MOVEM.L D7, -(SP)
    LSL.W   #8, D7
    LSL.W   #2, D7
    LSR.W   #8, D7
    LSR.W   #5, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts

B11_TO_B9 * destination register
    MOVEM.L D7, -(SP)
    LSL.W   #4, D7
    LSR.W   #8, D7
    LSR.W   #5, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts
B2_TO_B0 * source register
    MOVEM.L D7, -(SP)
    LSL.W   #8, D7
    LSL.W   #5, D7
    LSR.W   #8, D7
    LSR.W   #5, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts

B11_TO_B6
    MOVEM.L D7, -(SP)
    LSL.W   #4, D7
    LSR.W   #8, D7
    LSR.W   #2, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    rts
B5
    MOVEM.L D7, -(SP)
    LSL.W   #8, D7
    LSL.W   #2, D7
    LSR.W   #8, D7
    LSR.W   #7, D7
    MOVE.B  D7, D6
    MOVEM.L (SP)+, D7
    RTS
    END    START        ; last line of source

