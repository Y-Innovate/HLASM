# Allocating memory #

You can allocate memory with the GETMAIN macro and free it with the FREEMAIN macro.  

A macro is a separate Assembly source with a mix of macro statements and assembler statements that are inserted into your code where you code the macro name and parameters. We've seen one already, the `WTO` macro. If you've looked at your assembly listing then you've seen what instructions the `WTO` macro expanded to. GETMAIN and FREEMAIN work in the same way.

GETMAIN has a number of parameters we don't need to get into right now. One of the simplest ways to invoke it is like this:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GETMAIN&nbsp;RU,LV=64</span>  
After this line R1 will contain a pointer to the allocated 64 bytes of memory.

The corresponding simplest way to invoke FREEMAIN is:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FREEMAIN&nbsp;RU,LV=64,A=(R1)</span>  
Assuming R1 points to the memory that was previously GETMAIN'ed.

Having the working storage for data as part of your load module as was shown in the previous examples is usually not the best idea. If your program ends up being loaded in read-only memory it won't even work, but even if that's not the case you run the risk of a small programming error overwriting your machine code.

So it's best te keep data and code separate and the way to do that is to allocate some memory for your data at the start of your program with GETMAIN and free it at the end of your code with FREEMAIN.

Have a look at [SAMP02.jcl](/chapter04/SAMP02.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit this sample.