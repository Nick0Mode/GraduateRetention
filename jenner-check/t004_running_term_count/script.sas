/*VIII. Part B*/
/*Creates running total for terms per student*/
data timeline8;
	set timeline7;
	by studentID term;
	term_count + first.term;
	if first.studentID then term_count = 1;
	keep studentID term date event flag 'subj code'n 'crse numb'n 'final grade'n term_count;
run;

/* observe the running term count per student */
proc print data=timeline8; var studentID term event term_count; run;
