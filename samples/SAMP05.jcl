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
SAMP05   CSECT
         STM   R14,R12,12(R13)   Save caller's registers in our SA
         LR    R11,R15           Set up R11 for SAMP05
         USING SAMP05,R11          addressability
         ST    R13,SAVEAREA+4    Back chain the caller's SA
         LR    R2,R13            Save pointer to caller's SA
         LA    R13,SAVEAREA      Address our own SA
         ST    R13,8(,R2)        Forward chain our SA in caller's SA
*
         OPEN  (MYDATA,INPUT)    Open MYDATA DD for input
         OPEN  (SYSOUT,OUTPUT)   Open SYSOUT DD for output
*
         MVI   EOF,C'N'          Initialize EOF flag to 'N'
*
NEXT_REC EQU   *                 Branch here to read the next input rec
         LA    R7,EOF_CHK        Point R7 to instruction for EOF check
         GET   MYDATA            Read a record from MYDATA
*
EOF_CHK  EQU   *                 Branch here to check for end-of-file
         CLI   EOF,C'Y'          Check for end-of-file
         BE    CLOSE_ALL         If EOF, branch to close files
*
         CLI   0(R1),C' '        Check if first pos is blank
         BNE   SKIP_PUT          If non-blank, skip the PUT
         MVC   MYRECORD,0(R1)    Move input record to MYRECORD
         PUT   SYSOUT,MYRECORD   Write MYRECORD to SYSOUT
SKIP_PUT EQU   *                 Branch here to skip writing a record
*
         B     NEXT_REC          Read the next input record
*
CLOSE_ALL EQU   *
         CLOSE (MYDATA)          Close MYDATA DD
         CLOSE (SYSOUT)          Close SYSOUT DD
*
         L     R13,4(,R13)       Restore pointer to caller's SA
         LM    R14,R12,12(R13)   Restore caller's registers
         XR    R15,R15           Set return value to 0
         BR    R14               Return to caller
*
EODAD    DS    0H
         MVI   EOF,C'Y'          Set EOF flag to 'Y'
         BR    R7                Continue where indicated
*
SAVEAREA DS    18F
*
MYDATA   DCB   DDNAME=DDIN,RECFM=FB,LRECL=80,DSORG=PS,MACRF=(GL),      X
               DCBE=MYDATAE
MYDATAE  DCBE  EODAD=EODAD
SYSOUT   DCB   DDNAME=SYSOUT,RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS,     X
               MACRF=(PM)
*
MYRECORD DS    CL80
*
EOF      DS    C
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
//SYSLIN    DD DISP=(SHR,PASS),DSN=&&TMPOBJ(SAMP05)
//SYSUT1    DD SPACE=(4096,(120,120),,,ROUND),UNIT=SYSALLDA
//SYSPRINT  DD SYSOUT=*
//*
//LKED    EXEC PGM=IEWL,COND=(0,NE),PARM='LIST,XREF'
//SYSLIB    DD DISP=(SHR,PASS),DSN=&&TMPOBJ
//SYSLIN    DD *
  MODE AMODE(31),RMODE(24)
  INCLUDE SYSLIB(SAMP05)
  NAME SAMP05(R)
/*
//SYSLMOD   DD DISP=(SHR,PASS),DSN=&&TMPLOD(SAMP05)
//SYSUT1    DD UNIT=SYSDA,DCB=BLKSIZE=1024,SPACE=(1024,(200,20))
//SYSPRINT  DD SYSOUT=*
//*
//RUN     EXEC PGM=SAMP05,COND=(0,NE)
//STEPLIB   DD DISP=SHR,DSN=&&TMPLOD
//DDIN      DD *
*Comment
 Actual data
*More comment
 More actual data
//SYSOUT    DD SYSOUT=*,DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)