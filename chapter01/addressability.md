# Memory and addressability #

To access any part of the system's memory you need a pointer to it loaded in one of the general purpose registers.

Say you wanted to have R4 point to address 16, or in hex 0x00000010, you could use the load address instruction LA:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LA&nbsp;&nbsp;&nbsp;&nbsp;R4,16</span>  

Now R4 can be used as a pointer to whatever memory address was loaded from 0x00000010:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R5,0(,R4)</span>  

That second parameter `0(,R14)` follows a specific syntax that tells the Assembler to use R14 as a pointer, add an offset of 0 to whatever address it points to. There's one parameter omitted (between '(' and ',') where another register can be used as an index, but that's for another training.

In for example the load (`L`) and load address (`LA`) instructions, and the same goes for many instructions, the offset in machine code takes up 12 bits, so the value is at max 4095. Meaning a register used as a pointer can only point to memory address R+0 up to memory address R+4095. If it needs to point beyond that, the value in the register needs to be updated.

Say you now wanted to replace the value in R5 by the contents of the memory it points to, but offset by 140 bytes:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R5,140(,R5)</span>  

And say you now wanted to store that value in R5 into the address pointed to by R1:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R5,0(,R1)</span>  

You may have noticed that I've used example register values in formats 0x00000000 and 0x0000000000000000. That's because the traditional instructions explained here all operate on 32-bit values. z/OS is a fully 64-bit capable operating system, but to program Assembler in 64-bit requires the use of other instructions that are meant for 64-bit addressability. For example the load instruction `L` only affects the lower 4 bytes of the register used, if you want to load 8 bytes of storage you have to use the `LG` instruction.

[Prev](/chapter01/conditioncodes.md) | [Next](/chapter02/saveareas.md)