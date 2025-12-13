# USING #

In the previous sample code you saw a statement with the keyword `USING` which is a very powerful programming technique in Assembler. A `USING` tells the Assembler that any named address (in either your code, or in some area of memory for data) that falls within the range of R+0 to R+4095 can be resolved by the Assembler automatically. That allows you to use those names instead of having to code all addresses as register values with offsets.

Consider this bit of code:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CR&nbsp;&nbsp;&nbsp;&nbsp;R5,R6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Compare registers 5 and 6  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BC&nbsp;&nbsp;&nbsp;&nbsp;12,SKIPTO&nbsp;&nbsp;Branch to SKIPTO if R5 is less or equal to R6  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R5,R6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Put value of R6 in R5  
SKIPTO&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R5,0(,R1)&nbsp;&nbsp;Store value of R5 where R1 points to</span>  

`SKIPTO` in this example is a named address in our code meant to be a point to branch to. The actual branch instruction used is branch on condition or `BC` which I'll explain in a moment. I want to focus on how we're replacing the address of the next instruction in the PSW with the address of the statement labeled `SKIPTO` by branching to it.

If you look up the branch on condition `BC` instruction in the Principles of Operation you'll find:  
><span style="font-family: monospace">BC&nbsp;&nbsp;&nbsp;&nbsp;M</span><span style="font-family: monospace; font-size: x-small">1</span><span style="font-family: monospace">,D</span><span style="font-family: monospace; font-size: x-small">2</span><span style="font-family: monospace">(X</span><span style="font-family: monospace; font-size: x-small">2</span><span style="font-family: monospace">,B</span><span style="font-family: monospace; font-size: x-small">2</span><span style="font-family: monospace">)</span>

You might recognize that second parameter being in the format we've seen in the `L` or `LA` instructions, for example `28(,R11)`.

So the Assembler expects the branch on condition instruction in this format:  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BC&nbsp;&nbsp;&nbsp;&nbsp;12,28(,R11)  
Instead of this one:  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BC&nbsp;&nbsp;&nbsp;&nbsp;12,SKIPTO  

For the Assembler to know how to construct `28(,R11)` from the name `SKIPTO` it needs a `USING` that tells it a point in your code from which to calculate offsets from.

Let's plug our snippet into the previous entry & exit code example:

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">SAMP01&nbsp;&nbsp;&nbsp;CSECT  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;STM&nbsp;&nbsp;&nbsp;R14,R12,12(R13)&nbsp;&nbsp;&nbsp;Save caller's registers in our SA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R11,R15&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Set up R11 for SAMP01  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;USING&nbsp;SAMP01,R11&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;addressability  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R13,SAVEAREA+4&nbsp;&nbsp;&nbsp;&nbsp;Back chain the caller's SA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R2,R13&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Save pointer to caller's SA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LA&nbsp;&nbsp;&nbsp;&nbsp;R13,SAVEAREA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address our own SA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R13,8(,R2)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Forward chain our SA in caller's SA  
*  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CR&nbsp;&nbsp;&nbsp;&nbsp;R5,R6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Compare registers 5 and 6  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BC&nbsp;&nbsp;&nbsp;&nbsp;12,SKIPTO&nbsp;&nbsp;Branch to SKIPTO if R5 is less or equal to R6  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R5,R6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Put value of R6 in R5  
SKIPTO&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R5,0(,R1)&nbsp;&nbsp;Store value of R5 where R1 points to  
*  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R13,4(,R13)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Restore pointer to caller's SA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LM&nbsp;&nbsp;&nbsp;&nbsp;R14,R12,12(R13)&nbsp;&nbsp;&nbsp;Restore caller's registers  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;XR&nbsp;&nbsp;&nbsp;&nbsp;R15,R15&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Set return value to 0  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BR&nbsp;&nbsp;&nbsp;&nbsp;R14&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Return to caller  
*  
SAVEAREA DS&nbsp;&nbsp;&nbsp;&nbsp;18F  
*  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;END</span>  

Now the 3rd and 4th line of code start to make a little more sense. The 3rd line copies R15 into R11, and by convention R15 points to the first instruction at the beginning of our code. The 4th line tells the assembler that any name that falls within the range of the start of our code up to 4095 bytes beyond the start of our code can be addresses with the help of R11.

To show you how it got to the value 28 it's helpful to look at a snippet of an Assembler listing produced from assembling this code:  
<pre>  Loc    Object Code      Addr1    Addr2    Stmt  Source Statement                          HLASM R6.0  2025/12/13 11.15
00000000                00000000 00000074      1 SAMP01   CSECT                                                         
00000000 90EC D00C               0000000C      2          STM   R14,R12,12(R13)   Save caller's registers in our SA     
00000004 18BF                                  3          LR    R11,R15           Set up R11 for SAMP01                 
                    R:B 00000000               4          USING SAMP01,R11          addressability                      
00000006 50D0 B030               00000030      5          ST    R13,SAVEAREA+4    Back chain the caller's SA            
0000000A 182D                                  6          LR    R2,R13            Save pointer to caller's SA           
0000000C 41D0 B02C               0000002C      7          LA    R13,SAVEAREA      Address our own SA                    
00000010 50D0 2008               00000008      8          ST    R13,8(,R2)        Forward chain our SA in caller's SA   
                                               9 *                                                                      
00000014 1956                                 10          CR    R5,R6      Compare registers 5 and 6                    
00000016 47C0 B01C               0000001C     11          BC    12,SKIPTO  Branch to SKIPTO if R5 is less or equal to R6
0000001A 1856                                 12          LR    R5,R6      Put value of R6 in R5                        
0000001C 5050 1000               00000000     13 SKIPTO   ST    R5,0(,R1)  Store value of R5 where R1 points to         
                                              14 *                                                                      
00000020 58D0 D004               00000004     15          L     R13,4(,R13)       Restore pointer to caller's SA        
00000024 98EC D00C               0000000C     16          LM    R14,R12,12(R13)   Restore caller's registers            
00000028 17FF                                 17          XR    R15,R15           Set return value to 0                 
0000002A 07FE                                 18          BR    R14               Return to caller                      
                                              19 *                                                                      
0000002C                                      20 SAVEAREA DS    18F</pre>

In the 2nd column 'Object Code' you can see what actual machine code was produced by the Assembler for each instruction in your code. You'll see that some instructions lead to 2 bytes of machine code, some lead to 4 bytes (and there are larger ones possible for other instructions). If you add up the lengths of the instructions preceding the one we labeled `SKIPTO` you get to 28 or in hex 0x1C. In fact, the 2nd half of the machine code instruction that was generated for our branch on condition statement is `B01C`, which is `B` for register R11 and `01C` for the offset.

Also note how you can now explain how the statements referencing our variable `SAVEAREA` were resolved to offset 0x2C (and 0x30 for `SAVEAREA+4`).

[Prev](/chapter02/registerconventions.md) | [Next](/chapter02/conditioncodesrevisited.md)