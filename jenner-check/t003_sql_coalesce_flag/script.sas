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

/* observe the propagated flag */
proc print data=flag_data; run;
