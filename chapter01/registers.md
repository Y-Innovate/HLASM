# Registers #

Every computer, whether that's a mainframe, or a laptop, or an iPhone works with registers. These are bit of hardware inside your CPU/core that can contain binary values of up to a fixed number of bytes (usually 8). When your code executes, what happens is that some parts of the computer's memory contain your code, other parts of memory contain your data/variables, your code is executed machine instruction by machine instruction and each of those machine instructions operate on one or more registers and often times in combination with your data/variables.

><span style="font-family: monospace">memory</span>  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----</span>  
<span style="font-family: monospace">0000000000000000000000000000000000000000000000000000000000000000  
0000000000000000000000000000000000000000000000000000000000000000  
0000000your code somewhere in memory in machine instructions0000  
0000000000000000000000000000000000000000000000000000000000000000  
0000000000000000000000000000000000000000000000000000000000000000  
0000your data somewhere else in memory00000000000000000000000000  
0000000000000000000000000000000000000000000000000000000000000000  
0000000000000000000000000000000000000000000000000000000000000000</span>
  
><span style="font-family: monospace">registers  
R0&nbsp; : 0x0011002200330044  
R1&nbsp; : 0x5500660077008800  
R2&nbsp; : 0x0000000012345678  
R3&nbsp; : 0x0000000087654321  
R4&nbsp; : 0xABCDEF00ABCDEF00  
R5&nbsp; : 0x00000000DEADBEEF  
R6&nbsp; : 0xAA00FF00BB00DD00  
R7&nbsp; : 0x00EE00CC00998877  
R8&nbsp; : 0x0000000000182243  
R9&nbsp; : 0x00000000FFFFFFFD  
R10 : 0x0000000000000000  
R11 : 0x0000000019C5DD02  
R12 : 0x0000000019C5DDF0  
R13 : 0x1199000000000000  
R14 : 0x0000000089C5DC40  
R15 : 0x0000000000000000</span>

There are many different such machine instructions, the most common ones are for example for fetching some data from memory into a register (load, `L`), storing the contents of a register in memory (store, `ST`), getting the address of some data in memory and putting that address in a register (load address, `LA`), copying some data from one address in memory to another address (move, `MVC`), etc.

In for example X86 architecture the machine instructions are very different from the ones for s390x, for some of the instructions on X86 there are specific registers you HAVE to use. For s390x that's not the case, on Z you have a set of 16 general purpose registers (and a bunch more, but that's not for this training) that can be used for a large majority of the instructions. There are programming conventions though, so it's not entirely free-for-all.

Those 16 general purpose registers are used simply by their number, so for example:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2,3</span>  
is a valid instruction that copies the value of register 3 to register 2.

Meaning if the values of registers 2 and 3 before the instruction were:  
<span style="font-family: monospace">R2 : 0x0000000000245118  
R3 : 0x000000001D300017</span>  
Then afterwards they would contain:  
<span style="font-family: monospace">R2 : 0x000000001D300017  
R3 : 0x000000001D300017</span>

Because you'll use other numbers intensively in your HLASM sources (for offsets for example) what's very common is to use HLASM equates to have the words R0, R1, R2, .... R15 equate to the numeric values 0 - 15 so that you can use for example `R2` to mean register 2. Those equates are shown later on in this training, for now just assume R0 - R15 are valid names of registers, which makes the same instruction a little more readable:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R2,R3</span>  

[Next](/chapter01/conditioncodes.md)