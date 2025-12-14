# Allocating memory #

You can allocate memory with the GETMAIN macro and free it with the FREEMAIN macro.  

A macro is a separate Assembly source with a mix of macro statements and assembler statements that are inserted into your code where you code the macro name and parameters. We've seen one already, the `WTO` macro. If you've looked at your assembly listing then you've seen what instructions the `WTO` macro expanded to. GETMAIN and FREEMAIN work in the same way.

GETMAIN has a number of parameters we don't need to get into right now. One of the simplest ways to invoke it is like this:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         GETMAIN RU,LV=64</span>  
After this line R1 will contain a pointer to the allocated 64 bytes of memory.

The corresponding simplest way to invoke FREEMAIN is:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         FREEMAIN RU,LV=64,A=(R1)</span>  
Assuming R1 points to the memory that was previously GETMAIN'ed.

Having the working storage for data as part of your load module as was shown in the previous examples is usually not the best idea. If your program ends up being loaded in read-only memory it won't even work, but even if that's not the case you run the risk of a small programming error overwriting your machine code.

So it's best te keep data and code separate and the way to do that is to allocate some memory for your data at the start of your program with GETMAIN and free it at the end of your code with FREEMAIN.

Have a look at [SAMP02.jcl](/chapter04/SAMP02.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit this sample.

A couple of things to note.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">DSA      DSECT                   My dynamic storage area</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">SAVEAREA DS    18F               My save area</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">MYWTO    DS    H,CL20            WTO up to 20 characters</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">DSASIZ   EQU   \*-DSA             Calculated size of DSA</span>  
First off the data fields are now encapsulated by a so called `DSECT`, which turns the sequence of definitions into a blueprint for how a memory area is structured without actualling defining it and so without it taking up space in your load module. The equate at the end of that block has the Assembler automatically calculate the size of the DSECT in bytes by subtracting the address of the start of the DSECT (pointed to using the name `DSA`) from the current address in your code (or in this case your DSECT) indicated by the asterisk `*`.  
So in this example `*-DSA` resolves in the length of 18 fullwords and a halfword prefixed string of 20, so 18 x 4 + 2 + 20 = 94.

Technically you could allocate different chunks of memory for the save area and for your working data fields, but it's pretty common to just have the save area be at the top of one larger chunk of memory and address both the save area *and* your working data fields with one `USING` with R13.

Next lets look at what changed in the so called prolog, meaning the code at the top to set up addressability.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         GETMAIN RU,LV=DSASIZ    Allocate memory for our DSA</span>  
We're using the automatically calculated equate for the size of our DSECT to request a certain amount of bytes of memory.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,4(,R1)        Back chain the caller's SA</span>  
After the GETMAIN R1 points to the newly acquired memory, so now we can back chain the caller's SA in the 2nd fullword at the start of that area.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13            Save pointer to caller's SA</span>  
This hasn't changed, we still need to save the caller's SA in another register because we need R13 in a moment to point to our own SA.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LR    R13,R1            Address our own SA</span>  
Copy the pointer to our acquired chunk of memory to R13 since it starts with our own SA we're still following the register conventions.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         USING DSA,R13           DSA addressability</span>  
We now have a 2nd `USING`, this time to have our DSECT overlay the storage area we allocated. After this line we can use the names in the DSECT and the Assembler will correctly deduce the offset to R13 to use in all sort of instructions.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)        Forward chain our SA in caller's SA</span>  
This also hasn't changed.

Finally there are similar changes in the so called epilog, meaning the code at the bottom to wrap things up and return to the caller.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)        Restore pointer to caller's SA</span>  
This hasn't changed.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         DROP  DSA                Forget DSA addressability</span>  
The opposite of a `USING` is a `DROP` which makes the Assembler forget that a register could be used to resolve offsets from a certain base address. We're dropping whatever register pointed to DSA (R13 of course) because the memory it pointed to is about to be freed.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         FREEMAIN RU,LV=DSASIZ,A=8(,R13)  Free allocated memory</span>  
Give back the memory we allocated to the operating system's memory manager.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)   Restore caller's registers</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15           Set return value to 0</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14               Return to caller</span>  
The rest remains the same.

[Prev](/chapter04/workingwithdata.md) | [Next](/chapter05/selection.md)