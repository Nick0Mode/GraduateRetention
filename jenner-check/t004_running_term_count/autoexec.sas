/* cap input rows for the captured run */
options obs=100;
/* name literals with spaces require validvarname=any */
options validvarname=any;

/* mock the intermediate `timeline7` dataset that Section VIII Part B consumes,
   already sorted by studentID term as the upstream step guarantees.
   Includes the `date` column (a SAS date, date9. formatted) that the upstream
   pipeline carries and this DATA step keeps. */
data timeline7;
  length studentID 8 term 8 event $12 flag 3 date 8 'subj code'n $4 'crse numb'n $4 'final grade'n $2;
  format date date9.;
  infile datalines dsd truncover;
  input studentID term event $ flag date : date9. 'subj code'n $ 'crse numb'n $ 'final grade'n $;
  datalines;
1001,202010,Applied,.,01AUG2019,,,
1001,202020,Continuing,1,01MAY2020,STAT,5100,A
1001,202110,Graduated,1,15DEC2020,,,
1002,202110,Applied,.,01AUG2020,,,
1002,202120,Continuing,.,01MAY2021,MATH,3000,B
1003,202210,Applied,.,01AUG2021,,,
1003,202210,Admitted,.,01AUG2021,,,
1003,202220,Exited,.,01MAY2022,,,
;
run;
