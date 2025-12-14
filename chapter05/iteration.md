# Loops #

Have a look at [SAMP03.jcl](/samples/SAMP03.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit a program with a loop.

Let's examine a code snippet that loops 5 times and performs some logic each iteration:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+2(14),=C'COUNTING DOWN '  Prepare WTO text</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO(2),=H'16'   Prepare WTO text length</span>  
<span style="font-family: monospace; white-space: pre">         LA    R2,10             Use R2 as counter for 10 iterations</span>  
<span style="font-family: monospace; white-space: pre">NEXT_WTO EQU   \*                 Every loop around starts back here</span>  
<span style="font-family: monospace; white-space: pre">         CVD   R2,PACKED         Convert binary to packed decimal</span>  
<span style="font-family: monospace; white-space: pre">         UNPK  ZONED,PACKED      Convert packed decimal to zoned</span>  
<span style="font-family: monospace; white-space: pre">         OI    ZONED+7,X'F0'     Ignore sign nibble</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+16(2),ZONED+6  Copy 1 last digit</span>  
<span style="font-family: monospace; white-space: pre">         WTO   TEXT=MYWTO,ROUTCDE=11,DESC=7</span>  
<span style="font-family: monospace; white-space: pre">         BCT   R2,NEXT_WTO       Decrease R2 by 1 and jump if not 0</span>  

Here we go again line by line :-)

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+2(14),=C'COUNTING DOWN '  Prepare WTO text</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO(2),=H'15'   Prepare WTO text length</span>  
These two lines are done outside of the loop because they only need to be done once.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LA    R2,10             Use R2 as counter for 10 iterations</span>  
Here we're assigning the value 10 to register R2. The same could be achieved by  
<span style="font-family: monospace; white-space: pre">         L     R2,=F'10'</span>  
but the `LA` (load address) is slightly more efficient because there's no memory involved since the value 10 ends up in the machine code instruction.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CVD   R2,PACKED         Convert binary to packed decimal</span>  
<span style="font-family: monospace; white-space: pre">         UNPK  ZONED,PACKED      Convert packed decimal to zoned</span>  
<span style="font-family: monospace; white-space: pre">         OI    ZONED+7,X'F0'     Ignore sign nibble</span>  
These three instructions technically have nothing to do with looping but it's a nice opportunity to explain something else: converting your register value into readable text.  
Getting from the register value 0x0000000A to the text value '10' takes these 3 steps:  
1. Convert the binary number in our register to a packed decimal number using the `CVD` (convert to decimal) instruciton  
The first iteration, when R2 has value 10, this means our data item PACKED is assigned this value in hex:  
<span style="font-family: monospace; white-space: pre">0x000000000000010C</span>  
So every digit in a packed decimal number takes up half of a byte, also known as a nibble, and the last nibble if 0xC for positive and 0xD for negative.
2. Convert the packed decimal number to a zoned decimal number using the `UNPK` (unpack) instruction  
This means the variable PACKED value  
<span style="font-family: monospace; white-space: pre">0x000000000000010C</span>  
gets converted to the variable ZONED with value  
<span style="font-family: monospace; white-space: pre">0xF0F0F0F0F0F0F1C0</span>  
So every digit in a zoned decimal number takes up a full byte with readable digits 0xF0 to 0xF9, except the last one that now has a high nibble of 0xC for positive and 0xD for negative.
3. Overwrite the high nibble of the last byte in the zoned decimal field to make that an EBCDIC readable digit.  
This means the variable ZONED value goes from  
<span style="font-family: monospace; white-space: pre">0xF0F0F0F0F0F0F1C0</span>  
to  
<span style="font-family: monospace; white-space: pre">0xF0F0F0F0F0F0F1F0</span>  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYWTO+16(2),ZONED+6  Copy 1 last digit</span>  
<span style="font-family: monospace; white-space: pre">         WTO   TEXT=MYWTO,ROUTCDE=11,DESC=7</span>  
Here the last 2 bytes of the ZONED variable are copied to the end of our MYWTO text.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         BCT   R2,NEXT_WTO       Decrease R2 by 1 and jump if not 0</span>  
This is not an extended branching mnemonic but an actual instruction `BCT` (branch on count). This will decrease the register (in this case R2) by 1 and if the resulting value is not zero it will jump to the address (in this case NEXT_WTO).

In our DSECT we have the two added variables:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">PACKED   DS    PL8               Packed decimal 8 bytes</span>  
<span style="font-family: monospace; white-space: pre">ZONED    DS    ZL8               Zoned decimal 8 bytes</span>  
The first one is of type `P` for packed decimal and has to of length 8 to work with the `CVD` (convert to decimal) instruction.  
The second one is of type `Z` for zoned decimal and doesn't necessarily need to be of length 8 but if the number can be large (not in our case) it's best to accomodate for it.

P.S. Don't set the counting register R2 too high in the sample JCL, your colleagues on z/OS might not appreciate you filling the system log with your messages ;-).

[Prev](/chapter05/selection.md) | [Next](/chapter06/residency.md)