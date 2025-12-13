# Save areas #

Any memory your code wants to write to should normally be memory it allocates first. If programs could just write anywhere in the system's memory then with many programs running in parallel many processes would fail because other programs are messing up their memory. For the system to keep track of which program 'owns' what area of memory every program needs to first allocate that memory.  

An Assembler program that starts executing doesn't have any memory allocated so it can't write anywhere safely, with one exception. The programming convention on z/OS is that a calling program provides a small bit of memory to the called program where that called program can store the contents of the general purpose registers. The 2nd part of that programming convention is that the called program, upon returning to the calling program, restores the contents of most general purpose registers.  
Such a memory area for saving register contents is called a `save area`.  

Why is it important to save the caller program's registers? Two reasons:  
1. The calling program, after getting control back when the called program finishes, will want to continue where it left off and the contents of at least some of the registers will have meaning only to the calling program.
2. The called program, assuming the calling program follows the common programming conventions, is provided certain information in several registers. Registers it might want to use in its own code and if it needs the values passed from the calling program after those registers were used and overwritten it can retrieve those values from the save area.

A default save area for a 24-bit or 31-bit program (more on that later) is 18 fullwords, so 18 x 4 bytes, with this layout:  
<table>
  <tr><th>Offset</th><th>Content</th></tr>
  <tr><td>00</td><td>Reserved</td></tr>
  <tr><td>04</td><td>Back chain to caller's save area</td></tr>
  <tr><td>08</td><td>Forward chain to next save area</td></tr>
  <tr><td>12</td><td>Save R14</td></tr>
  <tr><td>16</td><td>Save R15</td></tr>
  <tr><td>20</td><td>Save R0</td></tr>
  <tr><td>24</td><td>Save R1</td></tr>
  <tr><td>28</td><td>Save R2</td></tr>
  <tr><td>32</td><td>Save R3</td></tr>
  <tr><td>36</td><td>Save R4</td></tr>
  <tr><td>40</td><td>Save R5</td></tr>
  <tr><td>44</td><td>Save R6</td></tr>
  <tr><td>48</td><td>Save R7</td></tr>
  <tr><td>52</td><td>Save R8</td></tr>
  <tr><td>56</td><td>Save R9</td></tr>
  <tr><td>60</td><td>Save R10</td></tr>
  <tr><td>64</td><td>Save R11</td></tr>
  <tr><td>68</td><td>Save R12</td></tr>
</table>

```
/-----------\           /-----------\
| Calling   |           | Called    |
|   program |---------->|   program |
|     code  |           |     code  |
+-----------+           \-----------/
| Calling   |                 |
|   progam  |<----------------/
| save area |       First task of called program =
\-----------/       save calling program's registers
```

```
/-----------\           /-----------\
| Calling   |           | Called    |
|   program |           |   program |--\
|     code  |           |     code  |  |
+-----------+           +-----------+  |
| Calling   |           | Called    |  |  Second task of called program =
|   progam  |           |   program |<-/  allocate memory of its own, at
| save area |           | save area |     least enough to have its regs saved
\-----------/           \-----------/     if it decides to call another program
```

```
/-----------\           /-----------\
| Calling   |           | Called    |
|   program |     /-----|   program |
|     code  |     |     |     code  |
+-----------+     |     +-----------+  Third task of called program =
| Calling   |     V     | Called    |  chain the save areas by having the
|   progam  |<----------|   program |  caller's save area point to its own
| save area |---------->| save area |  and have its own save area point to
\-----------/           \-----------/  its caller's.
```

The actual sequence of these tasks is slightly different for logical reasons you'll see in the next page.

[Prev](/chapter01/addressability.md) | [Next](/chapter02/registerconventions.md)