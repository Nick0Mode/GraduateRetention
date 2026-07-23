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

/* observe the cleaned output */
proc print data=enrollments(obs=10); run;
proc freq data=enrollments; tables race OAP NC_resident distance_education male military; run;
