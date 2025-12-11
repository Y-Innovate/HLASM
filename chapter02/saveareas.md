# Save areas #

Any memory your code wants to write to should normally be memory it allocates first. If programs could just write anywhere in the system's memory then with many programs running in parallel many processes would fail because other programs are messing up their memory. For the system to keep track of which program 'owns' what area of memory every program needs to first allocate that memory.  

An Assembler program that starts executing doesn't have any memory allocated so it can't write anywhere safely, with one exception. The programming convention on z/OS is that a calling program provides a small bit of memory to the called program where that called program can store the contents of the general purpose registers. The 2nd part of that programming convention is that the called program, upon returning to the calling program, restores the contents of most general purpose registers.  
Such a memory area for saving register contents is called a `save area`.  

Why is it important to save the caller program's registers? Two reasons:  
1. The calling program, after getting control back when the called program finishes, will want to continue where it left off and the contents of at least some of the registers will have meaning only to the calling program.
2. The called program, assuming the calling program follows the common programming conventions, is provided information in several registers. Registers it might want to use in its own code and if it needs the values passed from the calling program after those registers it can retrieve those values from the save area.

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

[Prev](/chapter01/addressability.md) | [Next](/chapter02/registerconventions.md)