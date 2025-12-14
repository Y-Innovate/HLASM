# IF - THEN - ELSE #

Let's examine a code snippet that tests the value of a byte in memory and performs an if - then - else selection:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CLI   MYSWITCH,C'Y'      Compare MYSWITCH to literal 'Y'</span>  
<span style="font-family: monospace; white-space: pre">         BNE   MYSWITCH_IS_NO     If not jump past WTO for yes</span>  
<span style="font-family: monospace; white-space: pre">         WTO   'MYSWITCH IS YES'  Put message on syslog for yes</span>  
<span style="font-family: monospace; white-space: pre">         B     MYSWITCH_DONE      Jump to end of if/then/else logic</span>  
<span style="font-family: monospace; white-space: pre">MYSWITCH_IS_NO EQU   \*            Named point in code to jump to if 'N'</span>  
<span style="font-family: monospace; white-space: pre">         WTO   'MYSWITCH IS NO'   Put message on syslog for no</span>  
<span style="font-family: monospace; white-space: pre">MYSWITCH_DONE EQU   \*             Named point in code end if/then/else</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">\* more lines of logic</span>  
<span style="font-family: monospace; white-space: pre">\* and lets imagine there's a DSECT that contains MYSWITCH and the</span>  
<span style="font-family: monospace; white-space: pre">\* addressability was set up previously</span>  
<span style="font-family: monospace; white-space: pre">MYSWITCH DS    C</span>  

Picking that apart line by line:

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CLI   MYSWITCH,C'Y'      Compare MYSWITCH to literal 'Y'</span>  
This instruction is `CLI` (compare logical immediate) which compares a single byte in memory to a literal, in this case 'Y'. Afterwards the condition code will have one of three values 0, 1 or 2 for 'equal', 'first operand low' and 'first operand high' just like we saw earlier with `CR` (compare registers).  
Note how the literal 'Y' in this instruction is not preceded by `=`. That's because the 'Y' actually becomes part of the machine code, so it needs no `DC` anywhere in the code, hence the 'immediate' part of the instruction name.  
If we pretend for a second that MYSWITCH sits at offset 72 of register R10 then the machine code for this instruction would be `95E8A048`.  
`95` is the machine code that means `CLI`  
`E8` is the literal 'Y' in EBCDIC  
`A` is register R10
`048` is the hex value of 72  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         BNE   MYSWITCH_IS_NO     If not jump past WTO for yes</span>  
Here we're using a so called 'extended mnemonic' `BNE` (branch not equal), which is fancy word for an alias to a certain `BC` (branch on condition) instruction. In this case the actual instruction that's generated is  
<span style="font-family: monospace; white-space: pre">         BC    7,MYSWITCH_IS_NO</span>  
Which is a bit mask of `b'0111'` so basically branch on any condition code but 0, hence `BNE` (branch not equal).

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         WTO   'MYSWITCH IS YES'  Put message on syslog for yes</span>  
We get to this `WTO` only if we fall through the previous `BNE`, so only when MYSWITCH is equal to 'Y'.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         B     MYSWITCH_DONE      Jump to end of if/then/else logic</span>  
This is an uncondition `B` (branch) to skip to the 'else' part of our if-then-else logic.  
Fun fact: the machine code generated for a `B` (branch) is exactly the same as for `BC` (branch on condition) with mask `b'1111'`, meaning: branch whatever the condition code may be.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">MYSWITCH_IS_NO EQU   \*            Named point in code to jump to if 'N'</span>  
This is an equate to have a name attached to this spot in the code where we can jump to if MYSWITCH is not equal to 'Y'. Equates are purely for the Assembler to calculate offsets or sizes or to make a program easier to read. It doesn't generate any machine code.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         WTO   'MYSWITCH IS NO'   Put message on syslog for no</span>  
We get to this `WTO` only if MYSWITCH is unequal to 'Y' (so not only in the case it's 'N').

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">MYSWITCH_DONE EQU   \*             Named point in code end if/then/else</span>  
Finally, another equate for us to jump to when we're done doing this if-then-else logic.