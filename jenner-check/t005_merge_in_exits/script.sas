/* Section VII Part B of FinalTimelineSAS.sas: flag students who enrolled but
   never graduated as 'Exited', via a MERGE with in= dataset flags.
   Small mock SortEnroll / graduations are inlined here so this file runs
   stand-alone (e.g. against /v1/quick); the merge logic is verbatim. */

data SortEnroll;
  input studentID term;
  datalines;
1001 202010
1002 202110
1003 202210
1004 202120
1005 202310
;
run;

data graduations;
  input studentID term;
  datalines;
1001 202110
1003 202220
;
run;

/*VII. Part B*/
/*Merges SortEnroll and graduations data. Applies 'Exited' to event.*/
data exits (keep=studentID event);
	merge SortEnroll (in=InSEnr)
		graduations (in=InGrad);
	 	by studentID;
	length exit $ 10.;
	event = 'Exited';
	if InSEnr and not InGrad then output;
run;

/* observe which students were flagged Exited (in SortEnroll, not in graduations) */
proc print data=exits; run;
