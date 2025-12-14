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
SAMP03   CSECT
         STM   R14,R12,12(R13)   Save caller's registers in our SA
         LR    R11,R15           Set up R11 for SAMP03
         USING SAMP03,R11          addressability
         GETMAIN RU,LV=DSASIZ    Allocate memory for our DSA
         ST    R13,4(,R1)        Back chain the caller's SA
         LR    R2,R13            Save pointer to caller's SA
         LR    R13,R1            Address our own SA
         USING DSA,R13           DSA addressability
         ST    R13,8(,R2)        Forward chain our SA in caller's SA
*
         MVC   MYWTO+2(14),=C'COUNTING DOWN '  Prepare WTO text
         MVC   MYWTO(2),=H'15'   Prepare WTO text length
         LA    R2,10             Use R2 as counter for 10 iterations
NEXT_WTO EQU   *                 Every loop around starts back here
         CVD   R2,PACKED         Convert binary to packed decimal
         UNPK  ZONED,PACKED      Convert packed decimal to zoned
         OI    ZONED+7,X'F0'     Ignore sign nibble
         MVC   MYWTO+16(1),ZONED+7  Copy 1 last digit
         WTO   TEXT=MYWTO,ROUTCDE=11,DESC=7
         BCT   R2,NEXT_WTO       Decrease R2 by 1 and jump if not 0
*
         L     R13,4(,R13)       Restore pointer to caller's SA
         DROP  DSA               Forget DSA addressability
         FREEMAIN RU,LV=DSASIZ,A=8(,R13)  Free allocated memory
         LM    R14,R12,12(R13)   Restore caller's registers
         XR    R15,R15           Set return value to 0
         BR    R14               Return to caller
*
DSA      DSECT                   My dynamic storage area
*
SAVEAREA DS    18F               My save area
*
MYWTO    DS    H,CL20            WTO up to 20 characters
*
PACKED   DS    PL8               Packed decimal 8 bytes
ZONED    DS    ZL8               Zoned decimal 8 bytes
*
DSASIZ   EQU   *-DSA             Calculated size of DSA
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
//SYSLIN    DD DISP=(SHR,PASS),DSN=&&TMPOBJ(SAMP03)
//SYSUT1    DD SPACE=(4096,(120,120),,,ROUND),UNIT=SYSALLDA
//SYSPRINT  DD SYSOUT=*
//*
//LKED    EXEC PGM=IEWL,COND=(0,NE),PARM='LIST,XREF'
//SYSLIB    DD DISP=(SHR,PASS),DSN=&&TMPOBJ
//SYSLIN    DD *
  INCLUDE SYSLIB(SAMP03)
  NAME SAMP03(R)
/*
//SYSLMOD   DD DISP=(SHR,PASS),DSN=&&TMPLOD(SAMP03)
//SYSUT1    DD UNIT=SYSDA,DCB=BLKSIZE=1024,SPACE=(1024,(200,20))
//SYSPRINT  DD SYSOUT=*
//*
//RUN     EXEC PGM=SAMP03,COND=(0,NE)
//STEPLIB   DD DISP=SHR,DSN=&&TMPLOD