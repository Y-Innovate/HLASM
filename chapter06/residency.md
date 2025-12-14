# AMODE and RMODE #

Back in the day when z/OS was called MVS it started out as a 24-bit operating system. Nowadays it's hard to imagine you could get anything done with just 16 MiB, but there are still traces of that 24-bit ceiling in z/OS to this day (more on that later). The 24-bit ceiling is named `the line`, so if you ever hear mention of something `below the line` it means somewhere in the lower 16 MiB of memory.  
The first memory ceiling upgrade took us to a 31-bit operating system. Hang on, 31? Shouldn't that be 32? Yes and no. The registers became 32-bit registers, but to be downward compatible to all of the 24-bit code (which at that time was most of it), the high-order bit was sacrificed to become an addressing mode indicator. This meant that maximum amount of addressible storage because 2 GiB instead of 4 GiB, but who could ever need more than 2 GiB, right? The 31-bit ceiling is name `the bar`, so if you ever hear mention of something `below the bar` it means somewhere in the lower 2 GiB of memory.  
The second memory ceiling upgrade took us to a 64-bit operating system, which allows for a maximum amount of addressible storage of 16 EiB (that's roughly 10 to the 18th). Who could ever need more than 16 EiB, right? I've heard the 64-bit ceiling be called `the beam` but I don't know if that really caught on.  

The JCL's we've ran so far haven't specified anything but in the linkage editor step you can tell the binder what attributes your load modules is to be marked with. Two common attributes area `AMODE` and `RMODE`.

`AMODE` assigns an addressing mode to your load module. This can be `24`-, `31`- or `64`-bit addressing mode or `ANY` which means it can operate safely in either 24- or 31-bit addressing mode.

`RMODE` assigns a so-called residency mode to your load module. The residency mode of your load module determines *where* in memory your code can be loaded regardless of its addressing mode. This can be `24`-bit or `ANY`.

The most common combination nowadays is `AMODE(31)` with `RMODE(ANY)`, but you'll also still see a lot of `AMODE(31)` with `RMODE(24)`.  
The reason for that is the fact that certain types of control blocks still need to reside in 24-bit storage, most notably `DCB`'s or Data Control Blocks which are needed to open and read/write data sets. Therefor it's quite common to see 31-bit addressing mode modules to be required to be loaded into the lower 16 MiB of storage for the simple reason that a `DCB` is coded as part of the load module just like we defined our working storage fields without a DSECT in the beginning.

As you can imagine nowadays on a heavily used system it can get a bit crowded still having to load lots of load modules in the 24-bit addressible storage. Similarly there are lots of 31-bit applications nowadays that require large amounts of storage, so it can also get crowded in the 31-bit addressible storage.  
IBM with every z/OS release put effort in so called virtual storage constraint relief, meaning they change their code to eliminate or at least minimize the required storage below the line or the bar.

By the end of this training you'll at least know how to minimize your need for 24-bit storage.

[Prev](/chapter05/iteration.md) | [Next](/chapter06/writetodataset.md)