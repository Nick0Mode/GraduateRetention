/*Section I.*/
/*Part A*/
/*Cleaning step for gradsch.enrollments */
data enrollments(drop=gender "MULTI RACE IND"n "\RACE VAL5 DESC"n "RACE VAL1 DESC"n "RACE VAL2 DESC"n "RACE VAL3 DESC"n "RACE VAL4 DESC"n
						'SESSION CODE'n 'race ans code'n 'race ans desc'n 'attrib ind oap'n 'graduated ind'n);

	set gradsch.enrollments(
						    rename=('CURRENT TIME STATUS'n=time_status
						    'RESIDENCY CODE'n=NC_resident)
						);
 
length distance_education 3 race $10 male 3;
 
 /*The following if blocks convert the specified binary column to a numeric representation*/ 
if 'attrib ind oap'n = 'Y' then OAP = 1;
else OAP = 0;
 
if NC_resident='N' then NC_resident=0;
	else if NC_resident='R' then NC_resident=1;
 
if first(lowcase(COLLEGE)) = 'x' then distance_education = 1;
	else distance_education = 0;
 
if missing(military) then military=0;
	else if military then military=1;
if gender='F' then male=0;
	else if gender='M' then male=1;
	
/*The following if block condenses race attributes into a single column*/	
if 'MULTI RACE IND'n = 'Y' then race='Multiracial';
	else if not missing("RACE VAL1 DESC"n) then race='Native';
	else if not missing("RACE VAL2 DESC"n) then race='Asian';
	else if not missing("RACE VAL3 DESC"n) then race='Black';
	else if not missing("RACE VAL4 DESC"n) then race='Pacific';
	else if not missing("\RACE VAL5 DESC"n) then race='White';
run;

/*I. Part B*/
/*Cleaning step for gradsch.admissions*/
data admissions;
	set gradsch.admissions;
	*where 'last decision code'n eq 'IE';
	keep studentID term 'appl date'n 'last decision code'n 'appl admit type'n degree 'school gpa'n 
		'institution desc'n;
run;

/*I. Part C*/
/*Cleaning step for gradsch.graduations*/
data graduations (drop = 'Attempted Classes Ind'n 'Degree Status Code'n 'Grad Status Code'n 'Grad Term Code'n);
	set gradsch.graduations;
	date1 = datepart('grad date'n);
	*format date1 dtdate9.;
run;

/*I. Part C.1*/
proc sort data=graduations;
	by studentID term;
run;

/*I. Part D*/
/*Cleaning step for gradsch.grades*/
data grades;
	set gradsch.grades;
	keep studentID degree term CRN 'SUBJ CODE'n 'CRSE NUMB'n 'FINAL GRADE'n;
run;

/*I. Part D.1*/
proc sort data=grades;
	by studentID term;
run;

/*I. Part D.2*/
proc sort data=admissions out=SortAd nodupkey;
	by studentID term;
run;


/*Section II.*/
/*Part A*/
/*Uses sorted admissions data; creates an event column, assigns 'Applied' */
data timeline;
	set SortAd;
	length event $50.;
	date = datepart('appl date'n);
	format date date9.;
	event = 'Applied';
	keep studentID term date event;
run;

/*II. Part B*/
proc sort data=enrollments out=SortEnroll nodupkey;
	by studentID admitTerm;
run;

/*II. Part C*/
proc sort data=SortEnroll;
	by studentID term;
run;


/*Section III.*/
/*Part A*/
/*Combines SortEnroll data with timeline data ('Applied' event); 
  assigns added rows from SortEnrollM with 'Admitted' event*/
data timeline1;
	set timeline
		SortEnroll;
	by studentID term;
	if missing(event) then event = 'Admitted';
	if event eq 'Admitted' then do;
		season = mod(admitTerm, 100);
		year = input(substr(admitTerm, 5,6), best12.);
		if season eq 10 then year=year-1;
		select(season);
		when(10) month = 8;
		otherwise month = 1;
		end;
	date = mdy(month,1,year);
	end;
	keep studentID term date event 'STU TYPE'n;
run;	

/*IV. Part A*/
/*Selects rows with C as stu type*/
data enrollments1(keep=studentid term 'stu type'n date);
	set gradsch.enrollments;
	where 'stu type'n eq 'C';
	if mod(term,100) eq 60 then term = term - 40;    /*Changes summer term to spring term*/
	season = mod(term, 100);                         /*Grabs last two digits from term*/
	year = input(substr(term, 5,6), best12.);        /*Gets year from term*/
	if season eq 10 then year=year-1;                /**MUST SUBTRACT 1 FROM YEAR FOR FALL TERM**/
		select(season);
		when(10) month = 12;   /*Assigns December as month for fall terms*/
		otherwise month = 5;   /*Assigns May as month for spring terms*/
		end;
	date = mdy(month,1,year);  /*Assigns day as first of the month*/
	format date date9.;
run;

/*IV. Part B*/
proc sort data=enrollments1 nodupkey;
	by studentID date;
run;


/*IV. Part C*/
data continuing(drop='stu type'n);
set enrollments1;
if 'stu type'n eq 'C' then event = 'Continuing';
run;

/*IV. Part D*/
proc sort data=continuing nodupkey;
	by studentID term event;
run;

/*IV. Part E*/
/*Combines timeline1 and continuing*/
data timeline1;
	set timeline1 (in=In1)
		continuing(in=InCont);
	by studentID term;
run;

/*Section V.*/
/*Part A*/
data before2021;
	set timeline1;
	if event eq 'Admitted' and year(date) le 2021 then do;   /*Checks year in admit date; 
															   if 2021 or earlier, row is flagged.*/
	flag = 1;
end;
run;

/*V. Part B*/
/*Combines before2021 and graduations data. Applies 'Graduated' to event*/
data timeline3;
	set before2021
		graduations;
	by studentID term;
	if missing(event) then event = 'Graduated';
	if event eq 'Graduated' then date = date1;
	keep studentID term date event flag 'subj code'n 'crse numb'n 'final grade'n;
run;

/**/
/* proc sql; */
/*   create table timeline4  */
/*   as select * */
/*   from timeline3; */
/* quit; */

/*Section VI.*/
/*Part A*/
proc sql; 
	create table timeline5
	as select *, count(distinct term) as TotalTerms   /*counts distinct terms*/
	from timeline3 
	group by studentID;
quit;

/*VI. Part B*/
proc sort data=timeline5;
	by studentID term date;
run;

/*Section VII.*/
/*Part A*/
proc sql;
	create table termfix
	as select DISTINCT(studentID), term from timeline5
	group by studentID
	having term=max(term);
quit;

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

/*VII. Part C*/
data exits1;
	merge exits(in=inexits)
	termfix(in=interm);
	by studentid;
	if interm and inexits then output;
run;

/*VII. Part D*/
proc sort data=exits1;
	by studentID;
run;

/*VII. Part E*/
/*Merges timeline5 and exits1 data*/
data timeline6;
	merge timeline5 (in=InT5)
		exits1(in=InExits);
	by studentID term;
	if event eq 'Exited' then do;
		season = mod(term, 100);
		year = input(substr(term, 5,6), best12.);
		if season eq 10 then year=year-1;
		select(season);
		when(10) month = 12;
		otherwise month = 5;
		end;
	date = mdy(month,1,year);
	keep studentID term date event flag 'subj code'n 'crse numb'n 'final grade'n;
	end;
run;

/*VII. Part F*/
proc sort data=timeline6;
	by studentID term;
run;

/*Section VIII.*/
/*Part A*/
data timeline7;
	set timeline6;
	if mod(term,100) eq 60 then term = term-40;  /*Changes summer terms to spring*/
run;

/*VIII. Part B*/
/*Creates running total for terms per student*/
data timeline8;
	set timeline7;
	by studentID term;
	term_count + first.term;
	if first.studentID then term_count = 1;
	keep studentID term date event flag 'subj code'n 'crse numb'n 'final grade'n term_count;
run;

/*Section IX.*/
/*Part A*/
proc sql;
  create table flag_data as
  select a.studentID, /*selects studentID from timeline8 aliased as a*/
         a.flag,	  /*selects flag from timeline8 aliased as a*/
         coalesce(a.flag, b.flag) as Crctflag /*returns the first non-missing value from a list of values. 
         										Checks if a.flag is missing. If it is, substitutes it with 
         										b.flag. Aliases as Crctflag.*/
  from timeline8 a
  /*left join between the timeline8 dataset (aliased as a) and a subquery (aliased as b)*/
  left join (
    select distinct studentID, flag
    from timeline8
    where not missing(flag)
  ) b
  on a.studentID = b.studentID
  order by a.studentID, a.flag;
quit;

/*IX. Part B*/
data Final_merge;
	merge flag_data
			timeline8;
	keep studentID term Crctflag date event 'subj code'n 'crse numb'n 'final grade'n term_count;
run;

/*IX. Part C*/
proc sort data=Final_merge;
	by studentID term;
run;

/*Section X.*/
/*Part A*/
/*Sends flagged rows to Training_data; all others to  Test_data*/
data Training_data Test_data;
    set Final_merge;
    by studentId term;
    if not missing(Crctflag) then output Training_data;
    else output Test_data;
    keep studentID term date event 'subj code'n 'crse numb'n 'final grade'n term_count;
run;

/*X. Part B*/
/*In Training_data, if a studentID is assigned a "graduated" event, 
  the sql query below chooses the earliest graduation term for each 
  studentID, leaving only one graduation term per student in the data. 
  graduation_terms table will not contain multiple graduate degrees 
  per studentID.*/
proc sql;
  create table graduation_terms as
  select distinct StudentID, min(term) as Graduation_Term /*min(Term) selects earliest/first graduation term*/
  from Training_data
  where Event = 'Graduated'
  group by StudentID;
quit;

/*X. Part C*/
/*Merge the training data with the graduation terms table */
data clean_dataset;
  merge Training_data graduation_terms(keep=StudentID Graduation_Term);
  by StudentID;
run;


/*Section XI.*/
/*Part A*/
/*Test_data cleaning*/
/*sql query to find all studentID's in Test_data with a 'continuing' 
and 'exited' event in the same term*/
proc sql;
  create table flagged_students as
  select distinct studentID, term, event
  from Test_data
  where event in ('Continuing', 'Exited')
  group by studentID, term
  having count(distinct event) = 2;
quit;


/*XI. Part B*/
/*Ensures only 'exited' event remains if an 'exited' event is present*/
data Test_data;
  merge Test_data(in=a) flagged_students(in=b);
  by studentID term;
  where not missing(term);
  if a and b and event='Exited' then output;
  else if a and not b then output;

  drop b;
run;


/*Section XII.*/
/*Part A*/
/*subsets to rows containing event type of 'continuing', 'graduated', or 'exited'*/
data eventsCGE; 
	set clean_dataset;
	where event eq 'Continuing' or event eq 'Graduated' or event eq 'Exited';
run;


/*XII. Part B*/
proc sort data=eventsCGE out=SorteventsCGE nodupkey;
	by studentID term;
run;


/*XII. Part C*/
/*Probability model*/
proc logisitic data=SorteventsCGE;
	model event = term_count / link = glogit;
	output out=EventProbs predprobs=(i);
run;

