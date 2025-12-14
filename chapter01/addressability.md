# Memory and addressability #

To access any part of the system's memory you need a pointer to it loaded in one of the general purpose registers.

Say you wanted to have R4 point to address 16, or in hex 0x00000010, you could use the `LA` (load address) instruction:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace; white-space: pre">         LA    R4,16</span>  

Before that instruction R4 would have any value, for example:  
<span style="font-family: monospace">R4 : 0x000000003F095571</span>  
And after the instruction its value would be:  
<span style="font-family: monospace">R4 : 0x0000000000000010</span>

Now R4 can be used as a pointer to whatever memory address is present at address 0x00000010, for example with the `L` (load) instruction to put the value at address 16 into register 5:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace; white-space: pre">         L     R5,0(,R4)</span>  

So again before that instruction registers R4 and R5 and the first 32 bytes of memory in the system could look like this:  
<span style="font-family: monospace; white-space: pre">                                      0 1 2 3  4 5 6 7   8 9 A B  C D E F
R4 : 0x0000000000000010   memory: 00 |00000000 00000000  00000000 00000000|
R5 : 0x00000000FFFFFF8C           10 |00FD8108 00000000  7FFFF000 7FFFF000|</span>  
And after the instruction only the value of R5 has changed, R4 and the state of the memory remains the same:  
<span style="font-family: monospace; white-space: pre">R4 : 0x0000000000000010   memory: 00 |00000000 00000000  00000000 00000000|
R5 : 0x00000000**00FD8108**           10 |00FD8108 00000000  7FFFF000 7FFFF000|</span>  

That second parameter `0(,R14)` follows a specific syntax that tells the Assembler to use R14 as a pointer, add an offset of 0 to whatever address it points to. There's one parameter omitted (between '(' and ',') where another register can be used as an index, but that's for another training.

In for example the `L` (load) and `LA` (load address) instructions, and the same goes for many instructions, the offset in machine code takes up 12 bits, so the value is at max 4095. Meaning a register used as a pointer can only point to memory address R+0 up to memory address R+4095. If it needs to point beyond that, the value in the register needs to be updated.

Say you now wanted to replace the value in R5 by the contents of the memory it points to, but offset by 140 bytes:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3</span>  
<span style="font-family: monospace; white-space: pre">         L     R5,140(,R5)</span>  

Continuing on the previous example, say R5 has the value 0x00FD8108, then the address with offset 140 would be 0x00FD8194.  
So before this instruction register 5 and the memory it points to are:  
<span style="font-family: monospace; white-space: pre">                                            0 1 2 3  4 5 6 7   8 9 A B  C D E F
R5 : 0x0000000000FD8108   memory: 00FD8190 |00FEC878 01E21D18  84A92000 00FD5EA0|</span>  
And after the instruction again only the value of R5 changed:  
<span style="font-family: monospace; white-space: pre">R5 : 0x00000000**01E21D18**   memory: 00FD8190 |00FEC878 01E21D18  84A92000 00FD5EA0|</span>  

And say you now wanted to store that value in R5 into the address pointed to by R1:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace; white-space: pre">         ST    R5,0(,R1)</span>  

Lets look at that again before and after. Before these are registers R1 and R5 and the memory pointed to by R1:  
<span style="font-family: monospace; white-space: pre">                                            0 1 2 3  4 5 6 7   8 9 A B  C D E F
R1 : 0x000000001C591240   memory: 1C591240 |00000000 00000000  00000000 00000000|
R5 : 0x0000000001E21D18</span>  
And after the instruction now only the 4 bytes at address 0x1C591240 changed:  
<span style="font-family: monospace; white-space: pre">R1 : 0x000000001C591240   memory: 1C591240 |**01E21D18** 00000000  00000000 00000000|
R5 : 0x0000000001E21D18</span>

You may have noticed that I've used example register or memory values in formats 0x00000000 and 0x0000000000000000. That's because the traditional instructions explained here all operate on 32-bit values. z/OS is a fully 64-bit capable operating system, but to program Assembler in 64-bit requires the use of other instructions that are meant for 64-bit addressability. For example the `L` (load instruction) only affects the lower 4 bytes of the register used, if you want to load 8 bytes of storage you have to use the `LG` (load 64-bit) instruction.

[Prev](/chapter01/conditioncodes.md) | [Next](/chapter02/saveareas.md)