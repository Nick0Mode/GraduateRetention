/* cap input rows for the captured run */
options obs=100;
/* name literals with spaces require validvarname=any */
options validvarname=any;

/* mock gradsch library standing in for the Dean's-office data the script reads.
   column shapes/types match what Section I Part A of FinalTimelineSAS.sas consumes. */
libname gradsch (work);

data gradsch.enrollments;
  length studentID 8 term 8 admitTerm 8 gender $1 military 3
         COLLEGE $12 'CURRENT TIME STATUS'n $2 'RESIDENCY CODE'n $1
         'MULTI RACE IND'n $1 'RACE VAL1 DESC'n $12 'RACE VAL2 DESC'n $12
         'RACE VAL3 DESC'n $12 'RACE VAL4 DESC'n $12 '\RACE VAL5 DESC'n $12
         'attrib ind oap'n $1 'STU TYPE'n $1 'SESSION CODE'n $2
         'race ans code'n $2 'race ans desc'n $12 'graduated ind'n $1;
  infile datalines dsd truncover;
  input studentID term admitTerm gender $ military
        COLLEGE $ 'CURRENT TIME STATUS'n $ 'RESIDENCY CODE'n $
        'MULTI RACE IND'n $ 'RACE VAL1 DESC'n $ 'RACE VAL2 DESC'n $
        'RACE VAL3 DESC'n $ 'RACE VAL4 DESC'n $ '\RACE VAL5 DESC'n $
        'attrib ind oap'n $ 'STU TYPE'n $;
  datalines;
1001,202010,202010,F,.,Xerox College,FT,R,N,,,,,White,Y,C
1002,202010,202010,M,1,Engineering,PT,N,Y,,,,,,N,C
1003,202110,202010,F,.,xArts,FT,R,N,Native,,,,,N,C
1004,202120,202110,M,.,Business,PT,R,N,,Asian,,,,Y,C
1005,202210,202210,F,.,Xtended Studies,FT,N,N,,,Black,,,,N,C
1006,202220,202210,M,1,Nursing,PT,R,N,,,,Pacific,,N,C
1007,202310,202310,F,.,Education,FT,R,N,,,,,White,Y,C
;
run;
