# Reading from a data set #

The next sample builds upon the previous one, it's a little bit more complicated but we're going to go through it again step by step.

Have a look at [SAMP05.jcl](/samples/SAMP05.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit this sample.

We're going to look at the additions to our data first again:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">SAVEAREA DS    18F</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">**MYDATA   DCB   DDNAME=DDIN,RECFM=FB,LRECL=80,DSORG=PS,MACRF=(GL),      X**</span>  
<span style="font-family: monospace; white-space: pre">               **DCBE=MYDATAE**</span>  
<span style="font-family: monospace; white-space: pre">**MYDATAE  DCBE  EODAD=EODAD**</span>  
<span style="font-family: monospace; white-space: pre">SYSOUT   DCB   DDNAME=SYSOUT,RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS,     X</span>  
<span style="font-family: monospace; white-space: pre">               MACRF=(PM)</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">MYRECORD DS    CL80</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">**EOF      DS    C**</span>  
We've added another `DCB`, this one for DD name `DDIN` that we're going to use for input. It's down one parameter, we've lost BLKSIZE=0, and we've gained a new parameter `DCBE` which is assigned the name of the next new line. Also, the `MACRF` parameter has changed to `GL`, meaning this `DCB` is for input because of the `G` and we're allowing the operating system to provide the memory for the records because of the `L`.   
We've also added a `DCBE`, which is another macro that defines another control block, just like `DCB`, this one is an extension on a `DCB`, hence `DCBE`. We're only using this extension to point `EODAD` to a tiny piece of code that is to be executed when the data set allocated to DD name `DDIN` has reached its end.  
Finally, we've added a new field `EOF` that's only one single character that will be set to 'Y' when we've reached the end of the input data set allocated to `DDIN`.

Now let's look at the code again:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (MYDATA,INPUT)    Open MYDATA DD for input</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         MVI   EOF,C'N'          Initialize EOF flag to 'N'</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">NEXT_REC EQU   \*                 Branch here to read the next input rec</span>  
<span style="font-family: monospace; white-space: pre">         LA    R7,EOF_CHK        Point R7 to instruction for EOF check</span>  
<span style="font-family: monospace; white-space: pre">         GET   MYDATA            Read a record from MYDATA</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">EOF_CHK  EQU   \*                 Branch here to check for end-of-file</span>  
<span style="font-family: monospace; white-space: pre">         CLI   EOF,C'Y'          Check for end-of-file</span>  
<span style="font-family: monospace; white-space: pre">         BE    CLOSE_ALL         If EOF, branch to close files</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         CLI   0(R1),C' '        Check if first pos is blank</span>  
<span style="font-family: monospace; white-space: pre">         BNE   SKIP_PUT          If non-blank, skip the PUT</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD,0(R1)    Move input record to MYRECORD</span>  
<span style="font-family: monospace; white-space: pre">         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT</span>  
<span style="font-family: monospace; white-space: pre">SKIP_PUT EQU   \*                 Branch here to skip writing a record</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         B     NEXT_REC          Read the next input record</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">CLOSE_ALL EQU   \*</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (MYDATA)          Close MYDATA DD</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (SYSOUT)          Close SYSOUT DD</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         L     R13,4(,R13)       Restore pointer to caller's SA</span>  
<span style="font-family: monospace; white-space: pre">         LM    R14,R12,12(R13)   Restore caller's registers</span>  
<span style="font-family: monospace; white-space: pre">         XR    R15,R15           Set return value to 0</span>  
<span style="font-family: monospace; white-space: pre">         BR    R14               Return to caller</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">EODAD    DS    0H</span>  
<span style="font-family: monospace; white-space: pre">         MVI   EOF,C'Y'          Set EOF flag to 'Y'</span>  
<span style="font-family: monospace; white-space: pre">         BR    R7                Continue where indicated</span>  

Now for the step by step explanation:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (MYDATA,INPUT)    Open MYDATA DD for input</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output</span>  
We're now opening 2 `DCB`s, one called `MYDATA` for input and still the one called `SYSOUT` for output like in the previous sample.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVI   EOF,C'N'          Initialize EOF flag to 'N'</span>  
Our single byte flag for end-of-file `EOF` is initialized to 'N' with a `MVI` (move immediate) instruction.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">NEXT_REC EQU   *                 Branch here to read the next input rec</span>  
This is the point in our code we're going to loop around to until we've reached end-of-file.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         LA    R7,EOF_CHK        Point R7 to instruction for EOF check</span>  
<span style="font-family: monospace; white-space: pre">         GET   MYDATA            Read a record from MYDATA</span>  
We're reading an input record with the `GET` macro passing our input `DCB` name, but not before setting R7 to the address of a tiny bit of code at the bottom of our sample that gets invoked if the `GET` runs into an end-of-file situation. This takes some getting used to as it is not like other languages deal with EOF. Basically you get to choose an address where processing is to continue when end-of-file is reached but you have to do the work yourself of actually getting back to the code that was executing before issuing the `GET`. We've done this in the sample by setting R7 to the address just beyond the `GET` and in the EODAD routine we simple `BR` (branch register) to R7 after setting the `EOF` field to 'Y'.  
Another way would have been to jump straight to `CLOSE_ALL`, which in this sample would have worked, but if this hadn't been sample code but an actual program there might be code you still wanted to execute for the previous record or to wrap things up before closing the `DCB`s.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">EOF_CHK  EQU   \*                 Branch here to check for end-of-file</span>  
<span style="font-family: monospace; white-space: pre">         CLI   EOF,C'Y'          Check for end-of-file</span>  
<span style="font-family: monospace; white-space: pre">         BE    CLOSE_ALL         If EOF, branch to close files</span>  
So this is where the `EODAD` routing branches to in case of end-of-file. And it's also where we end up after `GET` when it's not end-of-file yet. So in both cases we get to check the `EOF` field with a `CLI` (compare logical immediate) instruction to test if for value 'Y'. We branch if it's equal to 'Y' with `BE` (branch equal) which is an extended mnemonic that resolves to  
<span style="font-family: monospace; white-space: pre">         BC    8,CLOSE_ALL</span>  
because mask value 8 corresponds to condition code 0 which means 'operands equal'.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CLI   0(R1),C' '        Check if first pos is blank</span>  
<span style="font-family: monospace; white-space: pre">         BNE   SKIP_PUT          If non-blank, skip the PUT</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD,0(R1)    Move input record to MYRECORD</span>  
<span style="font-family: monospace; white-space: pre">         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT</span>  
<span style="font-family: monospace; white-space: pre">SKIP_PUT EQU   \*                 Branch here to skip writing a record</span>  
To do something that resembles something meaningful we're only writing input records to the output data set if column 1 of the input record is blank (skipping comment lines is the idea here).  
`CLI` (compare logical immediate) we've seen before, however this one specifies `0(R1)` instead of a data field name. That's because we're using `MACRF=(GL)` on the input `DCB` which means we're not providing memory for the input record. We're getting a pointer to a system managed record area pointed to by R1. And it's `0(R1)` and not `0(,R1)` because the `CLI` (compare logical immediate) instruction doesn't allow for an indexing register.  
`BNE` (branch not equal) we've also seen before, it jumps to the instruction just after the `PUT` in case column 1 of our input record is non-blank.  
The `MVC` (move) instruction is moving the input record from the system provided memory to our own record area. Although we've seen it a couple of times now, I want to point something out on, which is we haven't specified a length. We could have:  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD(80),0(R1)</span>  
or a little smarter:  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD(L'MYRECORD),0(R1)</span>  
but neither are needed because by default the Assembler will use the length of the definition of the data field. Since it's defined as `CL80` the `MVC` (move) instruction is generated with length 80.  
The line with `PUT` is unchanged from the writing to a data set sample.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         B     NEXT_REC          Read the next input record</span>  
We're unconditionally branching around to the part where we read the next input record because we will inevitably reach end-of-file, which means we will always end up branching past this line. Nevertheless you sometimes see failsafes built in, for example with `BCT` (branch on count) and a huge counter value to not end up in an endless loop in case we make a programming error.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">CLOSE_ALL EQU   \*</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (MYDATA)          Close MYDATA DD</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (SYSOUT)          Close SYSOUT DD</span>  
This speaks for itself, closing 2 `DCB`s now instead of 1.

The epiloc (the bit of code restoring the caller's registers and branching to R14) is unchanged and only shown to see the bit of code added below.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">EODAD    DS    0H</span>  
<span style="font-family: monospace; white-space: pre">         MVI   EOF,C'Y'          Set EOF flag to 'Y'</span>  
<span style="font-family: monospace; white-space: pre">         BR    R7                Continue where indicated</span>  
As already explained above, this bit of code is branched to by the operating system as part of the `GET` macro execution when the input file has reached end-of-file. Once more: the operating system doesn't branch back to where the `GET` was coded, if that's what your code requires, *you* have to do the work. In our case we fill R7 with the address of the next instruction after the `GET` macro so the `EODAD` routine can branch there after setting our `EOF` field to 'Y'.

[Prev](/chapter06/writetodataset.md)