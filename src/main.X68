*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Youssef Beltagy
* Date       : 10/25/2020
* Description: A 68k Disassembler
*-----------------------------------------------------------

    ORG    $1000
START:                  ; first instruction of program

* FIXME: For Testing, DELETE LATER *============================
    bra         SKIP_TESTS


    * write your opcodes here
    
    nop *
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

    *Inclusive of INPUT_END TODO: ASK the professor whether it should be inclusive or not
    *Will read the op-code starting at INPUT_END
    *That op-code could be 80 bytes, and there won't be a problem.

    cmp.w       #$4E71,(a6)
    bne         SKIP_NOPROUTINE
    jsr         NOPROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_NOPROUTINE:


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
    ble         INPUT_OR_EXIT_INVALID
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
*Given a word at a6, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 will change
*Input: a1, a6
*Output: a1
    movem.l     d0/d1,-(sp)

    move.l      #0,d0 * loop variable. Used for shifting lift
    move.l      #0,d1 * temp register for the word

STRING_FROM_WORD_LOOP:
    move.w     (a6),d1 * get the word
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
    movem.l     (sp)+,d0/d2
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
*Output: a6
    movem.l     A0-A5/D0-D7, -(sp)
    *If needed, could optimize memory by not copying anything

    *THE movem.l is not necessary for this subroutine.
    *I put it here as an example.
    *TODO: Delete the movem

    *TODO: CONSIDER ADDING an error case
    lea         NOP_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ *terminate the string
    adda.l      #2,a6


    movem.l     (sp)+,A0-A5/D0-D7
    rts

* You may want to define your constants next to your
* subroutines. TODO: delete this comment after others see it.

* End of NOPROUTINE subroutine

DATAROUTINE:
*Description:
*Loads "DATA: $" then the hex value of the word at (a6)
*into buffer and increments a6 by two bytes.
*Requires a1 to point to buffer.
*input: a6
*Output: a6
    movem.l     A0-A5/D0-D7, -(sp)
    *if needed, could optimize memory by only copying a2

    lea         DATA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "DATA: $" into a1

    jsr         STRING_FROM_WORD     *Put the word into string from

    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1

    move.b      #0,(a1)+             *terminate the string

    adda.l      #2,a6                *Move forward two bytes with a6

    lea         BUFFER,a1            *Make a1 point to the start of the string

    movem.l     (sp)+,A0-A5/D0-D7
    rts

* End of DATAROUTINE subroutine

* Variables
*-----------------------------------------------------------
* Put variables and constants here

CR          EQU $0D
LF          EQU $0A

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
    dc.b    'DATA: $',0 * must be null terminated

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
