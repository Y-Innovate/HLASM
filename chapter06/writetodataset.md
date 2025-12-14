# Writing to a data set #

Despite having explained how taking too much 24-bit storage is discouraged we're going to do it the 'wrong' way first.

Have a look at [SAMP04.jcl](/samples/SAMP04.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit this sample.

This sample looks a lot like SAMP01.jcl because we're back to doing no GETMAINs or FREEMAINs to keep it simple.

There's also no error handling yet, but we'll fix that later.

Let's first look at these lines at the bottom:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">SYSOUT   DCB   DDNAME=SYSOUT,RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS,     X</span>  
<span style="font-family: monospace; white-space: pre">               MACRF=(PM)</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">MYRECORD DS    CL80</span>  
The first line invokes the `DCB` macro for building a Data Control Block. This takes a lot of parameters (and there are a lot more than I've coded here) so we're forced to continue it on a second line by putting a non-blank in column 72 and continuing on the next line in column 16.  
If you're familiar with JCL all of the parameters I think are self-explanatory except for the `MACRF` parameter. We use this parameter to tell the operating system we want to read or write to the data set by specifying either `P` for PUT or `G` for GET. We also use it to tell the operating system whether we will provide the memory for a record to be read or written or if the operating should provide that by specifying either `M` for move mode or `L` for locate mode.  
In our sample we're telling it `PM` so we're intending to write output to it and we're providing the memory for a record to be written.  
The last line is that memory for a record of 80 characters.

Now let's examine these lines of code:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         MVI   MYRECORD,C' '     Initialize MYRECORD with spaces</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD+1(L'MYRECORD-1),MYRECORD</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD(17),=C'SAMP04 SAYS HELLO'</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT</span>  
<span style="font-family: monospace; white-space: pre">\*</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (SYSOUT)          Close SYSOUT DD</span>  

Let's chop that up again.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output</span>  
We're using the `OPEN` macro to have the operating system access the data set that is attached to the `SYSOUT` DD name, which in our sample JCL is a SYSOUT data set, and we're telling it we want to start writing records to it with the `OUTPUT` parameter.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         MVI   MYRECORD,C' '     Initialize MYRECORD with spaces</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD+1(L'MYRECORD-1),MYRECORD</span>  
<span style="font-family: monospace; white-space: pre">         MVC   MYRECORD(17),=C'SAMP04 SAYS HELLO'</span>  
The first 2 lines are a little trick to initialize a character field to spaces without having to use a literal of 80 spaces to copy from. The trick is to use the `MVI` (move immediate) instruction to set the first byte of a character field to one space. Then the next `MVC` (move) instruction copies MYRECORD to MYRECORD+1, which is an overlapping move (meaning source and target memory overlap) and while that's normally a bad idea, in this case it's exactly what we want. The result is it repeatedly copies a space to the next byte, so byte 1 (which we set to a space with the previous instruction) is copied to byte 2, now also a space. Then byte 2 is copied to byte 3, now also a space, and so on.  
Note that we've specified the length of the area to be moved as `L'MYRECORD-1`. That `L'` is an Assembler language syntax that means 'the length of'. So because we've defined MYRECORD as a CL80 field, `L'MYRECORD-1` resolves to 79. And since we're copying to MYRECORD+1 that ensures we don't copy beyond the end of MYRECORD.

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT</span>  
We write a single record to the SYSOUT DD name with the `PUT` macro, which takes a DCB name (SYSOUT in our case) and an address of the data to write (MYRECORD in our case).

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CLOSE (SYSOUT)          Close SYSOUT DD</span>  
When we're done writing to our data set we should close it with another macro call `CLOSE` which just takes the DCB name as a parameter.

Finally, have a look at the link-edit step in the sample JCL and note the extra line we provide as input to the binder:  
<span style="font-family: monospace; white-space: pre">  MODE AMODE(31),RMODE(24)</span>  
This tells the binder to mark the load module as 31-bit addressing and to load it in 24-bit storage (so far that has been the default anyway, but after this point we're going to work towards always having `RMODE(ANY)`).