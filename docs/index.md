# 68k Disassembler

This is a disassembler for Motorola's 68k microprocessor. Given an address in memory, this disassembler will rewrite the code there. 

[Presentation Link.](https://youtu.be/Cz3WhxKClwM)



## Team members

Youssef Beltagy, the lonely chicken



## Specifications


Disassembler Description and resources: [https://canvas.uw.edu/courses/1408528/pages/project-description](https://canvas.uw.edu/courses/1408528/pages/project-description)

The Specification Page: [https://canvas.uw.edu/courses/1408528/pages/specification](https://canvas.uw.edu/courses/1408528/pages/specification)

The Required Op-codes (Also listed below): [https://canvas.uw.edu/courses/1408528/pages/required-opcodes](https://canvas.uw.edu/courses/1408528/pages/specification)



## Required op-codes and addressing modes

A list of all required tasks.



## Effective Addressing Modes:

1. Data Register Direct
2. Address Register Direct
3. Address Register Indirect
4. Immediate Data
5. Address Register Indirect with Post incrementing
6. Address Register Indirect with Pre decrementing
7. Absolute Long Address
8. Absolute Word Address



## Autumn 2020 Requirement:

1. [x] NOP
2. [x] MOVE
3. [x] MOVEM
4. [x] ADD
5. [x] SUB
6. [x] MULS
7. [ ] DIVU -- No longer required (Must not implement or I will lose points)
8. [x] LEA
9. [x] AND
10. [x] NOT
11. [x] LSL
12. [ ] LSR -- No longer required (Must not implement or I will lose points)
13. [ ] ASL -- No longer required (Must not implement or I will lose points)
14. [x] ASR
15. [x] Bcc     (BLT, BGE, BEQ)
16. [x] JSR
17. [x] RTS
18. [x] BRA
19. [x] DATA as a default



## Signature

The design is built on the concept of op-code signatures. I define a signature as the common component in the 16-bit permutations that an op-code maps onto when it is assembled. While one op-code can map onto many permutations, each permutation can only map to one op-code.

The signature must be loose enough to include all permutations of an op-code, but must be tight enough that it doesn't contain another op-code's permutations.

The set of all permutations that contain the signature is equal to the set of permutations of an op-code.

These signatures are exclusive to one op-code. Two op-codes cannot share the same signature. If a signature is shared across op-codes, then it is wrong by definition.



## Design

The program will ask the user for a starting and ending memory addresses to disassemble. Then the program will loop through the memory, word-by-word, and disassemble each word.

Then the program will check if the read word matches a specific op-code signature. The program checks the op-codes one by one.

If the word matches an op-code, the subroutine for that specific op-code is called. If the word didn't match a subroutine, the word will be treated as data, and the program will call the data subroutine.

The program will print the op-code or data until the end of the output console or the end memory address. If the program reached the end of the output console, the program will wait for the user to press "enter" before it disassembles more. If the program reached the end of the memory the user entered, the program will restart and ask the user for a new starting and ending addresses.

In the design, I distinguish between two types of subroutines. Utility subroutines are routines that handle general program logic and are to be used in multiple op-codes. Op-code Subroutines are subroutines that handle a single op-code from the beginning to the end.

Every subroutine starts with comments that explains what it does, its inputs, and its ouputs.



### Flow-Chart

![](https://68k-disassembler.ybeltagy.com/disassembler_design_2.png)



### Coding Guidelines

This is a long project. So I defined some guidelines to follow when writing the code to ensure high-quality and easy integration.


I test my code and document these tests. I follow the guidelines of [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development).

1. Write a unit test.
2. Run the test and ensure it fails before you implement.
3. write the minimum code for the test to pass.
4. Run the test and ensure it succeeds.
5. Refactor the code until it is simple.
6. Repeat and accumulate unit tests


I Test that the code works when it should and fails when it shouldn't. I don't want to print an op-code when I am given wrong input.



#### Style Guidelines

I write my code in small letters.

I write my labels in capital letters.

I follow a standard naming process for my opcode-subroutines. I prepend the name of the op-code to its subroutine. For example, I name the subroutine that handles move, MOVEROUTINE.

For labels inside subroutines, I prepend the subroutine label. For example, if I'm writing a loop inside MOVEROUTINE, I name the label for the loop MOVEROUTINE_LOOP. This allows me to avoid accidentally duplicating a label and moving the program control haphazardly.



#### Git Rules

For every feature, I make a branch. I name the branch with that feature.

When I am finished implementing a feature, I make a merge request and review it one last time.

Again, I follow the principles of test-driven development. I make tests. I ensure they fail. I make the tests pass, and I record the tests in merge requests.



#### Op-Code Subroutines

Again, each op-code has its own subroutine. The label for the subroutine is the op-code name in all capitals with "ROUTINE" appended at the end (MOVEROUTINE).

Every op-code subroutine only handle that op-code. It reads a bytes from (a6) and loads what should be printed into A1. It increments a6 with the number of bytes it read (so a6 points to the next op-code by the end). All other registers and memory should remain unchanged.

Every op-code should start with comments that explain it. It should also start by backing up the registers it uses. At the end of a subroutine, the subroutine should restore the states of the registers.

Here is an example of a subroutine op-code:

```assembly
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
```

#### Utility Subroutines

These are subroutines that I implemented as I needed in this project. I implemented them to be reusable. I ended up reusing and reusing code so that saved me time.

Here are their descriptions.

```assembly
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



CONTINUE_OR_EXIT:
*Description:
*Ensures that MAIN_LOOP_COUNTER is reset or that
*d7.l = -1 to indicate that the program should terminate.
*nothing changes other than MAIN_LOOP_COUNTER or d7.l
*Input: nothing
*Output: d7.l



LONG_FROM_STRING:
*Description:
*Given a string at a1 and its size at d1.w, returns a hex number at 
*d6 and 0 at d7.l, or -1 at d7.l to represent an error.
*nothing other than d7 and d6 will change
*Input: a1, d1.w
*Output: d7.l, d6.l


STRING_FROM_NIBBLE:
*Description:
*Given the lower nibble at d2.b, will convert that into a char in the
*memory pointed to by a1.
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


STRING_FROM_BYTE:
*Description:
*Given a byte at d2.b, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


STRING_FROM_WORD:
*Description:
*Given a word at d2.w, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.w
*Output: a1 and the memory it points to


STRING_FROM_LONG:
*Description:
*Given a long at d2.l, will convert that into a string of hex
*digits pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.l
*Output: a1 and the memory it points to


COPY_STRING_A2_TO_A1:
*Description:
*Given a null terminated string at a2, will
*copy the string to a1 except the terminating null.
*Nothing other than a1 will change
*Input: a1, a2
*Output: a1


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


GET_LIGHT_PURPLE_SIZE:
*Description:
*Given an op-code at (a6) that uses
* the light purple size in http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf.
* This subroutine will print the approperiate size (B|W|L) in the value pointed to by a1.
* If the input is Invalid, prints ERROR_STRING.
* returns the size in TEMP_VARIABLE.b.
*Input: a6
*Output: a1, TEMP_VARIABLE.b


GET_A_REG_DIRECT:
*Description:
*Given a byte at d2.b, will print "A" then the number of the
*address register that is specified in d2.b.
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


GET_D_REG_DIRECT:
*Description:
*Given a byte at d2.b, will print "D" then the number of the
*address register that is specified in d2.b.
*Assumes the data register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


GET_A_REG_INDIRECT:
*Description:
*Given a byte at d2.b, will print "(A" then the number of the
*address register that is specified in d2.b and ")".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


GET_A_REG_INDIRECT_POST:
*Description:
*Given a byte at d2.b, will print "(A" then the number of the
*address register that is specified in d2.b and ")+".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


GET_A_REG_INDIRECT_PRE:
*Description:
*Given a byte at d2.b, will print "-(A" then the number of the
*address register that is specified in d2.b and ")".
*Assumes the address register number (d2.b) is valid [0,7].
*nothing other than a1 and the memory it points to will change
*Input: a1, d2.b
*Output: a1 and the memory it points to


GET_INVALID_ADDRESSING_MODE:
*Description:
*Loads "IAM" into the memory pointed to by a1
*nothing other than a1 and the memory it points to will change
*Input: a1
*Output: a1 and the memory it points to


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


SHIFTROUTINE:
*Description:
*A routine to handle shift op-codes like ASR/LSL and any more if necessary.
*Requires a1 to point to buffer.
*Requires a2 to point to the string of the shift ("ASR" for example).
*Calls COPY_STRING_A2_TO_A1 and handles the size and EA of the op-code.
*If the EA is invalid, calls DATAROUTINE.
*input: a6, a2
*Output: a6, a1, the value pointed to by a1
```


### Appendix

#### TODO

- Review MOVE
- Review MOVEM
- Review BCC
- Clean up the report.
- Add table of Signatures



#### Coding Problems 

 - LEA: Loads the memory location to an address register. It modifies an address register to point to a new location. Once I realized that, I made a COPY_STRING_A2_TO_A1 subroutine to copy strings into A1 without pointing A1 to new memory.
 - BRA: The address of the instruction is the address of bra + 2 + the difference. This was different from what we said in class.
 - Jmp: If you jmp to a line below the current line, jmp is three words. If you jmp to a line above the current line, jmp can be two words. This messes up with jmp tables.
