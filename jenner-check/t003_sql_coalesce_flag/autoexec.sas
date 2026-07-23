/* cap input rows for the captured run */
options obs=100;

/* mock the intermediate `timeline8` dataset that Section IX Part A consumes.
   Only the columns the PROC SQL reads are populated: studentID, flag.
   flag is 1 on the row where a student was flagged (admitted <= 2021), missing otherwise.
   The query propagates each student's non-missing flag across all their rows via coalesce. */
data timeline8;
  input studentID flag;
  datalines;
1001 1
1001 .
1001 .
1002 .
1002 .
1003 1
1004 .
1005 .
1005 1
;
run;
