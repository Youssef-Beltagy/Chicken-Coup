*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Youssef Beltagy
* Date       : 10/25/2020
* Description: A 68k Disassembler
*-----------------------------------------------------------

    ORG    $1000
START:                  ; first instruction of program

* FIXME: For Testing, DELETE LATER *============================
    bra         SKIP_TESTS * don't actually run the tests


    * write your opcodes 
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
    rts
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
    move.l      INPUT_START,d1 *
    move.b      #15,d0 *
    move.b      #16,d2 *
    trap        #15 *
    
    *starts a new line
    lea         LINE_END,a1 *
    move.b      #14,d0 *
    trap        #15 *

    move.l      INPUT_END,d1 *
    move.b      #15,d0 *
    move.b      #16,d2 *
    trap        #15 * 

    *starts a new line
    lea         LINE_END,a1 *
    move.b      #14,d0 *
    trap        #15 *

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
    cmp.b       #6,d0
    bne         SKIP_BCCROUTINE
    jsr         BCCROUTINE
    bra         MAIN_LOOP_PRINT

SKIP_BCCROUTINE:



*put more op-code subroutine calls here.
*Just like NOPROUTINE

* the default subroutine if no other routines are called is
* the data ROUTINE
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

* End of NOPROUTINE subroutine

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

NOP_OPCODE
    dc.b    'NOP',CR,LF,0

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

RTS_OPCODE
    dc.b    'RTS',CR,LF,0

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


    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
