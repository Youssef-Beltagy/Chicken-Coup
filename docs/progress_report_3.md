# Progress Report 3

Date: 11/22/2020

To: CSS 422, Autumn 2020

From: Youssef Beltagy

Subject: Implemented GET_EA, ASR, LSL, NOT, RTS, JSR, AND, MULS, and LEA

---

The last report written by the lonely chicken in the Chicken Coup!



## Work Completed:

I implemented IS_EA_VALID and GET_EA. IS_EA_VALID is a subroutine that determines whether the effective address of a word is valid or not. If the EA is invalid, IS_EA_VALID calls DATAROUTINE and returns -1. GET_EA prints the effective address of the current word.



Using IS_EA_VALID and GET_EA, I implemented ASR, LSL, NOT, AND, MULS, and LEA. Jordan implemented RTS before I left the team. I don't intend to redo RTS because I'm going to write the same code anyway. Though I can re-implement RTS if you wish me to.



I finished the main loop. It now asks the user for input after it finishes disassembling the memory and prints the disassembled code screen by screen.



I figured out the signature for ADD and SUB. I made a fancy startup message.



I updated and improved the design. I updated the input and verification logic. I didn't update the logic that chooses the op-codes because it hasn't changed. I intend to include a table of subroutine signatures in my final documentation.

![](https://68k-disassembler.ybeltagy.com/disassembler_design_2.png)




## Problems:

Maybe it is that I left my team? I don't know what to write in here.



In terms of coding, it has been smooth. Nothing is behaving unexpectedly. My biggest concern right now is the documentation. Documenting will take a lot of time even though I have no use for those documents and designs. I didn't need a newer design since the first one. The only reason I updated the design is this report.



I have found some things I want clarifications on. But they are not problems. I will come at office hours.



## Work Scheduled:

Well, I'm a one-man team, so I have the rest of the work scheduled like this:

1. ADD
2. SUB
3. MOVE
4. MOVEM
5. Final tests and code review
6. Documentation
7. Refactoring the code if needed

 

## Evaluation:

Is there a meaning to this section at this point?

I wrote all the code except for RTS which Jordan implemented before I left the team.

![](https://68k-disassembler.ybeltagy.com/progress_report_3.png)