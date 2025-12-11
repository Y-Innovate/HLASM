# Programming and register conventions #

Now that we know some basics it's time to talk about programming conventions for HLASM on z/OS.  

These are the most common register purposes:
* R1 = pointer to parameter(s) passed from calling program
* R13 = pointer to calling program's save area
* R14 = return address to where calling program's code should continue after the call
* R15 = address of the start of this program's code

With this register purpose convention in mind let's look at a small piece of Assembler code:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace">SAMP01&nbsp;&nbsp;&nbsp;CSECT  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;STM&nbsp;&nbsp;&nbsp;R14,R12,12(R13)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R11,R15  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;USING&nbsp;SAMP01,R11  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R13,SAVEAREA+4  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LR&nbsp;&nbsp;&nbsp;&nbsp;R2,R13  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LA&nbsp;&nbsp;&nbsp;&nbsp;R13,SAVEAREA  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ST&nbsp;&nbsp;&nbsp;&nbsp;R13,8(,R2)  
*  
\* Lines of code  
*  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R13,4(,R13)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LM&nbsp;&nbsp;&nbsp;&nbsp;R14,R12,12(R13)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;XR&nbsp;&nbsp;&nbsp;&nbsp;R15,R15  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BR&nbsp;&nbsp;&nbsp;&nbsp;R14  
*  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;END</span>  

Let's look at that line by line.  

<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+</span>  
<span style="font-family: monospace">SAMP01&nbsp;&nbsp;&nbsp;CSECT</span>  
This tells the Assembler that the lines that follow it are lines of code (as opposed to for example a DSECT to define the layout of a memory area).