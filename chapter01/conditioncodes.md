# PSW and Condition codes #

## PSW ##

The Program Status Word or PSW is a 128-bit register that contains several pieces of information, but at this point in the training we'll keep it to two: the address to the next machine instruction and the condition code.

As your code executes the CPU will load every next instruction from memory before executing it. A part of the PSW register is used to point to the next instruction to be executed. If you ever look at a dump of a program that abended you'll see the contents of the 16 general purpose registers listed and the PSW, the instruction that caused the abend will the the one *before* the instruction pointed to by the PSW.

## Condition codes ##

Some of the machine instructions, apart from operating on registers and potentially memory, give off a condition code that can be read to determine what happened and what to do next. The condition code takes up only 2 bits in the PSW, so there are max 4 values possible.  
For example a compare of 2 registers (CR) can give back 3 different values in the condition code register:  
<table>
<tr><td>0</td><td>Operands are equal</td></tr>
<tr><td>1</td><td>First operand low</td></tr>
<tr><td>2</td><td>First operand high</td></tr>
</table>  
  
Another example is to add 2 registers together (AR), which can give back 4 different values in the condition code register:
<table>
<tr><td>0</td><td>Result zero; no overflow</td></tr>
<tr><td>1</td><td>Result less than zero; no overflow</td></tr>
<tr><td>2</td><td>Result greater than zero: no overflow</td></tr>
<tr><td>3</td><td>Overflow</td></tr>
</table>  

How to test the condition code is covered later.

[Prev](/chapter01/registers.md) | [Next](/chapter01/addressability.md)