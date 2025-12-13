# Assemble your first program #

Have a look at [SAMP01.jcl](/chapter03/SAMP01.jcl), customize it where needed to your own environment and submit it to Assemble and link-edit your first program.

This sample job has everything instream and should normally result in CC=0000 and write 1 line into the z/OS log.

Just like with COBOL or PL/1 the process of creating a load module is a 2 step process. Step one is to create an object module from your source code. Step two is to combine your object module with potentially other bits and pieces to form a load module that can be executed.

Up until now the sample code did not contain a line that invokes the WTO macro. It was inserted here not to explain WTO, but to have a tangible result of executing your load module.

[Prev](/chapter02/conditioncodesrevisited.md) | [Next](/chapter04/definingdata.md)