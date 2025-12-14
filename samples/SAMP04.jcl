//         JOB 'SAMPLE ASM LKED GO',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*
//TMPPDSE EXEC PGM=IEFBR14
//TMPOBJ    DD DISP=(,PASS),DSN=&&TMPOBJ,
//             DCB=(DSORG=PO,RECFM=FB,LRECL=80),
//             UNIT=SYSALLDA,SPACE=(TRK,(10,10)),DSNTYPE=LIBRARY
//TMPLOD    DD DISP=(,PASS),DSN=&&TMPLOD,
//             DCB=(DSORG=PO,RECFM=U,LRECL=0,BLKSIZE=3120),
//             UNIT=SYSALLDA,SPACE=(TRK,(10,10)),DSNTYPE=LIBRARY
//*
//ASM     EXEC PGM=ASMA90,PARM='LIST(133)',COND=(0,NE)
//SYSLIB    DD DISP=SHR,DSN=SYS1.MACLIB
//SYSIN     DD *,DLM=@@
SAMP04   CSECT
         STM   R14,R12,12(R13)   Save caller's registers in our SA
         LR    R11,R15           Set up R11 for SAMP04
         USING SAMP04,R11          addressability
         ST    R13,SAVEAREA+4    Back chain the caller's SA
         LR    R2,R13            Save pointer to caller's SA
         LA    R13,SAVEAREA      Address our own SA
         ST    R13,8(,R2)        Forward chain our SA in caller's SA
*
         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output
*
         MVI   MYRECORD,C' '     Initialize MYRECORD with spaces
         MVC   MYRECORD+1(L'MYRECORD-1),MYRECORD
         MVC   MYRECORD(17),=C'SAMP04 SAYS HELLO'
*
         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT
*
         CLOSE (SYSOUT)          Close SYSOUT DD
*
         L     R13,4(,R13)       Restore pointer to caller's SA
         LM    R14,R12,12(R13)   Restore caller's registers
         XR    R15,R15           Set return value to 0
         BR    R14               Return to caller
*
SAVEAREA DS    18F
*
SYSOUT   DCB   DDNAME=SYSOUT,RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS,     X
               MACRF=(PM)
*
MYRECORD DS    CL80
*
R0       EQU   0 
R1       EQU   1 
R2       EQU   2 
R3       EQU   3 
R4       EQU   4 
R5       EQU   5 
R6       EQU   6 
R7       EQU   7 
R8       EQU   8 
R9       EQU   9 
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
         END
@@
//SYSLIN    DD DISP=(SHR,PASS),DSN=&&TMPOBJ(SAMP04)
//SYSUT1    DD SPACE=(4096,(120,120),,,ROUND),UNIT=SYSALLDA
//SYSPRINT  DD SYSOUT=*
//*
//LKED    EXEC PGM=IEWL,COND=(0,NE),PARM='LIST,XREF'
//SYSLIB    DD DISP=(SHR,PASS),DSN=&&TMPOBJ
//SYSLIN    DD *
  MODE AMODE(31),RMODE(24)
  INCLUDE SYSLIB(SAMP04)
  NAME SAMP04(R)
/*
//SYSLMOD   DD DISP=(SHR,PASS),DSN=&&TMPLOD(SAMP04)
//SYSUT1    DD UNIT=SYSDA,DCB=BLKSIZE=1024,SPACE=(1024,(200,20))
//SYSPRINT  DD SYSOUT=*
//*
//RUN     EXEC PGM=SAMP04,COND=(0,NE)
//STEPLIB   DD DISP=SHR,DSN=&&TMPLOD
//SYSOUT    DD SYSOUT=*,DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)