# Questions

This file is for documenting questions to the professor and their answers.

- How should we handle unimplemented addressing modes? Don't worry about them. We will not be tested for unrequired addressing modes.
- Should we stop disassembling when an op-code needs to access memory beyond the ending address? No, You can disassemble that op-code and exceed the ending address.
- How should we distinguish between ADD and ADDQ? They sometimes have identical signatures.
- Should we Implement ADDA?
- How do we load another program in memory? This is a simulator option.
- Is jmp always 3 words?
- For immediate EA and absolute EA, should we remove the left side zeros when printing or not?
- Is it okay that i have a line when I wait for the user to continue or not?
- Can I use Github's wiki?
- I don't understand how learning assembly makes my code perform better.
- can I use github's wiki? Yes, but add the grader.
- Ask about added grader.
- Do we have to implement muls for word only or for word and long?
- Do we print muls as muls or as muls.w?
- Ask about images.
- How to test BRA Long? We don't have big enough files.
- Ask about bug in the main.






## Notes

- We can have subroutines in other files. Read the program requirements slides.
- Jump tables are explained in the addendum.
- Possibly, handle the most significant byte of the addresses in a differen way.
- Just in case, talk about how to resume printing in the documentation.
- Speed and efficiency don't matter that much.
- Just print data instead of IAM