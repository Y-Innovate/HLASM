# Working with data #

Here's a little sample program that works with some data:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">SAMP01   CSECT</span>  
<span style="font-family: monospace; white-space: pre">         STM   R14,R12,12(R13)   Save caller's registers in our SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R11,R15           Set up R11 for SAMP01</span>  
<span style="font-family: monospace; white-space: pre">         USING SAMP01,R11          addressability</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,SAVEAREA+4    Back chain the caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13            Save pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LA    R13,SAVEAREA      Address our own SA</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)        Forward chain our SA in caller's SA</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         LA    R2,16             Point R2 to CVT address</span>  
<span style="font-family: monospace; white-space: pre">         L     R2,0(,R2)         Point R2 to CVT</span>  
<span style="font-family: monospace; white-space: pre">         MVC   LPAR,340(R2)      Copy CVTSNAME to our LPAR variable</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         WTO   TEXT=MYWTO,ROUTCDE=11,DESC=7</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)       Restore pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)   Restore caller's registers</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15           Set return value to 0</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14               Return to caller</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">SAVEAREA DS    18F</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">MYWTO    DC    H'15'             WTO text length</span>  
<span style="font-family: monospace; white-space: pre">         DC    C'HELLO FROM '    WTO text</span>  
<span style="font-family: monospace; white-space: pre">LPAR     DC    CL4' '            Placeholder for LPAR name</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         END</span>  

This example copies the LPAR name from a z/OS control block to it's own `LPAR` variable and then uses `WTO` with the `TEXT` parameter to point it to a varying length string which is a character field preceded by a halfword length.

There's no need to define *all* the data values you need with `DC` because the Assembler can do this for you for any literals you use throughout your code. A literal is a constant value preceded by the `=` character. For any such literal used in your code instructions the Assembler will make sure there's a `DC` definition generated at the bottom of your code.

So we could rewrite the above sample like this:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">SAMP01   CSECT</span>  
<span style="font-family: monospace; white-space: pre">         STM   R14,R12,12(R13)   Save caller's registers in our SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R11,R15           Set up R11 for SAMP01</span>  
<span style="font-family: monospace; white-space: pre">         USING SAMP01,R11          addressability</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,SAVEAREA+4    Back chain the caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LR    R2,R13            Save pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LA    R13,SAVEAREA      Address our own SA</span>  
<span style="font-family: monospace; white-space: pre">         ST    R13,8(,R2)        Forward chain our SA in caller's SA</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+2(11),=C'HELLO FROM '  First bit of text</span>  
<span style="font-family: monospace; white-space: pre">         LA    R2,16             Point R2 to CVT address</span>  
<span style="font-family: monospace; white-space: pre">         L     R2,0(,R2)         Point R2 to CVT</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+13(4),340(R2)  Copy CVTSNAME to our LPAR variable</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO(2),=H'15'   Set length of varying string to 15</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         WTO   TEXT=MYWTO,ROUTCDE=11,DESC=7</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)       Restore pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)   Restore caller's registers</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15           Set return value to 0</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14               Return to caller</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">SAVEAREA DS    18F</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">MYWTO    DS    H,CL20            WTO text</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         END</span>  

Now we've simplified the memory reservation for a WTO text a the bottom of our source to a single line that defines MYWTO as a varying length string, i.e. a halfword length followed by a number of characters.

Let's pick apart the code for constructing the WTO text:  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+2(11),=C'HELLO FROM '  First bit of text</span>  
`MYWTO+2` means the address of MYWTO + 2 bytes, so the first byte of the actual text after the halfword length.  
`MYWTO+2(11)` does *not* mean it should explicitly use R11 (it does because of the `USING`), that 11 is the amount of bytes to move to the address of MYWTO + 2. Notice how the statement becomes completely different if we add a single comma, `MYWTO+2(,11)` *does* mean to move to the address R11 points to, offset with MYWTO+2, which luckily in this case would generate an assembly error or the results could be disastrous.  
`MYWTO+2(11),=C'HELLO FROM '` uses a literal `=C'HELLO FROM '` which causes the assembler to generate that constant at the bottom of the source and resolve that address to an offset of our USING R11.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LA    R2,16             Point R2 to CVT address</span>  
<span style="font-family: monospace; white-space: pre">         L     R2,0(,R2)         Point R2 to CVT</span>  
These lines are unchanged.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+13(4),340(R2)  Copy CVTSNAME to our LPAR variable</span>  
`MYWTO+13` resolves to the first byte after our `HELLO FROM ` constant (2 bytes length, 11 bytes constant).  
`MYWTO+13(4)` means move 4 bytes to that address of `MYWTO+13`.  
`MYWTO+13(4),340(R2)` still moves the LPAR name.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO(2),=H'15'   Set length of varying string to 15</span>  
`MYWTO(2)` means write to the first 2 bytes of MYWTO.  
`MYWTO(2),=H'15'` means fill that first 2 bytes with the halfword value 15.  
Hang on, the source data is a halfword, but we're using the `MVC` (move) instruction, shouldn't we use a 'move halfword' instruction? No, because there isn't one. The `MVC` (move) instruction actually doesn't care if it's moving character data or not. It's just copying memory from one place to another.

[Prev](/chapter04/definingdata.md) | [Next](/chapter04/allocatingmemory.md)