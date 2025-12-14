# Programming and register conventions #

Now that we know some basics it's time to talk about programming conventions for Assembler on z/OS.  

These are the most common register purposes:
* R1 = pointer to parameter(s) passed from calling program
* R13 = pointer to calling program's save area
* R14 = return address to where calling program's code should continue after the call
* R15 = address of the start of this program's code

With this register purpose convention in mind let's look at a small piece of Assembler code:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">SAMP01   CSECT</span></span>  
<span style="font-family: monospace; white-space: pre">         STM   R14,R12,12(R13)</span>  
<span style="font-family: monospace; white-space: pre">         LR    R11,R15</span>  
<span style="font-family: monospace; white-space: pre">         USING SAMP01,R11</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,SAVEAREA+4</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13</span>  
<span style="font-family: monospace; white-space: pre">         LA    R13,SAVEAREA</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">\* Lines of code</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">         END</span>  

Let's look at that line by line.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">SAMP01   CSECT</span>  
This tells the Assembler that the lines that follow it are lines of code (as opposed to for example a DSECT to define the layout of a memory area).  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         STM   R14,R12,12(R13)</span>  
This instruction is `STM` (store multiple), which can store any number of your 16 general purpose registers and works by starting with the first parameter's register number, in this case R14, counting up and looping around to R0 to continue on to R12, effectively saving 15 registers at the address R13, offset by 12, points to. This trusts any caller follows the convention of having R13 point to it's save area.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         LR    R11,R15</span>  
Another convention is that R15, on entry to your code, points to the first instruction of your code. Because R15 is used in that way, there's a good chance it's needed for similar reasons in your code. So this statement uses `LR` (load registers) to copy the address in R15 to R11 to free up R15 for other use.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         USING SAMP01,R11</span>  
A `USING` is explained later in this training, so for now just assume it's needed to be able to access the variable SAVEAREA in the next statements. The actual variable is not shown in the sample code because it requires a bit more explaining further on in this training.  
There's no convention that dictates R11 for this purpose, but you often see the higher registers for this kind of addressability.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,SAVEAREA+4</span>  
In the previous page I explained how one of the tasks of each program is to set up a save area of it's own and chain it with the caller's save area. This statement does half of that, more specifically it sets the address of the caller's save area in the back pointer of it's own save area by using the `ST` (store) instruction.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13</span>  
Because R13 needs to be changed to point to the called program's save area instead of the caller's, we need to save the pointer to the caller's save area in another register, which could have been any, in this example we're using another `LR` (load registers) to copy R13 to R2.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         LA    R13,SAVEAREA</span>  
Here we set up R13 to point to our own save area with the `LA` (load address) instruction.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)</span>  
Three statements ago we back chained the caller's save area in our own. This statement forward chains our save area in the caller's one with another `ST` (store) instruction.

<br>  

>At this point your program is properly set up to do whatever code for its purpose. The next lines are for wrapping things up before passing control back to the caller.  

<br>  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)</span>  
This statement restores R13 to point to the caller's save area using the `L` (load) instruction. Since we're wrapping things up we know there won't be any calls from our program to another, so our own save area pointer is no longer needed.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)</span>  
This instruction is `LM` (load multiple), which is the reverse of the `STM` (store multiple) instruction explained above. It can load any number of your 16 general purpose registers and works by starting with the first parameter's register number, in this case R14, counting up and looping around to R0 to continue on to R12, effectively loading 15 registers from  the address R13, offset by 12, points to.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15</span>  
This instruction, `XR` (exclusive or registers), is used to bit-wise 'exclusive or' a register with another register. Exclusive or means the bits of both registers are combined into a new binary value where each bit position becomes '1' if only one of the bits in the same position of the input registers is '1' but not both. By exclusive or-ing a register with itself you're effectively clearing it to all '0'-s.
We're doing this to follow another register convention which is to have R15 indicate success or failure of our code to the caller, zero being success.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14</span>  
Finally we're passing control back to the calling program by branching to the address pointed to by R14. We're using the `BR` (branch register) instruction for this. Branching is the term for having the operating system continue the flow of instructions from another point in memory. Like a GO TO in COBOL.
This follows another register convention where the caller is supposed to use an instruction that branches to the beginning of our code and at the same time pass the pointer to the statement *after* its own branch instruction in R14.
By our branching to that address in R14 we're continuing the flow of instructions of the caller program right after the call to ours.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace; white-space: pre">         END</span>  
This tells the assembler our bit of code ends here.

I haven't mentioned comments yet to not make the code any more confusing. You can see a few lines of comments in the example, those are the lines that start with a non-blank in column 1.
You can also add comments on any line of code after the instruction is complete. So the same bit of code could also look like this:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">SAMP01   CSECT</span>  
<span style="font-family: monospace; white-space: pre">         STM   R14,R12,12(R13)   Save caller's registers in our SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R11,R15           Set up R11 for SAMP01</span>  
<span style="font-family: monospace; white-space: pre">         USING SAMP01,R11          addressability</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,SAVEAREA+4    Back chain the caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13            Save pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LA    R13,SAVEAREA      Address our own SA</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)        Forward chain our SA in caller's SA</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">\* Lines of code</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)       Restore pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)   Restore caller's registers</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15           Set return value to 0</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14               Return to caller</span>  
<span style="font-family: monospace; white-space: pre">*</span>  
<span style="font-family: monospace; white-space: pre">         END</span>  

[Prev](/chapter02/saveareas.md) | [Next](/chapter02/using.md)