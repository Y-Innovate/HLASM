# Condition codes revisited #

Let's look at that branch instruction again in the little code snippet:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         CR    R5,R6      Compare registers 5 and 6</span>  
<span style="font-family: monospace; white-space: pre">         BC    12,SKIPTO  Branch to SKIPTO if R5 is less or equal to R6</span>  
<span style="font-family: monospace; white-space: pre">         LR    R5,R6      Put value of R6 in R5</span>  
<span style="font-family: monospace; white-space: pre">SKIPTO   ST    R5,0(,R1)  Store value of R5 where R1 points to</span>

We now understand how `SKIPTO` is resolved to an offset to R11, but I am yet to explain that `12`.

Remember how the PSW has 2 bits reserved for the condition code and how that allows for 4 different values of the condition code? Well the branching instructions allow a mask of 4 bits where each bit corresponds to one of the possible values of the condition code. That way you can use a single branch instruction to jump somewhere if the condition code has value 0 *or* 1 *or* 2 *or* 3 or any combination that makes sense.

So to reiterate, the possible condition code values are:  
<table>
  <tr><th>bits</th><th>decimal</th></tr>
  <tr><td>00</td><td>0</td></tr>
  <tr><td>01</td><td>1</td></tr>
  <tr><td>10</td><td>2</td></tr>
  <tr><td>11</td><td>3</td></tr>
</table>  

And for the `CR` (compare registers) instruction those condition codes mean:
<table>
  <tr><th>bits</th><th>decimal</th><th>meaning</th></tr>
  <tr><td>00</td><td>0</td><td>Operands are equal</td></tr>
  <tr><td>01</td><td>1</td><td>First operand low</td></tr>
  <tr><td>10</td><td>2</td><td>First operand high</td></tr>
  <tr><td>11</td><td>3</td><td></td></tr>
</table>  

The way the 4 condition codes are mapped to the mask in the `BC` (branch on condition) instruction is:
<table>
  <tr><td>Condition Code</td><td>0</td><td>1</td><td>2</td><td>3</td></tr>
  <tr><td>Mask position value</td><td>8</td><td>4</td><td>2</td><td>1</td></tr>
</table>

So thereby a mask of `b'1100'` on a `BC` (branch on condition) after a `CR` (compare register) instruction means "branch if the condition code is either 0=Operands are equal or 1=First operand low". Adding the mask position values in the mask gets us:  
<table>
  <tr><td>Condition Code</td><td>0</td><td>1</td><td>2</td><td>3</td></tr>
  <tr><td>Mask</td><td>1</td><td>1</td><td>0</td><td>0</td></tr>
  <tr><td>Mask position value</td><td>8</td><td>4</td><td></td><td></td></tr>
</table>

Add those 2 mask position values together and you get the 12 we coded on our `BC` (branch on condition) instruction:  
<span style="font-family: monospace; color: gray">----+----1----+----2----+----3----+----4----+----5----+----6----+----7--</span>  
<span style="font-family: monospace; white-space: pre">         BC    12,SKIPTO  Branch to SKIPTO if R5 is less or equal to R6</span>  

[Prev](/chapter02/using.md) | [Next](/chapter03/firstassembly.md)