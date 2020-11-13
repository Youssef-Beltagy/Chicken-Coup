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
    and.l       #4,d3
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

    * print the start message
    lea         PROGRAM_START_MESSAGE,a1
    move.b      #14,d0
    trap        #15

MAIN_GET_USER_INPUT:
    * GET the valid user input or exit the program.
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
    movea.l     INPUT_START,a6 * Initialize the loop.
    move.l      #INITIAL_COUNT,MAIN_LOOP_COUNTER * print INITIAL_COUNT lines at a time.


MAIN_LOOP:
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

    *Inclusive of INPUT_END
    *Will read the op-code starting at INPUT_END
    *That op-code could be 80 bytes, and there won't be a problem.

    * print the address of the instruction
    move.l      a6,d2
    jsr         STRING_FROM_LONG
    move.b      #9,(a1)+ * print a tab.


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


    * Is This BCCROUTINE?
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
    lsl.w       #4,d0
    lsl.w       #4,d0
    lsr.w       #7,d0
    lsr.w       #7,d0
    cmp.b       #3,d0 * The size must not be %11 = 3
    beq         SKIP_ANDROUTINE
    move.w      (a6),d0
    btst        #8,d0
    bne         CONTINUE_CHECKING_ANDROUTINE * If the eigth bit is zero this is likely ANDROUTINE.
                * If the eight bit is 0, this is an and op-code.
                * The 0 in the eight bit chooses the direction of <ea> & Dn -> Dn 
    lsl.b       #2,d0 *The only invalid EA for this direction is An.
    lsr.b       #5,d0 * I don't see a reason to test for it here, but I still did. FIXME: Is this a good choice?
    cmp.b       #1,d0
    beq         SKIP_ANDROUTINE
    jsr         ANDROUTINE  
    bra         MAIN_LOOP_PRINT  
CONTINUE_CHECKING_ANDROUTINE:  * Else, we need to check more.
    * The destination is not a data register.
    * It must not be an Address register as well.
    * So we must check the mode of the destination operand and make sure
    * that it isn't 000 or 001
    lsl.b       #2,d0
    lsr.b       #5,d0
    cmp.b       #0,d0
    beq         SKIP_ANDROUTINE
    cmp.b       #1,d0
    beq         SKIP_ANDROUTINE
    jsr         ANDROUTINE
    bra         MAIN_LOOP_PRINT
SKIP_ANDROUTINE:


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


MAIN_GET_NEW_ADDRESSES:
    lea         MORE_MEMORY_MESSAGE,a1
    move.b      #14,d0
    trap        #15
    bra         MAIN_GET_USER_INPUT


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
    beq         INPUT_OR_EXIT_TERMINATE *return exit code

    *convert the string into a long
    jsr         LONG_FROM_STRING
    cmp.l       #-1,d7
    beq         INPUT_OR_EXIT_INVALID

    *Test that the start address is even
    btst        #0,d6
    bne         INPUT_OR_EXIT_INVALID_ODD 

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

INPUT_OR_EXIT_TERMINATE:
    move.l      #-1,d7
INPUT_OR_EXIT_END:
    movem.l     (sp)+,d0-d6/a0-a6
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

STRING_FROM_BYTE:
*Description:
*Given a byte at d2.b, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to
    movem.l     d0/d1,-(sp)

    move.l      #0,d0 * loop variable. Used for shifting lift
    move.l      #0,d1 * temp register for the byte

STRING_FROM_BYTE_LOOP:
    move.b      d2,d1 * get the byte
    cmp.b       #8,d0 * is the loop over?
    beq         STRING_FROM_BYTE_END

    lsl.b       d0,d1  * gets rid of all excess more significant bits
    lsr.b       #4,d1  * gets rid of all excess less significant bits

    add.b       #4,d0  * Next time, shift to the lift 4 more bits

    cmp.b       #9,d1
    bgt         STRING_FROM_BYTE_CHAR * is this byte A-F
    add.b       #48,d1 * this byte is 0-9
    move.b      d1,(a1)+
    bra         STRING_FROM_BYTE_LOOP

STRING_FROM_BYTE_CHAR: *this byte is A-F
    add.b       #55,d1
    move.b      d1,(a1)+
    bra         STRING_FROM_BYTE_LOOP

STRING_FROM_BYTE_END:
    movem.l     (sp)+,d0/d1
    rts
* End of STRING_FROM_BYTE

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

GET_LIGHT_PURPLE_SIZE:
*Description:
*Given an op-code at (a6) that uses
* the light purple size in http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf.
* This subroutine will print the approperiate size (B|W|L) in the value pointed to by a1.
* If the input is Invalid, prints ERROR_STRING.
* returns the size in d3.b.
*Input: a
*Output: a1, d3.b
    movem.l     d0/a2,-(sp)

    move.w      (a6),d0 * get the bits at the 6th and 7th index (0-indexing)
    lsl.w       #4,d0
    lsl.w       #4,d0
    lsr.w       #7,d0
    lsr.w       #7,d0

    move.b      d0,d3 * return the size in d3.b

    cmp.b       #0,d0
    beq         GET_LIGHT_PURPLE_SIZE_BYTE

    cmp.b       #1,d0
    beq         GET_LIGHT_PURPLE_SIZE_WORD

    cmp.b       #2,d0
    beq         GET_LIGHT_PURPLE_SIZE_LONG

    *The defualt error case!
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
    movem.l     d2,-(sp)

    move.b      #65,(a1)+

    add.b       #48,d2
    move.b      d2,(a1)+

    movem.l     (sp)+,d2
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
    movem.l     d2,-(sp)

    move.b      #68,(a1)+

    add.b       #48,d2
    move.b      d2,(a1)+

    movem.l     (sp)+,d2
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
    movem.l     A2, -(sp)

    lea         IAM_STRING,a2
    jsr         COPY_STRING_A2_TO_A1

    movem.l     (sp)+,A2
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
*input: a6, d2.w, d3.b
*Output: a6, the value pointed to by a1
    movem.l     A2/D0-D3, -(sp)
    
    move.l      #0,d0
    move.w      d2,d0 * The instruction is in d0 from now.

    move.l      d0,d2 * The register will be stored in d2.
    and.w       #$0007,d2

    move.l      d0,d1 * The mode will be stored in d1.
    lsr.w       #3,d1
    and.w       #$0007,d1

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
    jsr         GET_INVALID_ADDRESSING_MODE
    bra         GET_EA_END

GET_EA_110: * Invalid addressing mode
    jsr         GET_INVALID_ADDRESSING_MODE
    bra         GET_EA_END

GET_EA_111: * Absolute short, absolute long, immediate, and Invalid addressing mode.
    *FIXME: THIS mode is non trivial. REVIEW IT AGAIN LATER IN THE QUARTER JUST TO BE SAFE!
    cmp.b       #0,d2
    bne         GET_EA_111_NOT_ABS_SHORT
    move.b      #36,(a1)+
    move.w      (a6)+,d2
    jsr         STRING_FROM_WORD
    bra         GET_EA_END
GET_EA_111_NOT_ABS_SHORT:

    cmp.b       #1,d2
    bne         GET_EA_111_NOT_ABS_LONG
    move.b      #36,(a1)+
    move.l      (a6)+,d2
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
    move.w      (a6)+,d2
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

    *Programmer error! Didn't set d3.b properly
    lea         ERROR_STRING,a2
    jsr         COPY_STRING_A2_TO_A1 * prints an error.
    bra         GET_EA_END

GET_EA_111_NOT_IMMEDIATE:
    *must be an invalid addressing mode!
    jsr         GET_INVALID_ADDRESSING_MODE
    bra         GET_EA_END

GET_EA_END:
    movem.l     (sp)+,A2/D0-D3
    rts

* End of GET_EA subroutine

* Op-cdoe Subroutines
*-----------------------------------------------------------
* Put your Op-Code Subroutine here

ANDROUTINE:
*Description:
*Loads "AND", then the size and the effective addressing modes into
*into buffer and makes a6 point to the next op-code.
*Requires a1 to point to buffer.
*input: a6
*Output: a6, the value pointed to by a1
    movem.l     A0/A2-A5/D0-D7, -(sp)

    lea         AND_OPCODE,a2
    jsr         COPY_STRING_A2_TO_A1 *Copy "DATA: $" into a1

    jsr         GET_LIGHT_PURPLE_SIZE * prints the size and sets d3.b. Don't touch d3.b

    move.b      #32,(a1)+ * Leave some spaces to print beautifully.
    move.b      #32,(a1)+

    move.w      (a6)+,d2 * make d2.w contain the instruction and increment a6

    move.l      #0,d1 * clear d4
    move.w      d2,d1 * copy the instruction.
    lsl.w       #4,d1 * Make d4 contain the number of the data register.
    lsr.w       #6,d1
    lsr.w       #7,d1

    btst        #8,d2
    bne         ANDROUTINE_TO_EA * the destination is EA.

    *The destionation is Dn.

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    jsr         GET_EA  * print the effective address

    move.b      #44,(a1)+ * print a comma

    move.b      d1,d2 * d2 contains the data register number now.
    jsr         GET_D_REG_DIRECT *print the data register
    bra         ANDROUTINE_END

ANDROUTINE_TO_EA: *the destination is EA
    move.l      d2,d0 * save d2
    move.b      d1,d2 * d2 contains the data register number now.
    jsr         GET_D_REG_DIRECT

    move.b      #44,(a1)+ * print a comma


    move.l      d0,d2 * load d2

    *d2.W is prepared
    *d3.b is prepared
    *a6 was incremented and is prepared.
    jsr         GET_EA
    BRA         ANDROUTINE_END

ANDROUTINE_END:
    lea         LINE_END,a2
    jsr         COPY_STRING_A2_TO_A1
    move.b      #0,(a1)+ * ybeltagy: the last line I wrote for ANDROUTINE,
                         * GET_EA, STRING_FROM_BYTE, all the GET addresses subroutines, and
                         * GET_LIGHT_PURPLE_SIZE.
                         * such long days!
    movem.l     (sp)+,A0/A2-A5/D0-D7
    rts

* End of ANDROUTINE subroutine

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

CR                  equ $0D
LF                  equ $0A
INITIAL_COUNT       equ 25

BUFFER
 * an input BUFFER
    ds.b   180 *A BUFFER of 180 bytes
MAIN_LOOP_COUNTER
    ds.l    1

INPUT_START
    ds.l    1

INPUT_END
    ds.l    1

NOP_OPCODE
    dc.b    'NOP',CR,LF,0

DATA_OPCODE
    dc.b    'DATA   $',0 * must be null terminated

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

AND_OPCODE
    dc.b    'AND.',0

IAM_STRING
    dc.b    'IAM',0

ERROR_STRING
    dc.b    'ERROR! ERROR! ERROR!',CR,LF,0

INPUT_START_MESSAGE
    dc.b   'Please enter the starting address (or q to exit): ',0

INPUT_END_MESSAGE
    dc.b   'Please enter the ending address: ',0

MORE_MEMORY_MESSAGE
    dc.b    'Finished Disassmebling!',CR,LF,CR,LF
    dc.b    'Do you want to disassemble more?',CR,LF,0

TERMINATION_MESSAGE
    dc.b    'Program Terminated',0

INVALID_MESSAGE
    dc.b    'Invalid input: The input must be 8-digit hex number',CR,LF,0

INVALID_MESSAGE_ODD
    dc.b    'Invalid input: The start address must be even',CR,LF,0

INVALID_MESSAGE_GT
    dc.b    'Invalid input: The start address can not be greater than the end address.',CR,LF,0

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
    dc.b    9,9,9,9,'           __// ',CR,LF
    dc.b    9,9,9,9,'          /.__.\',CR,LF
    dc.b    9,9,9,9,'          \ \/ /',CR,LF
    dc.b    9,9,9,9,'      ',39,'___/    \',CR,LF
    dc.b    9,9,9,9,'       \-      )',CR,LF
    dc.b    9,9,9,9,'        \_____/',CR,LF
    dc.b    9,9,9,9,'     _____|_|____',CR,LF
    dc.b    9,9,9,9,'           ',34,' ',34,' ',CR,LF
    dc.b    CR,LF
    dc.b    'A Motorola 68K disassembler.',CR,LF
    dc.b    'Please input your addresses as 8 hex-digits!',CR,LF
    dc.b    'When the program pauses, press enter to continue or q to exit.',CR,LF,LF,0


    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
