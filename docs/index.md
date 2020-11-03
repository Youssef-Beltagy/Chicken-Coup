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
2. Address     Register Direct
3. Address     Register Indirect
4. Immediate     Data
5. Address     Register Indirect with Post incrementing
6. Address     Register Indirect with Pre decrementing
7. Absolute     Long Address
8. Absolute     Word Address



## Autumn 2020 Requirement:

1. [x] NOP
2. [ ] MOVE
3. [ ] MOVEM
4. [ ] ADD
5. [ ] SUB
6. [ ] MULS
7. [ ] DIVU
8. [ ] LEA
9. [ ] AND
10. [ ] NOT
11. [ ] LSL
12. [ ] LSR
13. [ ] ASL
14. [ ] ASR
15. [ ] Bcc     (BLT, BGE, BEQ)
16. [ ] JSR
17. [ ] RTS
18. [ ] BRA



## Design

The program will ask the user for a starting and ending memory addresses to disassemble. Then the program will loop through the memory, word-by-word, and disassemble each word.

Then the program will check if the read word matches a specific op-code signature. The program checks the op-codes one by one.

If the word matches an op-code, the subroutine for that specific op-code will be called. If the word didn't match a subroutine, the word will be treated as data, and the program will call subroutine of the data.

The program will print the op-code or data until the end of the output console or the end memory address. If the program reached the end of the output console, the program will wait for the user to press "enter" before it disassembles more. If the program reached the end of the memory, the program will restart and ask the user for a new starting and ending addresses.



### Flow-Chart

![](https://chicken-coup.ybeltagy.com/disassembler_design.png)



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

**Output = A1, A6**

**Behavior:**

 - **Process opcode and put the address of what should printed in A1.**
 - **A6 += size of the opcode**
 - **Everything else should remain unchanged.**

Every op-code subroutine should begin with

```
movem.l     A0/A2-A5/D0-D7, -(sp)
```

and end with

```
movem.l     (sp)+,A0/A2-A5/D0-D7
rts
```



#### Utility Subroutines

As we go forward in this program, we will find that some code will be used and reused. For example, the code that will write our strings.

Some op-codes are similar and will have similar code. When we detect that, we will make a utility subroutine for that.


## Notes (to do for youssef)

 - Write explanations of what to do next.

 - Make d7 as an error flag register

 - Declare input and outputs universally