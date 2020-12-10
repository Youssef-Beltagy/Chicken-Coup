*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Youssef Beltagy
* Date       : 10/25/2020
* Description: A 68k Disassembler
*-----------------------------------------------------------

    ORG    $1000
START:                  ; first instruction of program

    * print the start message
    lea         PROGRAM_START_MESSAGE,a1
    move.b      #14,d0
    trap        #15
    bra         MAIN_GET_USER_INPUT

MAIN_GET_NEW_ADDRESSES: * ask for user input again.
    lea         MORE_MEMORY_MESSAGE,a1
    move.b      #14,d0
    trap        #15
    bra         MAIN_GET_USER_INPUT

MAIN_GET_USER_INPUT:
    * GET the valid user input or exit the program.
    jsr         INPUT_OR_EXIT
    cmp.l       #-1,d7
    beq         EXIT_PROGRAM

    *The Main Loop
    movea.l     INPUT_START,a6 * Initialize the loop.
    move.l      #INITIAL_COUNT,MAIN_LOOP_COUNTER * print INITIAL_COUNT lines at a time.


MAIN_LOOP:

    *Inclusive of INPUT_END
    *Will read the op-code starting at INPUT_END
    *That op-code could be 80 bytes, and there won't be a problem.

    cmp.l       INPUT_END,a6 *test exit condition
    BGT         MAIN_GET_NEW_ADDRESSES * Should you exit and ask for new addresses?

    move.l      MAIN_LOOP_COUNTER,d2 * Is the screen full and you should wait?
    cmp.l       #0,d2
    bne         MAIN_LOOP_DONT_WAIT * the screen is not full.

    jsr         CONTINUE_OR_EXIT * the screen is full.
    cmp.l       #-1,d7
    beq         EXIT_PROGRAM

MAIN_LOOP_DONT_WAIT:

    * update the counter.
    add.l       #-1,MAIN_LOOP_COUNTER

    * load the buffer
    lea         BUFFER,a1

    * print the address of the instruction
    move.l      a6,d2
    jsr         STRING_FROM_LONG
    move.b      #TAB,(a1)+ * print a tab.


    * Is this NOP?
    cmp.w       #$4E71,(a6)
    bne         SKIP_NOPROUTINE
    jsr         NOPROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_NOPROUTINE:


    * Is this RTS?
    cmp.w       #$4E75,(a6)
    bne         SKIP_RTSROUTINE
    jsr         RTSROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_RTSROUTINE:


    * Is This BCC?
    move.w      (a6),d0
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.b       #6,d0
    bne         SKIP_BCCROUTINE
    jsr         BCCROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_BCCROUTINE:

    * Is this ANDROUTINE?
    move.w      (a6),d0 * Must begin with a C.
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.b       #$C,d0
    bne         SKIP_ANDROUTINE

    move.w      (a6),d0
    lsr.w       #6,d0
    and.w       #3,d0
    cmp.b       #3,d0 * The size must not be %11 = 3
    beq         SKIP_ANDROUTINE

    move.w      (a6),d0
    btst        #8,d0
    bne         CONTINUE_CHECKING_ANDROUTINE * If the eigth bit is zero this is likely ANDROUTINE.
                * If the eight bit is 0, this is an and op-code.
                * The 0 in the eight bit chooses the direction of <ea> & Dn -> Dn 
                * The only invalid EA for this the source in this direction is An.
    lsr.w       #3,d0 * I don't think it is necessary to test for it here, but I still did.
    and.w       #7,d0
    cmp.w       #1,d0
    beq         SKIP_ANDROUTINE
    jsr         ANDROUTINE  
    bra         MAIN_LOOP_PRINT  
CONTINUE_CHECKING_ANDROUTINE:  * Else, we need to check more.

    * The destination is not a data register.
    * It must not be an Address register as well.
    * So we must check the mode of the destination operand and make sure
    * that it isn't 000 or 001
    lsr.w       #3,d0
    and.w       #7,d0
    cmp.w       #2,d0
    blt         SKIP_ANDROUTINE
    jsr         ANDROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_ANDROUTINE:

    *Is this JSR
    move.w      (a6),d0
    lsr.w       #6,d0
    cmp.w       #$13a,d0
    bne         SKIP_JSRROUTINE
    jsr         JSRROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_JSRROUTINE

    *Is this NOT?
    move.w      (a6),d0 * the most significant byte must be $46
    lsr.w       #8,d0
    cmp.w       #$46,d0
    bne         SKIP_NOTROUTINE

    move.w      (a6),d0 * the size must not be 11.
    lsr.w       #6,d0 
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SKIP_NOTROUTINE
    jsr         NOTROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_NOTROUTINE:

    *Is this LEA
    move.w      (a6),d0
    lsr.w       #4,d0 *cut out the register number
    lsl.b       #3,d0 *using the barrier between words and bytes.
    lsr.w       #5,d0
    cmp.w       #$27,d0
    bne         SKIP_LEAROUTINE
    jsr         LEAROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_LEAROUTINE:

    *Is this MULS
    move.w      (a6),d0
    lsr.w       #4,d0 *cut out the register number 
    lsl.b       #3,d0 *using the barrier between words and bytes
    lsr.w       #5,d0
    cmp.w       #$67,d0
    bne         SKIP_MULSROUTINE
    jsr         MULSROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_MULSROUTINE:

    *Is this LSL
    move.w      (a6),d0
    lsr.w       #6,d0
    cmp.w       #$38f,d0
    bne         CONTINUE_LSLROUTINE
    jsr         LSLROUTINE
    bra         MAIN_LOOP_PRINT
CONTINUE_LSLROUTINE:

    * test the first nibble
    move.w      (a6),d0
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.w       #$e,d0
    bne         SKIP_LSLROUTINE

    * test the size.
    move.w      (a6),d0
    lsr.w       #6,d0
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SKIP_LSLROUTINE

    * test the direction
    move.w      (a6),d0
    btst        #8,d0
    beq         SKIP_LSLROUTINE * if the direction is 0 (LSR), skip

    * Is this LSL or nother shift left?
    lsr.w       #3,d0
    and.w       #3,d0
    cmp.w       #1,d0
    bne         SKIP_LSLROUTINE

    jsr         LSLROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_LSLROUTINE:


*Is this ASR
    move.w      (a6),d0
    lsr.w       #6,d0
    cmp.w       #$383,d0
    bne         CONTINUE_ASRROUTINE
    jsr         ASRROUTINE
    bra         MAIN_LOOP_PRINT
CONTINUE_ASRROUTINE:

    * test the first nibble
    move.w      (a6),d0
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.w       #$e,d0
    bne         SKIP_ASRROUTINE

    * test the size.
    move.w      (a6),d0
    lsr.w       #6,d0
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SKIP_ASRROUTINE

    * test the direction
    move.w      (a6),d0
    btst        #8,d0
    bne         SKIP_ASRROUTINE * if the direction is 1 (ASL), skip

    * Is this ASR or another shift left?
    lsr.w       #3,d0
    and.w       #3,d0
    cmp.w       #0,d0
    bne         SKIP_ASRROUTINE

    jsr         ASRROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_ASRROUTINE:

    
    *Is this add?
    move.w      (a6),d0
    lsr.w       #6,d0 * Is the first nibble d?
    lsr.w       #6,d0
    cmp.b       #$d,d0
    bne         SKIP_ADDROUTINE

    move.w      (a6),d0 * Check the size. 
    lsr.w       #6,d0 * The size must not be 11
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SKIP_ADDROUTINE

    move.w      (a6),d0 * If the direction is 0, then it must be add.
    btst        #8,d0
    bne         CONTINUE_ADDROUTINE
    jsr         ADDROUTINE 
    bra         MAIN_LOOP_PRINT
CONTINUE_ADDROUTINE:

    lsr.w       #3,d0 * the direction is is dn + <ea> -> <ea>
    and.w       #7,d0 * then check that the destination is not an An or Dn.
    cmp.w       #2,d0 * Distinguishes ADD from ADDX
    blt         SKIP_ADDROUTINE
    jsr         ADDROUTINE 
    bra         MAIN_LOOP_PRINT
SKIP_ADDROUTINE:

    *Is this sub?
    move.w      (a6),d0 * Is the first nibble 9?
    lsr.w       #6,d0
    lsr.w       #6,d0
    cmp.b       #$9,d0
    bne         SKIP_SUBROUTINE

    move.w      (a6),d0 *check the size.
    lsr.w       #6,d0 * must not be 11
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SKIP_SUBROUTINE

    move.w      (a6),d0 * if the direction is 0, then it must be SUB
    btst        #8,d0
    bne         CONTINUE_SUBROUTINE
    jsr         SUBROUTINE 
    bra         MAIN_LOOP_PRINT
CONTINUE_SUBROUTINE:

    lsr.w       #3,d0 * the direction is is dn + <ea> -> <ea>
    and.w       #7,d0 * then check that the destination is not an An or Dn.
    cmp.w       #2,d0 * Distinguishes SUB from SUBX
    blt         SKIP_SUBROUTINE
    jsr         SUBROUTINE 
    bra         MAIN_LOOP_PRINT
SKIP_SUBROUTINE:

    *Is this move?
    move.w      (a6),d0
    lsr.w       #7,d0 * Are the first two bits zeros or not?
    lsr.w       #7,d0
    cmp.w       #0,d0
    bne         SKIP_MOVEROUTINE

    move.w      (a6),d0
    lsr.w       #8,d0 * Is the first nibble zero or 1/2/3
    lsr.w       #4,d0
    cmp.w       #0,d0
    beq         SKIP_MOVEROUTINE

    jsr         MOVEROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_MOVEROUTINE:

    *Is this MOVEM
    move.w      (a6),d0 * crop the direction using
    lsr.w       #3,d0 * the barrier between bytes and words.
    lsl.b       #1,d0
    lsr.w       #5,d0
    cmp.w       #$49,d0
    bne         SKIP_MOVEMROUTINE

    move.w      (a6),d0 * If the addressing mode is Dn,
    lsr.w       #3,d0 * this is not movem.
    and.w       #7,d0
    cmp.w       #0,d0
    beq         SKIP_MOVEMROUTINE * get rid of ext

    jsr         MOVEMROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_MOVEMROUTINE:

* the default subroutine if no other routines are called is
* the data ROUTINE
    jsr         DATAROUTINE


MAIN_LOOP_PRINT:
    * Finally, print the op-code.
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
*and INPUT_START is even.
*sets d7 to 0 for valid input and to -1 for exit.
*Nothing changes other than INPUT_START, INPUT_END, and d7
*Input: nothing
*Output: d7.l, INPUT_START, INPUT_END
    movem.l     a1/d0/d1/d6,-(sp)

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
    bne         INPUT_OR_EXIT_SKIP_Q_CHECK

    *program termination value
    cmp.b       #113,(a1) *113 is for 'q'
    beq         INPUT_OR_EXIT_TERMINATE *return exit code
INPUT_OR_EXIT_SKIP_Q_CHECK:

    *convert the string into a long
    jsr         LONG_FROM_STRING
    cmp.l       #-1,d7
    beq         INPUT_OR_EXIT_INVALID

    *Test that the start address is even
    btst        #0,d6
    bne         INPUT_OR_EXIT_INVALID_ODD 

    *Test that the most significant byte is 00.
    move.l      d6,d0
    move.l      #24,d1
    lsr.l       d1,d0
    cmp.b       #0,d0
    bne         INPUT_OR_EXIT_INVALID_NOT_00

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

    *Test that the most significant byte is 00.
    move.l      d6,d0
    move.l      #24,d1
    lsr.l       d1,d0
    cmp.b       #0,d0
    bne         INPUT_OR_EXIT_INVALID_NOT_00

    *Check the validity of the addresses
    cmp.l       INPUT_START,d6
    blt         INPUT_OR_EXIT_INVALID_GT
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

INPUT_OR_EXIT_INVALID_ODD:
    *prints invalid message for odd start address
    *and prompts for input again
    lea         INVALID_MESSAGE_ODD,a1
    move.b      #14,d0
    trap        #15
    bra         INPUT_OR_EXIT_LOOP

INPUT_OR_EXIT_INVALID_GT:
    *prints invalid message when the start address is greater
    *than the ending address and prompts for input again.
    lea         INVALID_MESSAGE_GT,a1
    move.b      #14,d0
    trap        #15
    bra         INPUT_OR_EXIT_LOOP

INPUT_OR_EXIT_INVALID_NOT_00:
    *prints invalid message when the most significant byte of the
    *address is not 0 and prompts for input again.
    lea         INVALID_MESSAGE_NOT_00,a1
    move.b      #14,d0
    trap        #15
    bra         INPUT_OR_EXIT_LOOP

INPUT_OR_EXIT_TERMINATE:
    move.l      #-1,d7
INPUT_OR_EXIT_END:
    movem.l     (sp)+,a1/d0/d1/d6
    rts
* End of INPUT_OR_EXIT

CONTINUE_OR_EXIT:
*Description:
*Ensures that MAIN_LOOP_COUNTER is reset or that
*d7.l = -1 to indicate that the program should terminate.
*nothing changes other than MAIN_LOOP_COUNTER or d7.l
*Input: nothing
*Output: d7.l
    movem.l     d0/d1/a1,-(sp)

CONTINUE_OR_EXIT_LOOP:

    *get the input
    lea         BUFFER,a1
    move.b      #2,d0
    trap        #15

    *If the size of the string is 0, this was just enter.
    cmp.w       #0,d1
    beq         CONTINUE_OR_EXIT_CONTINUE

    cmp.w       #1,d1 * More than one character is invalid input
    bne         CONTINUE_OR_EXIT_INVALID 

    *program termination value
    cmp.b       #113,(a1) *113 is for 'q'
    beq         CONTINUE_OR_EXIT_TERMINATE *return exit code

    * this must have been invalid input by this point.
    bra         CONTINUE_OR_EXIT_INVALID


CONTINUE_OR_EXIT_INVALID:
    *prints invalid message
    *and prompts for input again
    lea         WAIT_INVALID_MESSAGE,a1
    move.b      #14,d0
    trap        #15
    bra         CONTINUE_OR_EXIT_LOOP


CONTINUE_OR_EXIT_CONTINUE:
    move.l      #INITIAL_COUNT,MAIN_LOOP_COUNTER * print INITIAL_COUNT lines at a time.
    move.l      #0,d7
    bra         CONTINUE_OR_EXIT_END

CONTINUE_OR_EXIT_TERMINATE:
    move.l      #-1,d7
CONTINUE_OR_EXIT_END:
    movem.l     (sp)+,d0/d1/a1
    rts
* End of CONTINUE_OR_EXIT


LONG_FROM_STRING:
*Description:
*Given a string at a1 and its size at d1.w, returns a hex number at 
*d6 and 0 at d7.l, or -1 at d7.l to represent an error.
*nothing other than d7 and d6 will change
*Input: a1, d1.w
*Output: d7.l, d6.l

    movem.l     d0/d1/a1,-(sp)

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
    add.l   d1,d6 * PUT the digit value in the least significant bit of d6.
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
    movem.l     (sp)+,d0/d1/a1
    rts
* End of LONG_FROM_STRING subroutine

STRING_FROM_NIBBLE:
*Description:
*Given the lower nibble at d2.b, will convert that into a char in the
*memory pointed to by a1.
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    movem.l     d2,-(sp)

    and.b       #$0f,d2 *get rid of extra bits.

    cmp.b       #9,d2
    bgt         STRING_FROM_NIBBLE_CHAR * is this byte A-F
    add.b       #48,d2 * this byte is 0-9
    move.b      d2,(a1)+
    bra         STRING_FROM_NIBBLE_END

STRING_FROM_NIBBLE_CHAR: *this byte is A-F
    add.b       #55,d2
    move.b      d2,(a1)+

STRING_FROM_NIBBLE_END:
    movem.l     (sp)+,d2
    rts
* End of STRING_FROM_NIBBLE

STRING_FROM_BYTE:
*Description:
*Given a byte at d2.b, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    movem.l     d0,-(sp)

    move.l      d2,d0
    lsr.b       #4,d2
    jsr         STRING_FROM_NIBBLE

    move.l      d0,d2
    jsr         STRING_FROM_NIBBLE

STRING_FROM_BYTE_END:
    movem.l     (sp)+,d0
    rts
* End of STRING_FROM_BYTE

STRING_FROM_WORD:
*Description:
*Given a word at d2.w, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.w
*Output: a1 and the memory it points to
    movem.l     d0,-(sp)

    move.l      d2,d0
    lsr.w       #8,d2
    jsr         STRING_FROM_BYTE

    move.l      d0,d2
    jsr         STRING_FROM_BYTE

STRING_FROM_WORD_END:
    movem.l     (sp)+,d0
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
*copy the string to a1 except the terminating null.
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

IS_EA_VALID:
*Description:
*Determines if the EA of the current op-code at (a6) is valid or not.
*If the effective address is not valid, then calls DATAROUTINE
*and returns -1 in d7.l.
*If the effective address is valid, returns 0 in d7.l
*Nothing should be affected other than a6, d7.l, a1,
*and the memory a1 points to.
*Input: a6, a1
*Output: a6, d7.l, a1, and the memory pointed to by a1.
    movem.l     d0/d1,-(sp)

    move.w      (a6),d0 * Get the lest significant six bits at (a6)
    and.l       #$3f,d0       

    move.l      d0,d1 * copy to d1.

    lsr.b       #3,d0 * d0 represents the mode from now on.
    and.b       #7,d1 * d1 represents the register bits from now on.

    cmp.b       #5,d0
    blt         IS_EA_VALID_TRUE * The first 5 addressing modes are valid.

    cmp.b       #7,d0
    blt         IS_EA_VALID_FALSE * the sixth and seventh addressing modes are invalid.

    * that leaves the last addressing mode.
    * I will use the 3 register bits at d1 to make decisions from now on.

    cmp.b       #2,d1 * the first two modes are valid.
    blt         IS_EA_VALID_TRUE * abs short and abs long

    cmp.b       #4,d1 * the immediate addressing mode.
    beq         IS_EA_VALID_TRUE


    * Any other mode is invalid by this point.

IS_EA_VALID_FALSE:
    jsr         DATAROUTINE * call dataroutine.
    move.l      #-1,d7 * return -1 to represent an invalid EA
    bra         IS_EA_VALID_END

IS_EA_VALID_TRUE:
    move.l      #0,d7 * return 0 to represent a valid EA

IS_EA_VALID_END:
    movem.l     (sp)+,d0/d1
    rts
* End of IS_EA_VALID


GET_LIGHT_PURPLE_SIZE:
*Description:
*Given an op-code at (a6) that uses
* the light purple size in http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf.
* This subroutine will print the approperiate size (B|W|L) in the value pointed to by a1.
* If the input is Invalid, prints ERROR_STRING.
* returns the size in TEMP_VARIABLE.b.
*Input: a6
*Output: a1, TEMP_VARIABLE.b
    movem.l     d0/a2,-(sp)

    move.w      (a6),d0
    
    * get the bits at the 6th and 7th index (0-indexing from the right)
    lsr.w       #6,d0
    and.l       #3,d0

    move.b      d0,TEMP_VARIABLE * return the size in TEMP_VARIABLE.b

    cmp.b       #0,d0
    beq         GET_LIGHT_PURPLE_SIZE_BYTE

    cmp.b       #1,d0
    beq         GET_LIGHT_PURPLE_SIZE_WORD

    cmp.b       #2,d0
    beq         GET_LIGHT_PURPLE_SIZE_LONG

    *The defualt error case!
    *Print a Clear error message so the programmer knows.
    lea         ERROR_STRING,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         GET_LIGHT_PURPLE_SIZE_END

GET_LIGHT_PURPLE_SIZE_BYTE
    move.b      #66,(a1)+ * B
    bra         GET_LIGHT_PURPLE_SIZE_END

GET_LIGHT_PURPLE_SIZE_WORD
    move.b      #87,(a1)+ * W
    bra         GET_LIGHT_PURPLE_SIZE_END

GET_LIGHT_PURPLE_SIZE_LONG
    move.b      #76,(a1)+ * L
    bra         GET_LIGHT_PURPLE_SIZE_END

GET_LIGHT_PURPLE_SIZE_END:
    movem.l     (sp)+,d0/a2
    rts
* End of GET_LIGHT_PURPLE_SIZE

GET_A_REG_DIRECT:
*Description:
*Given a byte at d2.b, will print "A" then the number of the
*address register that is specified in d2.b.
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    
    move.b      #65,(a1)+ * Print A.
    
    move.b      d2,(a1)
    add.b       #48,(a1)+

    rts
* End of GET_A_REG_DIRECT

GET_D_REG_DIRECT:
*Description:
*Given a byte at d2.b, will print "D" then the number of the
*address register that is specified in d2.b.
*Assumes the data register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to

    move.b      #68,(a1)+

    move.b      d2,(a1)
    add.b       #48,(a1)+

    rts
* End of GET_D_REG_DIRECT

GET_A_REG_INDIRECT:
*Description:
*Given a byte at d2.b, will print "(A" then the number of the
*address register that is specified in d2.b and ")".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    
    move.b      #40,(a1)+
    jsr         GET_A_REG_DIRECT
    move.b      #41,(a1)+

    rts
* End of GET_A_REG_INDIRECT

GET_A_REG_INDIRECT_POST:
*Description:
*Given a byte at d2.b, will print "(A" then the number of the
*address register that is specified in d2.b and ")+".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    
    jsr         GET_A_REG_INDIRECT
    move.b      #43,(a1)+
    
    rts
* End of GET_A_REG_INDIRECT_POST

GET_A_REG_INDIRECT_PRE:
*Description:
*Given a byte at d2.b, will print "-(A" then the number of the
*address register that is specified in d2.b and ")".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    
    move.b      #45,(a1)+
    jsr         GET_A_REG_INDIRECT
    
    rts
* End of GET_A_REG_INDIRECT_PRE

GET_INVALID_ADDRESSING_MODE:
*Description:
*Loads "IAM" into the memory pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1
*Output: a1 and the memory it points to
    movem.l     a2,-(sp)

    *lea         IAM_STRING,a2
    lea         ERROR_STRING,a2 * print a clear error message so the programmer may notice.
    jsr         COPY_STRING_A2_TO_A1

    movem.l     (sp)+,a2
    rts
* End of GET_INVALID_ADDRESSING_MODE

GET_EA: * Get the effective address.
*Description:
*Requires d3.b to contain the size of the instruction in case it is immediate.
*You must set d3.b to a value in the range of [0,2]. 0 for byte. 1 for word. 2 for long.
*If d3.b contains anything aside from [0,2] and the EA was immediate, ERROR_STRING will be printed.
*Requires d2.w to contain the instruction.
*Requires a1 to point to buffer.
*Requires a6 to point to the next insturction or the memory of
*the data of this EA.
*Again, Requires a6 to point to the memory of the data of this EA or the
*next instruction.
*By the end of this subroutine, a6 will point to the next
*instruction.
*This subroutine is really powerful. But it needs to make a lot
*of assumptions. It is YOUR responsibility to ensure these
*prerequisites are correct!
*It is YOUR responsibility to print anything you need to print before
*or after GET_EA.
*Nothing other than a1 and the value it points to will change.
*input: a6, d2.w, d3.b, a1
*Output: a6, a1, and the value pointed to by a1
    movem.l     A2/D0-D3, -(sp)
    
    move.l      #0,d0
    move.w      d2,d0 * The instruction is in d0 from now.

    * The register will be stored in d2.
    and.l       #$7,d2

    move.l      d0,d1 * The mode will be stored in d1.
    lsr.w       #3,d1
    and.w       #$7,d1

    * Because of the jmp size variation issue I talked
    * to the professor about, all jmps should be below
    * the jmp table.
    * Basically, we found that if you jmp down, the 
    * jmp op-code is three words.
    * If you jmp up, jmp could be two words or three words.
    * This variation can wreck a jmp table.
    * See how these will be encoded differently if you uncomment them:
    * jmp GET_EA
    * jmp GET_EA_JMP_TABLE
    lea         GET_EA_JMP_TABLE,a2
    mulu.w      #6,d1 * values between [0,42]
    jmp         (0,a2,d1)

GET_EA_JMP_TABLE: * decides which mode it is.
    jmp         GET_EA_000
    jmp         GET_EA_001
    jmp         GET_EA_010
    jmp         GET_EA_011
    jmp         GET_EA_100
    jmp         GET_EA_101
    jmp         GET_EA_110
    jmp         GET_EA_111

GET_EA_000: * direct data register
    jsr         GET_D_REG_DIRECT
    bra         GET_EA_END

GET_EA_001: * direct address register
    jsr         GET_A_REG_DIRECT
    bra         GET_EA_END

GET_EA_010: * indirect address register
    jsr         GET_A_REG_INDIRECT
    bra         GET_EA_END

GET_EA_011: * indirect address register with post-increment
    jsr         GET_A_REG_INDIRECT_POST
    bra         GET_EA_END

GET_EA_100: * indirect address register with pre-increment
    jsr         GET_A_REG_INDIRECT_PRE
    bra         GET_EA_END

GET_EA_101: * Invalid addressing mode
GET_EA_110: * Invalid addressing mode
    jsr         GET_INVALID_ADDRESSING_MODE
    bra         GET_EA_END

GET_EA_111: * Absolute short, absolute long, immediate, and Invalid addressing mode.
    cmp.b       #0,d2
    bne         GET_EA_111_NOT_ABS_SHORT
    move.b      #36,(a1)+ * print the dollar sign.
    move.w      (a6)+,d2 * Get the address and print it.
    jsr         STRING_FROM_WORD
    bra         GET_EA_END
GET_EA_111_NOT_ABS_SHORT:

    cmp.b       #1,d2
    bne         GET_EA_111_NOT_ABS_LONG
    move.b      #36,(a1)+ * print the dollar sign.
    move.l      (a6)+,d2 * the same as absolute word, but using a long instead
    jsr         STRING_FROM_LONG
    bra         GET_EA_END
GET_EA_111_NOT_ABS_LONG:

    cmp.b       #4,d2
    bne         GET_EA_111_NOT_IMMEDIATE

    *print "#$"
    move.b      #35,(a1)+
    move.b      #36,(a1)+

    cmp.b       #0,d3 * Immediate byte!
    bne         GET_EA_111_IMMEDIATE_NOT_B
    move.w      (a6)+,d2 * the byte is in the low-order byte of (a6).w.
    jsr         STRING_FROM_BYTE *prints the least significant byte
    bra         GET_EA_END
GET_EA_111_IMMEDIATE_NOT_B:

    cmp.b       #1,d3 * Immediate word.
    bne         GET_EA_111_IMMEDIATE_NOT_W
    move.w      (a6)+,d2
    jsr         STRING_FROM_WORD * prints the word
    bra         GET_EA_END
GET_EA_111_IMMEDIATE_NOT_W:

    cmp.b       #2,d3 *Immediate LONG
    bne         GET_EA_111_IMMEDIATE_NOT_L
    move.l      (a6)+,d2
    jsr         STRING_FROM_LONG *prints the long
    bra         GET_EA_END
GET_EA_111_IMMEDIATE_NOT_L:
    *must be an invalid addressing mode!

GET_EA_111_NOT_IMMEDIATE:
    *must be an invalid addressing mode!
    jsr         GET_INVALID_ADDRESSING_MODE
    bra         GET_EA_END

GET_EA_END:
    movem.l     (sp)+,A2/D0-D3
    rts

* End of GET_EA subroutine

LIKE_ANDROUTINE:
*Description:
*For op-codes that are structured like and, 
*loads the size and the effective addressing modes into
*buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*Assumes the effective addressing mode is valid.
*Assumes the op-code is printed.
*input: a6, a1
*Output: a6, a1, and the value pointed to by a1
    movem.l     d0-d3/a2, -(sp)

    jsr         GET_LIGHT_PURPLE_SIZE * prints the size and sets TEMP_VARIABLE.b.
    move.b      TEMP_VARIABLE,d3 * set d3.b for future use. Don't use it from now on.


    move.b      #SPC,(a1)+ * Leave some spaces to print beautifully.
    move.b      #SPC,(a1)+
    move.b      #TAB,(a1)+

    move.w      (a6)+,d2 * make d2.w contain the instruction and increment a6

    move.l      #0,d1 * clear d1
    move.w      d2,d1 * copy the instruction.
    lsl.w       #4,d1 * Make d1 contain the number of the data register.
    lsr.w       #6,d1
    lsr.w       #7,d1

    btst        #8,d2
    bne         LIKE_ANDROUTINE_TO_EA * the destination is EA.

    *The destionation is Dn.

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    *a1 is pointing to the buffer
    jsr         GET_EA  * print the effective address

    move.b      #COMMA,(a1)+ * print a comma

    move.b      d1,d2 * d2 contains the data register number now.
    jsr         GET_D_REG_DIRECT *print the data register
    bra         LIKE_ANDROUTINE_END_LINE

LIKE_ANDROUTINE_TO_EA: *the destination is EA
    move.l      d2,d0 * save d2
    move.b      d1,d2 * d2 contains the data register number now.
    jsr         GET_D_REG_DIRECT
    
    move.l      d0,d2 * load d2 again

    move.b      #COMMA,(a1)+ * print a comma

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA
    BRA         LIKE_ANDROUTINE_END_LINE

LIKE_ANDROUTINE_END_LINE:
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

LIKE_ANDROUTINE_END:
    movem.l     (sp)+,d0-d3/a2
    rts
* End of LIKE_ANDROUTINE subroutine

SHIFTROUTINE:
*Description:
*A routine to handle shift op-codes like ASR/LSL and any more if necessary.
*Requires a1 to point to buffer.
*Requires a2 to point to the string of the shift ("ASR" for example).
*Calls COPY_STRING_A2_TO_A1 and handles the size and EA of the op-code.
*If the EA is invalid, calls DATAROUTINE.
*input: a6, a2
*Output: a6, a1, the value pointed to by a1
    movem.l     a2/d0/d7/d2,-(sp)

    * test the size.
    move.w      (a6),d0
    lsr.w       #6,d0
    and.w       #3,d0
    cmp.w       #3,d0
    beq         SHIFTROUTINE_EA * This is LSL for an ea.


    * Copy the provided string to a1
    jsr         COPY_STRING_A2_TO_A1

    *Print the size.
    move.b      #PERIOD,(a1)+

    * Get the size in TEMP_VARIABLE
    jsr         GET_LIGHT_PURPLE_SIZE

    move.b      #SPC,(a1)+ * Leave some spaces to print beautifully.
    move.b      #SPC,(a1)+
    move.b      #TAB,(a1)+

    * Get the register/count
    move.w      (a6),d2
    lsr.w       #4,d2
    lsr.w       #5,d2
    and.w       #7,d2

    move.w      (a6),d0
    btst        #5,d0
    bne         SHIFTROUTINE_REGISTER * If the sixth bit is 1, then the op-code uses a register.

    * the shift op-code uses Immediate data.
    cmp.b       #0,d2 * 0 rotation is actually 8.
    bne         SHIFTROUTINE_IMMEDIATE

    move.b       #8,d2 * make the rotation 8.

SHIFTROUTINE_IMMEDIATE:
    move.b      #35,(a1)+ * print #
    add.b       #48,d2 * '0' to get values in range [1,8].
    move.b      d2,(a1)+

    bra         SHIFTROUTINE_D       

SHIFTROUTINE_REGISTER: * The source is a data register.
    jsr         GET_D_REG_DIRECT


SHIFTROUTINE_D: * the destination is a data register
    move.b      #COMMA,(a1)+

    move.w      (a6)+,d2
    and.w       #7,d2

    jsr         GET_D_REG_DIRECT
    bra         SHIFTROUTINE_END_LINE


SHIFTROUTINE_EA: * This is a shift op-code for an ea destination.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         SHIFTROUTINE_END

    * Copy the provided string to a1
    jsr         COPY_STRING_A2_TO_A1

    *Print 4 spaces for beauty.
    move.b      #SPC,(a1)+
    move.b      #SPC,(a1)+
    move.b      #SPC,(a1)+
    move.b      #SPC,(a1)+
    move.b      #TAB,(a1)+

    *prepare to call GET_EA
    move.w      (a6)+,d2

    *d2.W is prepared
    *d3.b is is never used. Don't set it. An immediate destination is not defined for shift.
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA

SHIFTROUTINE_END_LINE:
    * end the line and terminate the string
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

SHIFTROUTINE_END:
    movem.l     (sp)+,a2/d0/d7/d2
    rts
*   End of SHIFTROUTINE subroutine




* Op-code Subroutines
*-----------------------------------------------------------
* Put your Op-Code Subroutine here




ANDROUTINE:
*Description:
*Loads "AND", then the size and the effective addressing modes into
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d7,-(sp)

    * Check the validty of the addressing mode first.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         ANDROUTINE_END

    lea         AND_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "AND." into a1

    jsr         LIKE_ANDROUTINE

ANDROUTINE_END:
    movem.l     (sp)+,a2/d7
    rts
* End of ANDROUTINE subroutine

NOPROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "NOP" into BUFFER and increments a6 by two bytes
*input: a6
*Output: a6, a1, the value pointed to by a1
    movem.l     a2,-(sp)
    *If needed, could optimize memory by not copying anything except a2

    lea         NOP_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ *terminate the string
    adda.l      #2,a6

    movem.l     (sp)+,a2
    rts
* End of NOPROUTINE subroutine

RTSROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "RTS" into BUFFER and increments a6 by two bytes
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2,-(sp)

    lea         RTS_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ *terminate the string
    adda.l      #2,a6

    movem.l     (sp)+,a2
    rts
* End of RTSROUTINE subroutine

JSRROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "JSR" into BUFFER and handles its EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d7/d2, -(sp)
    *could optimize by not copying anything except a2, d7, d2

    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         JSRROUTINE_END

    lea         JSR_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    *prepare to call GET_EA
    move.w      (a6)+,d2

    *d2.W is prepared
    *d3.b should never be used because jsr doesn't accept immediate addressing modes.
    *Don't change d3 because it should not be used.
    *a6 was incremented and is prepared.
    *a1 points to the buffer
    jsr         GET_EA    
    
    * end the line and terminate the string
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

JSRROUTINE_END:
    movem.l     (sp)+,a2/d7/d2
    rts
* End of JSRROUTINE subroutine

NOTROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "NOT" into BUFFER and handles its size and EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d7/d2, -(sp)
    *could optimize by not copying anything except a2, d7, d2, and d3

    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         NOTROUTINE_END

    lea         NOT_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    * Get the size in TEMP_VARIABLE
    jsr         GET_LIGHT_PURPLE_SIZE

    move.b      #SPC,(a1)+ * Leave some spaces to print beautifully.
    move.b      #SPC,(a1)+
    move.b      #TAB,(a1)+

    *prepare to call GET_EA
    move.w      (a6)+,d2

    *d2.W is prepared
    *d3.b is not needed because NOT doesn't allow immediate addressing modes.
    *a6 was incremented and is prepared.
    *a1 points to the buffer
    jsr         GET_EA    
    
    * end the line and terminate the string
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

NOTROUTINE_END:
    movem.l     (sp)+,a2/d7/d2
    rts
* End of NOTROUTINE subroutine

LEAROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "LEA" into BUFFER and handles its EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d0/d7/d2,-(sp)
    *could optimize by not copying anything except a2, d0, d7, d2, and d3

    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         LEAROUTINE_END

    lea         LEA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    *get the address register and put it in d0
    move.w      (a6),d0
    lsl.w       #4,d0
    lsr.w       #7,d0
    lsr.w       #6,d0

    *prepare to call GET_EA
    move.w      (a6)+,d2

    *d2.W is prepared
    *d3.b is not used. lea doesn't use immediate data.
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA

    *print a comma
    move.b      #COMMA,(a1)+

    *print the address register
    move.b      d0,d2
    jsr         GET_A_REG_DIRECT    
    
    * end the line and terminate the string
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

LEAROUTINE_END:
    movem.l     (sp)+,a2/d0/d7/d2
    rts
* End of LEAROUTINE subroutine

MULSROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "MULS" into BUFFER and handles its EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d0/d2/d3/d7,-(sp)

    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         MULSROUTINE_END

    lea         MULS_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    *get the register and put it in d0
    move.w      (a6),d0
    lsl.w       #4,d0
    lsr.w       #7,d0
    lsr.w       #6,d0

    *prepare to call GET_EA
    move.w      (a6)+,d2
    move.b      #1,d3

    *d2.W is prepared
    *d3.b is prepared. d3.b is always a word.
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA

    *print a comma
    move.b      #COMMA,(a1)+

    *print the data register
    move.b      d0,d2
    jsr         GET_D_REG_DIRECT   
    
    * end the line and terminate the string
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+

MULSROUTINE_END:
    movem.l     (sp)+,a2/d0/d2/d3/d7
    rts
* End of MULSROUTINE subroutine

LSLROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "LSL" into BUFFER and handles its size and EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2,-(sp)

    lea         LSL_OPCODE,a2
    jsr         SHIFTROUTINE

    movem.l     (sp)+,a2
    rts

* End of LSLROUTINE subroutine

ASRROUTINE:
*Description:
*Requires a1 to point to buffer.
*Loads "ASR" into BUFFER and handles its size and EA.
*If the EA is invalid, calls DATAROUTINE.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2,-(sp)

    lea         ASR_OPCODE,a2
    jsr         SHIFTROUTINE

    movem.l     (sp)+,a2
    rts
* End of ASRROUTINE subroutine

DATAROUTINE:
*Description:
*Loads "DATA: $" then the hex value of the word at (a6)
*into buffer and increments a6 by two bytes.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     a2/d2,-(sp)

    lea         DATA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "DATA: $" into a1

    move.w      (a6)+,d2
    jsr         STRING_FROM_WORD     *Put the word into string from

    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+             *terminate the string

    movem.l     (sp)+,a2/d2
    rts

* End of DATAROUTINE subroutine


ADDROUTINE:
*Description:
*Loads "ADD", then the size and the effective addressing modes into
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     d7/a2, -(sp)

    * Check the validty of the addressing mode first.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         ADDROUTINE_END

    lea         ADD_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "ADD." into a1

    jsr         LIKE_ANDROUTINE * ADD is structured like AND

ADDROUTINE_END:
    movem.l     (sp)+,d7/a2
    rts
* End of ADDROUTINE subroutine

SUBROUTINE:
*Description:
*Loads "SUB.", then the size and the effective addressing modes
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     d7/a2, -(sp)

    * Check the validty of the addressing mode first.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         SUBROUTINE_END

    lea         SUB_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "SUB." into a1

    jsr         LIKE_ANDROUTINE * SUB is structured like AND

SUBROUTINE_END:
    movem.l     (sp)+,d7/a2
    rts

* End of SUBROUTINE subroutine

MOVEROUTINE:
*Description:
*Loads "MOVE.", then the size and the effective addressing modes
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     d7/d0-d4/a2, -(sp)

    * Check the validty of the source addressing mode first.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         MOVEROUTINE_END * it is okay to directly call MOVEROUTINE_END here

    move.w      (a6),d0 * put the opcode in d0.
    move.w      d0,d1 * copy to d1

    *put the mode of the destination in d0.
    lsr.w       #6,d0
    and.w       #7,d0

    *put the address of the destination in d1.
    lsl.w       #4,d1
    lsr.w       #6,d1
    lsr.w       #7,d1

    *store the EA of the destination in d4.w
    move.w      d0,d4
    lsl.w       #3,d4
    or.w        d1,d4

    * Is the destination a direct address register?
    cmp.b       #1,d0
    beq         MOVEROUTINE_DESTINATION_INVALID * Address register as the destination.

    cmp.b       #5,d0
    blt         MOVEROUTINE_DESTINATION_VALID * The first 5 addressing modes minus the direct address regsiter are valid.

    cmp.b       #7,d0
    blt         MOVEROUTINE_DESTINATION_INVALID * the sixth and seventh addressing modes are invalid.

    * that leaves the last addressing mode.
    * I will use the 3 register bits at d1 to make decisions from now on.

    cmp.b       #2,d1 * the first two modes are valid.
    blt         MOVEROUTINE_DESTINATION_VALID * abs short and abs long

    * the immediate addressing mode is valid.
    * Any other mode is invalid by this point.
    bra         MOVEROUTINE_DESTINATION_INVALID


MOVEROUTINE_DESTINATION_VALID:
    lea         MOVE_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "MOVE." into a1

    *get the size in d0
    move.l      #0,d0
    move.w      (a6),d0
    lsr.w       #6,d0
    lsr.w       #6,d0

    lea         MOVEROUTINE_SIZE_JMP_TABLE,a2
    mulu.w      #6,d0
    jmp         (0,a2,d0)

    *After the jump table, the size should be set in d3.b
MOVEROUTINE_AFTER_TABLE:

    *The source is stored before the destination if both need extension words.

    *print a few spaces.
    move.b      #TAB,(a1)+
    move.b      #SPC,(a1)+
    *move.b      #SPC,(a1)+
    *move.b      #SPC,(a1)+
    *move.b      #SPC,(a1)+
    

    * set d2.w and a6
    move.w      (a6)+,d2

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA

    *print a comma
    move.b      #COMMA,(a1)+

    *get the EA of the destination
    move.w      d4,d2

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA

    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1

    move.b      #0,(a1)+ * terminate the string.

    bra         MOVEROUTINE_END

MOVEROUTINE_SIZE_JMP_TABLE:
    jmp         MOVEROUTINE_S_00
    jmp         MOVEROUTINE_S_01
    jmp         MOVEROUTINE_S_10
    jmp         MOVEROUTINE_S_11

MOVEROUTINE_S_00: *this is an error. Print that.
    lea         ERROR_STRING,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+
    adda.l      #2,a6
    bra         MOVEROUTINE_END

MOVEROUTINE_S_01: *byte
    move.b      #0,d3 * sets the size. Don't mess with d3 from now on.
    move.b      #66,(a1)+
    bra         MOVEROUTINE_AFTER_TABLE
    
MOVEROUTINE_S_10: * long
    move.b      #2,d3 * sets the size. Don't mess with d3 from now on.  
    move.b      #76,(a1)+
    bra         MOVEROUTINE_AFTER_TABLE

MOVEROUTINE_S_11: * word
    move.b      #1,d3 * sets the size. Don't mess with d3 from now on.  
    move.b      #87,(a1)+
    bra         MOVEROUTINE_AFTER_TABLE

MOVEROUTINE_DESTINATION_INVALID:
    jsr         DATAROUTINE
MOVEROUTINE_END:
    movem.l     (sp)+,d7/d0-d4/a2
    rts
* End of MOVEROUTINE subroutine

MOVEMROUTINE:
*Description:
*Loads "MOVEM.", then the size, the register list, and the effective addressing mode
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, and the value pointed to by a1
    movem.l     a2/d7/d2,-(sp)

    * Check the validty of the EA first.
    jsr         IS_EA_VALID
    cmp.l       #-1,d7
    beq         MOVEMROUTINE_END

    move.w      (a6)+,d2 * store the op-code in d2.w
    move.w      (a6)+,d7 * store the register-list in d7.w

    * Print "MOVEM."
    lea         MOVEM_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1

    btst        #6,d2
    bne         MOVEMROUTINE_LONG * size of 1 for long

    *size of 0 for word.
    move.b      #87,(a1)+
    bra         MOVEMROUTINE_AFTER_SIZE

    *size of 1 for word.
MOVEMROUTINE_LONG:
    move.b      #76,(a1)+

    *we got the size. Let's get the EA.
MOVEMROUTINE_AFTER_SIZE:
    *move.b      #SPC,(a1)+
    *move.b      #SPC,(a1)+
    move.b      #TAB,(a1)+

    btst        #10,d2
    * if the 11th bit is 1, 
    bne         MOVEMROUTINE_M_TO_R * then the direction is memory to register

    *else, the direction is register to memory

    jsr         MOVEMROUTINE_GET_R

    move.b      #COMMA,(a1)+

    jsr         MOVEMROUTINE_GET_M
    bra         MOVEMROUTINE_END_LINE

MOVEMROUTINE_M_TO_R:
    jsr         MOVEMROUTINE_GET_M

    move.b      #COMMA,(a1)+

    jsr         MOVEMROUTINE_GET_R
    *move to MOVEMROUTINE_ENDLINE next.

MOVEMROUTINE_END_LINE:
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+
    
MOVEMROUTINE_END:
    movem.l     (sp)+,a2/d7/d2
    rts

* A subroutine to handle getting the register list.
MOVEMROUTINE_GET_R:
    movem.l     d2/d7/d1,-(sp)

    *get the addressing mode.
    lsr.w       #3,d2
    and.w       #7,d2
    cmp.w       #4,d2
    beq         MOVEMROUTINE_GET_R_PRE * Preincrement access mode.

    * otherwise it is control mode or postincrement which are treated the
    * same way.
MOVEMROUTINE_GET_R_POST:

    * It is postincrement.
    move.b      #0,d2
    move.l      #0,d1 * keep track of whether you printed before or not.
    
* GET the data registers
MOVEMROUTINE_GET_R_POST_D_LOOP:

    btst        #0,d7
    beq         MOVEMROUTINE_GET_R_POST_D_AFTER
    jsr         MOVEMROUTINE_GET_R_D_PRINT * print the data register
MOVEMROUTINE_GET_R_POST_D_AFTER:

    add.b       #1,d2 *update the loop
    lsr.w       #1,d7 *update the register list.
    cmp.b       #8,d2 *should you loop again?
    blt         MOVEMROUTINE_GET_R_POST_D_LOOP

* GET the ADDRESS registers
    move.b      #0,d2
MOVEMROUTINE_GET_R_POST_A_LOOP:

    btst        #0,d7
    beq         MOVEMROUTINE_GET_R_POST_A_AFTER
    jsr         MOVEMROUTINE_GET_R_A_PRINT * print the address register
MOVEMROUTINE_GET_R_POST_A_AFTER:

    add.b       #1,d2 *update the loop
    lsr.w       #1,d7 *update the register list.
    cmp.b       #8,d2 *should you loop again?
    blt         MOVEMROUTINE_GET_R_POST_A_LOOP

    bra         MOVEMROUTINE_GET_R_END * end the GET_R subroutine

* The branch responsible for handling registerlist of predecrement.
MOVEMROUTINE_GET_R_PRE:
    * It is pre.
    move.b      #8,d2
    move.l      #0,d1 * keep track of whether you printed before or not.

* GET the address registers.
MOVEMROUTINE_GET_R_PRE_A_LOOP:
    add.b       #-1,d2 * update the loop.

    btst        #0,d7
    beq         MOVEMROUTINE_GET_R_PRE_A_AFTER        
    jsr         MOVEMROUTINE_GET_R_A_PRINT * print the address register.
MOVEMROUTINE_GET_R_PRE_A_AFTER:

    lsr.w       #1,d7 * update the register list.
    cmp.b       #0,d2 * should you loop again?
    bgt         MOVEMROUTINE_GET_R_PRE_A_LOOP
    
* GET the data registers
    move.b      #8,d2

MOVEMROUTINE_GET_R_PRE_D_LOOP:
    add.b       #-1,d2 * update the loop.

    btst        #0,d7
    beq         MOVEMROUTINE_GET_R_PRE_D_AFTER
    jsr         MOVEMROUTINE_GET_R_D_PRINT * print the data register.
MOVEMROUTINE_GET_R_PRE_D_AFTER:

    lsr.w       #1,d7 * update the register list
    cmp.b       #0,d2 * should you loop again?
    bgt         MOVEMROUTINE_GET_R_PRE_D_LOOP

    *END the GET_R subroutine.
MOVEMROUTINE_GET_R_END: 
    movem.l     (sp)+,d2/d7/d1
    rts

    *prints the data register number d2.b
MOVEMROUTINE_GET_R_D_PRINT:
    *decide whether or not to print a slash.
    jsr         MOVEMROUTINE_GET_R_SLASH
    jsr         GET_D_REG_DIRECT
    add.b       #1,d1
    rts

    *prints the address register number d2.b
MOVEMROUTINE_GET_R_A_PRINT:
    *decide whether or not to print a slash.
    jsr         MOVEMROUTINE_GET_R_SLASH
    jsr         GET_A_REG_DIRECT
    add.b       #1,d1
    rts

    *prints a slash if this is not the first register.
MOVEMROUTINE_GET_R_SLASH:
    cmp.b       #0,d1
    beq         MOVEMROUTINE_GET_R_SLASH_END
    move.b      #47,(a1)+
MOVEMROUTINE_GET_R_SLASH_END:
    rts

* A subroutine to handle printing the EA
MOVEMROUTINE_GET_M:

    *d2.W is prepared
    *d3.b is not used because immediate addressing is not valid for MOVEM
    *a6 was incremented and is prepared.
    *a1 points to the buffer.
    jsr         GET_EA
    rts

* End of MOVEMROUTINE subroutine and its helper subroutines


BCCROUTINE:
*Description:
*HANDLES BRA, BLT, BEQ, BGE
*IF it is any other BCC, this subroutine calls the data routine.
*or just regulary print the data.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, a1, the value pointed to by a1
    movem.l     d2/a2/d0, -(sp)

    move.l      #0,d0
    move.w      (a6),d0

    *GET the condition nibble
    lsr.w       #8,d0
    and.w       #$f,d0 *get rid of the most significant nibble

    *Checks for BRA
    cmp.b       #$00,d0
    bne         BCCROUTINE_NOT_BRA
    lea         BRA_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS
BCCROUTINE_NOT_BRA:

    *Checks for BLT
    cmp.b       #$0D,d0
    bne         BCCROUTINE_NOT_BLT
    lea         BLT_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS
BCCROUTINE_NOT_BLT:

    *Checks for BGE
    cmp.b       #$0C,d0
    bne         BCCROUTINE_NOT_BGE
    lea         BGE_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS
BCCROUTINE_NOT_BGE:

    *Checks for BEQ
    cmp.b       #$07,d0
    bne         BCCROUTINE_INVALID
    lea         BEQ_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1
    bra         BCCROUTINE_GET_ADDRESS


BCCROUTINE_INVALID:
    jsr         DATAROUTINE
    bra         BCCROUTINE_END


BCCROUTINE_GET_ADDRESS:
    *The destination is the current instruction + 2 + displacement
    *even if the next word is the displacement and not an op-code.

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
    movem.l     (sp)+,d2/a2/d0
    rts

* End of BCCROUTINE subroutine

* Variables
*-----------------------------------------------------------
* Put variables and constants here

CR                  equ 13
LF                  equ 10
INITIAL_COUNT       equ 25
SPC                 equ 32
TAB                 equ 9
COMMA               equ 44
PERIOD              equ 46

BUFFER
 * an input BUFFER
    ds.b   180 *A BUFFER of 180 bytes
MAIN_LOOP_COUNTER
    ds.l    1

INPUT_START
    ds.l    1

INPUT_END
    ds.l    1

TEMP_VARIABLE
    ds.l    1

NOP_OPCODE
    dc.b    'NOP',CR,LF,0

DATA_OPCODE
    dc.b    'DATA',TAB,'   $',0 * must be null terminated

BRA_OPCODE
    dc.b    'BRA',TAB,'    $',0

BLT_OPCODE
    dc.b    'BLT',TAB,'    $',0

BGE_OPCODE
    dc.b    'BGE',TAB,'    $',0

BEQ_OPCODE
    dc.b    'BEQ',TAB,'    $',0

RTS_OPCODE
    dc.b    'RTS',CR,LF,0

AND_OPCODE
    dc.b    'AND.',0

JSR_OPCODE
    dc.b    'JSR    ',TAB,0

NOT_OPCODE
    dc.b    'NOT.',0

LEA_OPCODE
    dc.b    'LEA    ',TAB,0

MULS_OPCODE
    dc.b    'MULS   ',TAB,0

LSL_OPCODE
    dc.b    'LSL',0

ASR_OPCODE
    dc.b    'ASR',0

ADD_OPCODE
    dc.b    'ADD.',0

SUB_OPCODE
    dc.b    'SUB.',0

MOVE_OPCODE
    dc.b    'MOVE.',0

MOVEM_OPCODE
    dc.b    'MOVEM.',0

ERROR_STRING
    dc.b    'ERROR! ERROR! ERROR!',CR,LF,0

INPUT_START_MESSAGE
    dc.b   'Please enter the starting address (or q to exit): ',0

INPUT_END_MESSAGE
    dc.b   'Please enter the ending address: ',0

MORE_MEMORY_MESSAGE
    dc.b    'Finished Disassembling!',CR,LF,CR,LF
    dc.b    'Do you want to disassemble more?',CR,LF,0

TERMINATION_MESSAGE
    dc.b    'Program Terminated',0

INVALID_MESSAGE
    dc.b    'Invalid input: The input must be 8-digit hex number',CR,LF,0

INVALID_MESSAGE_ODD
    dc.b    'Invalid input: The start address must be even',CR,LF,0

INVALID_MESSAGE_GT
    dc.b    'Invalid input: The start address can not be greater than the end address.',CR,LF,0

INVALID_MESSAGE_NOT_00
    dc.b    'Invalid input: The most significant byte must be $00.',CR,LF,0

WAIT_INVALID_MESSAGE
    dc.b    'Invalid input: press enter or q.'

LINE_END
    dc.b    CR,LF,0

PROGRAM_START_MESSAGE
    dc.b    '   ___ _     _      _                  ___                    _  ',CR,LF
    dc.b    '  / __\ |__ (_) ___| | _____ _ __     / __\___  _   _ _ __   / \ ',CR,LF
    dc.b    ' / /  | ',39,'_ \| |/ __| |/ / _ \ ',39,'_ \   / /  / _ \| | | | ',39,'_ \ /  / ',CR,LF
    dc.b    '/ /___| | | | | (__|   <  __/ | | | / /__| (_) | |_| | |_) /\_/  ',CR,LF
    dc.b    '\____/|_| |_|_|\___|_|\_\___|_| |_| \____/\___/ \__,_| .__/\/    ',CR,LF
    dc.b    '                                                     |_|         ',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'           __// ',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'          /.__.\',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'          \ \/ /',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'      ',39,'___/    \',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'       \-      )',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'        \_____/',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'     _____|_|____',CR,LF
    dc.b    TAB,TAB,TAB,TAB,'           ',34,' ',34,' ',CR,LF
    dc.b    CR,LF
    dc.b    'A Motorola 68K disassembler.',CR,LF
    dc.b    CR,LF
    dc.b    TAB,'--BY Youssef Beltagy (ybeltagy or the Chicken Lord)',CR,LF
    dc.b    TAB,'Wait! Am I organizing a coup against myself?!',CR,LF
    dc.b    TAB,'No, it must be against humanity',39,'s oppression of chickens!',CR,LF
    dc.b    CR,LF
    dc.b    'Please input your addresses as 8 hex-digits!',CR,LF
    dc.b    'The most significant byte must be $00.',CR,LF
    dc.b    'When the program pauses, press enter to continue or q to exit.',CR,LF,LF,0


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
