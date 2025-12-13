# Defining data #

Further along in this training I'll show you how to neatly separate your code from your working storage allowing your load modules to be loaded into read-only memory for example. But for now we're going to add variables after our code, basically making your load module a bit bigger, not with code but with data, and the Assembler is perfectly okay with that.

You define data fields with either the define storage `DS` or the define constant `DC` statements. The difference is that `DS` only reserves the memory space whereas `DC` gives that memory an initial value too.  
For example to define a string of 8 characters you could:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">VARNAME1&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;C'AABBCCDD'&nbsp;&nbsp;Initialized string of 8 characters</span>  

You can add a length value to specify the size of the variable, so for example for an uninitialized string of 16 characters you could:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">VARNAME2&nbsp;DS&nbsp;&nbsp;&nbsp;&nbsp;CL16&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Uninitialized string of 16 characters</span>  

You can also add a multiplication in front of the data type to reserve space for n times that data type and in fact we've seen this when we defined the variable SAVEAREA in our sample program that reserves space for 18 fullwords:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">SAVEAREA&nbsp;DS&nbsp;&nbsp;&nbsp;&nbsp;18F&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This program's save area</span>  

Examples of initialized data types are:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;C'A'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Single character with the letter A  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;X'C1'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Single hex character, also letter A  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;H'12345'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Halfword which is 2 bytes  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;F'12345678'&nbsp;&nbsp;Fullword which is 4 bytes  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;FD'0'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Doubleword which is 8 bytes  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;B'01101001'&nbsp;&nbsp;A byte with a binary value  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;P'99887'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A packed decimal of in this case 3 bytes  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;Z'-23'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A zoned decimal of in this case 2 bytes  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DC&nbsp;&nbsp;&nbsp;&nbsp;A(16)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The 4 bytes address of 16</span>  

Assembled that looks like this in the listing:  
```
00000000 C1                                    3          DC    C'A'         Single character with the letter A
00000001 C1                                    4          DC    X'C1'        Single hex character, also letter A
00000002 3039                                  5          DC    H'12345'     Halfword which is 2 bytes
00000004 00BC614E                              6          DC    F'12345678'  Fullword which is 4 bytes
00000008 0000000000000000                      7          DC    FD'0'        Doubleword which is 8 bytes
00000010 69                                    8          DC    B'01101001'  A byte with a binary value
00000011 99887C                                9          DC    P'99887'     A packed decimal of in this case 3 bytes
00000014 F2D3                                 10          DC    Z'-23'       A zoned decimal of in this case 2 bytes
00000016 0000
00000018 00000010                             11          DC    A(16)        The 4 bytes address of 16
```

Notice the little extra blank space before the address constant which is the result of defining `A` type constants on a fullword boundary (a memory address divisible by 4).

[Prev](/chapter03/firstassembly.md) | [Next](/chapter04/workingwithdata.md)