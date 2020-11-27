# 68k Disassembler

This is a disassembler for Motorola's 68k microprocessor. Given an address in memory, this disassembler will rewrite the code there. 



## Deadline 11/21/2020 

We have a month. We can do it.



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
7. [ ] DIVU -- No longer required
8. [x] LEA
9. [x] AND
10. [x] NOT
11. [x] LSL
12. [ ] LSR -- No longer required
13. [ ] ASL -- No longer required
14. [x] ASR
15. [x] Bcc     (BLT, BGE, BEQ)
16. [x] JSR
17. [x] RTS
18. [x] BRA
19. [x] DATA as a default



## Design

The program will ask the user for a starting and ending memory addresses to disassemble. Then the program will loop through the memory, word-by-word, and disassemble each word.

Then the program will check if the read word matches a specific op-code signature. The program checks the op-codes one by one.

If the word matches an op-code, the subroutine for that specific op-code will be called. If the word didn't match a subroutine, the word will be treated as data, and the program will call subroutine of the data.

The program will print the op-code or data until the end of the output console or the end memory address. If the program reached the end of the output console, the program will wait for the user to press "enter" before it disassembles more. If the program reached the end of the memory, the program will restart and ask the user for a new starting and ending addresses.



### Flow-Chart

![](https://68k-disassembler.ybeltagy.com/disassembler_design_2.png)



### Coding Guidelines

We are a team of four. We need to define some guidelines to maximize our effectiveness. Otherwise, our code will not integrate, and we fight often.

Test your code and document these tests. Follow the guidelines of [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development).

1. Write a unit test.
2. Run the test and ensure it fails before you implement.
3. write the minimum code for the test to pass.
4. Run the test and ensure it succeeds.
5. Refactor the code until it is simple.
6. Repeat and accumulate unit tests


Test that your code works when it should and fails when it shouldn't. You don't want to print an op-code when you were given wrong input.



#### Style Guidelines

Write your code in small letters.

Write your labels in capital letters.

If you are writing the subroutine for move, label your subroutine MOVEROUTINE. Do the same for all op-codes (ADDROUTINE, NOPROUTINE, etc.).

Prepend all labels in your subroutines with the subroutine name to avoid conflicts.



#### Git Rules

For every feature, make a branch. Name the branch with that feature. Don't use your name.

When you are finished implementing a feature, make a merge request. Your code will not be merged until we have a unanimous agreement that it is correct. You are responsible for correcting anything that others point out.

Test your code. Write tests even before you begin implementation. And follow the guidelines of [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development). When you merge, show the output of your tests in a way that is convenient for you and us. It will save us all time if you show your tests. Remeber, you will review the work of others three times as much as your own. We all save time if we document our output.

Before you accept others' merge requests, read their code and test it. Don't assume their tests are enough. They might have missed, forgotten, or misinterpreted a case. We all know this, but just because the code works doesn't mean it is correct.



#### Op-Code Subroutines

If you are writing routine for move, label your routine MOVEROUTINE. Do the same for all op-codes (ADDROUTINE, NOPROUTINE, etc.).

Every op-code subroutine should only handle that op-code. It should read bytes from (A6) and load what should be printed into A1. It should increment A6 with the number of bytes it read (so A6 should point to the next op-code by the end). All other registers and memory should remain unchanged.

**Input = A6**

**Output = value pointed to by A1, A6**

**Behavior:**

 - **Process opcode and put the address of what should printed in the value pointed to by A1.**
 - **A6 += size of the opcode**
 - **Everything else should remain unchanged.**

Every op-code subroutine should begin with

```
movem.l     A0-A5/D0-D7, -(sp)
```

and end with

```
movem.l     (sp)+,A0-A5/D0-D7
rts
```



#### Utility Subroutines

As we go forward in this program, we will find that some code will be used and reused. For example, the code that will write our strings.

Some op-codes are similar and will have similar code. When we detect that, we will make a utility subroutine for that.

```assembly
LONG_FROM_STRING:
*Description:
*Given a string at a1 and its size at d1.w, returns a hex number at 
*d6 and 0 at d7.l, or -1 at d7.l to represent an error.
*nothing other than d7 and d6 will change
*Input: a1, d1.w
*Output: d7.l, d6.l

STRING_FROM_NIBBLE:
*Description:
*Given the lower nibble at d1.b, will convert that into a char in the
*memory pointed to by a1.
*nothing other than a1 and the memory it points to will change
*Input: a1, d1.b
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
*copy th string to a1 except the terminating null.
*a1 and the value it points to will change.
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
*Nothing other than a1 will change
*Input: a6, a1
*Output: a6, d7.l, a1, and the memory pointed to by a1.

GET_LIGHT_PURPLE_SIZE:
*Description:
*Given an op-code at (a6) that uses
* the light purple size in http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf.
* This subroutine will print the approperiate size (B|W|L) in the value pointed to by a1.
* If the input is Invalid, prints ERROR_STRING.
* returns the TEMP_VARIABLE.b.
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
*input: a6, d2.w, d3.b
*Output: a6, the value pointed to by a1
```