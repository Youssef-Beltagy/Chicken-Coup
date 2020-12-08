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
- LSd and ASd have two signatures each. For the <ea> one, should we write the size or not?
- How do we test bcc with long displacement?
- LSL, ASR word on control
- Ask about ADD, SUB, and Move cases.



## Notes

- We can have subroutines in other files. Read the program requirements slides.
- Jump tables are explained in the addendum.
- Possibly, handle the most significant byte of the addresses in a different way.
- Just in case, talk about how to resume printing in the documentation.
- Speed and efficiency don't matter that much.
- Just print data instead of IAM
- The index page is somewhat outdated. Remember to update it.
- AND, ADD, and SUB are incredibly similar. One subroutine can be used for all three.
- ASR and LSL are incredibly similar. Refactor them to reuse code.
- Check whether NOT and JSR are similar or not.
- Review MOVE and MOVEM to ensure I didn't make mistakes.
- Fix the rest of the indentations
- Make data use TAB.
- Test immediate EA of size byte because I don't remember how it behaves exactly.


ADD fails with immediate data as the source.

```
0000937E  5E83                     356      add.l       #$7,d3    *immediate
00009380  0647 0010                357      add.w       #$10,d7   *immediate word
00009384  0603 0060                358      add.b       #$60,d3   *immediate byte
00009388  0684 00000234            359      add.l       #$00234,d4 * immediate long
0000938E  0685 000FF234            360      add.l       #$ff234,d5 * immediate long
00009394 
```

SUB fails with immediate data as the source

```
0973A  5F83                     653      sub.l       #$7,d3    *immediate
0000973C  0447 0010                654      sub.w       #$10,d7   *immediate word
00009740  0403 0060                655      sub.b       #$60,d3   *immediate byte
00009744  0484 00000234            656      sub.l       #$00234,d4 * immediate long
0000974A  0485 000FF234            657      sub.l       #$ff234,d5 * immediate long
00009750                           658   
```


AND when move is data in my test files.

move fails with immediate data as the source.

```
00009682  7607                     575      move.l      #$7,d3    *immediate
```

Test that the program doesn't exist with q1234567. But exists with just q.
