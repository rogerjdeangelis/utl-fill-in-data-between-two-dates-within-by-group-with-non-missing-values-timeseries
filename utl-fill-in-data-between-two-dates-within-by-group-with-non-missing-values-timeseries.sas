%let pgm=utl-Fill-in-data-between-two-dates-within-by-group-with-non-missing-values-timeseries;

Fill in data between two dates within by group with non-missing values timeseries

   Five Solutions

        1. Optimal solution by Mark Keintz mkeintz@wharton.upenn.edu (set with merge and view option)
           With additional update
        2. Datastep
        3. Proc Expand
        4. HASH
        5. R

github
https://tinyurl.com/y2wdcp4p
https://github.com/rogerjdeangelis/utl-fill-in-data-between-two-dates-within-by-group-with-non-missing-values-timeseries

SAS Forum
https://tinyurl.com/y4b2cjq7
https://communities.sas.com/t5/New-SAS-User/Fill-in-data-between-two-dates-within-by-group-with-non-missing/m-p/542212

PG Stats Proc expand
https://communities.sas.com/t5/user/viewprofilepage/user-id/462

Novinosron HASH
https://communities.sas.com/t5/user/viewprofilepage/user-id/138205


*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
input Account $ Ticker $ Date :mmddyy10. shares Price dollar2.;
format date mmddyy10. Price dollar2.;
cards4;
X A 01/01/15 100 $1
X A 01/05/15 200 $2
X B 01/01/15 300 $3
X B 01/05/15 600 $6
;;;;
run;quit;

/*
WORK.HAVE total obs=4

  ACCOUNT    TICKER       DATE       SHARES    PRICE

     X         A       01/01/2015      100      $1
     X         A       01/05/2015      200      $2
     X         B       01/01/2015      300      $3
     X         B       01/05/2015      600      $6
*/

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WANT total obs=10
                                                      |  RULES
Obs    ACCOUNT    TICKER       DATE    SHARES   PRICE |
                                                      |
  1       X         A       01/01/2015   100     $1   |
                                                      |
  2       X         A       01/02/2015   100     $1   | Generate these dates and carry forward
  3       X         A       01/03/2015   100     $1   | values
  4       X         A       01/04/2015   100     $1   |
                                                      |
  5       X         A       01/05/2015   200     $2   |
                                                      |
  6       X         B       01/01/2015   300     $3   |
                                                      |
  7       X         B       01/02/2015   300     $3   | Generate these dates and carry forward
  8       X         B       01/03/2015   300     $3   | values
  9       X         B       01/04/2015   300     $3   |
                                                      |
 10       X         B       01/05/2015   600     $6   |
                                                      |

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;


=============================================================
1. Optimal solution by Mark Keintz mkeintz@wharton.upenn.edu
==============================================================

Out of the Genius

If it’s just a matter of filling in holes in a time series,
and if the intermediate values are only a function of the
time points immediately prior and after the hole,
(i.e. like simple carry-forward per this example, or carry-back,
or some interpolation between end points), then
I almost always prefer a data step to proc expand.
Here is a common structure I use -  SET/BY combined
 with self-merge:

data have;
input Account $ Ticker $ Date :mmddyy10. shares Price dollar2.;
format date mmddyy10. Price dollar2.;
cards;
X A 01/01/15 100 $1
X A 01/05/15 200 $2
X B 01/01/15 300 $3
X B 01/05/15 600 $6
run;

data want (drop=nxt_date);
  set have (keep=ticker);
  by ticker;
  merge have
        have (firstobs=2 keep=date rename=(date=nxt_date));
  if last.ticker=0 then do date=date to nxt_date-1;
    output;
  end;
  else output;
run;

Note I use the SET statement keeping only the BY-variable.
It's not necessary ignore the other variables,
but it reminds me that I only want the set
statement to provide first.ticker and last.ticker dummies.
Then the self merge with a "firstobs=2" provides all
the current-obs data, plus the date the hole is closed.
No retains necessary.  It works to a "t" as long as date are sort
ed by date and/or time within each by-group.  And of course
the BY statement can't be associated with the MERGE statement,
since the "firstobs=2" offset would be
eliminated at the start of the 2nd by-group.

BTW, one of the reasons I prefer this to proc expand
is that proc expand can only new values from univariate series.
That is, in the data step I could calculate VALUE=SHARES*PRICE.
You can't do  that in proc expand.
Also, unlike proc expand, the data step can generate a view
instead of a file - possibly avoiding a lot of disk I/O
preparing data for a time series analysis.

Regards,
Mark

UPDATE 

Recent Update by Keintz, Mark" <mkeintz@WHARTON.UPENN.EDU>  (flexible, simple and fast)   
                                                                                          
If it’s just a matter of filling in holes in a time series, and if the                    
intermediate values are only a function of the time points immediately                    
prior and after the hole, (i.e. like si mple carry-forward per this example,              
or carry-back, or some interpolation between end points), then                            
I almost always prefer a data step to proc expand.                                        
Here is a common structure I use -  SET/BY combined                                       
 with self-merge:                                                                         
                                                                                          
data have;                                                                                
input Account $ Ticker $ Date :mmddyy10. shares Price dollar2.;                           
format date mmddyy10. Price dollar2.;                                                     
cards;                                                                                    
X A 01/01/15 100 $1                                                                       
X A 01/05/15 200 $2                                                                       
X B 01/01/15 300 $3                                                                       
X B 01/05/15 600 $6                                                                       
run;                                                                                      
data want (drop=nxt_date);                                                                
  set have (keep=ticker);                                                                 
  by ticker;                                                                              
  merge have                                                                              
        have (firstobs=2 keep=date rename=(date=nxt_date));                               
  if last.ticker=0 then do date=date to nxt_date-1;                                       
    output;                                                                               
  end;                                                                                    
  else output;                                                                            
run;                                                                                      
                                                                                          
Note I use the SET statement keeping only the BY-variable.                                
It's not necessary ignore the other variables, but it reminds                             
me that I only want the set statement to provide first.ticker                             
and last.ticker dummies. Then the self merge with a "firstobs=2"                          
provides all the current-obs data, plus the date the hole is closed.                      
No retains necessary.  It works to a "t" as long as date are sort                         
ed by date and/or time within each by-group.  And of course                               
the BY statement can't be associated with the MERGE statement,                            
since the "firstobs=2" offset would be eliminated at the start of the 2nd by-group.       
                                                                                          
BTW, one of the reasons I prefer this to proc expand is that                              
proc expand can only new values from univariate series.  That is,                         
in the data step I could calculate VALUE=SHARES*PRICE.                                    
You can't do  that in proc expand.                                                        
Also, unlike proc expand, the data step can generate a view instead of a file -           
possibly avoiding a lot of disk I/O preparing data for a time series analysis.            
                                                                                          
                                                                                          


===========
2. Datastep
===========

data want;

  retain date1 price1 shares1;


  format date1 mmddyy10.;

     set have;
     by ticker;

     if first.ticker then do;
        date1   = date;
        price1  = price;
        shares1 = shares;
     end;
     else do;
       do date1=date1 to date by 1;
          if date=date1 then shares1=shares;
          output;
       end;
     end;
     drop date price shares;

run;quit;


===============
3. Proc Expand
===============

proc expand data=have out=want to=day;
by account ticker;
id date;
convert shares price / method=step observed=beginning;
run;


=======
4. HASH
========

proc sql;
create table temp as
select  Account ,Ticker,min(date) as mindate,max(date) as maxdate
from have
group by  Account ,Ticker;
quit;

data want;
if _n_=1 then do;
if 0 then set have;
 dcl hash H (dataset:'have') ;
  h.definekey  ("Account","Ticker","Date") ;
   h.definedata ("shares", "price") ;
   h.definedone () ;
 end;
set temp;
do date=mindate to maxdate;
rc=h.find();
output;
end;
drop rc mindate maxdate;
run;

====
5. R
====

%utl_submit_r64('
library(haven);
library(dplyr);
library(tidyr);
library(SASxport);
library(DescTools);
library(data.table);
have<-read_sas("d:/sd1/have.sas7bdat");
have;
want<-have %>% group_by(TICKER) %>%
  complete(TICKER, DATE = seq.Date(min(DATE), max(DATE), by = "day"));
want$PRICE1<-LOCF(want$PRICE);
want$SHARES1<-LOCF(want$SHARES);
want$ACCOUNT1<-LOCF(want$ACCOUNT);
want<-as.data.table(want);
write.xport(want,file="d:/xpt/want.xpt");
');

libname xpt xport "d:/xpt/want.xpt";
data want;
  retain account1 ticker date shares1 price1;
  keep   account1 ticker date shares1 price1;
  format date mmddyy10.;
  set xpt.want;
run;quit;
libname xpt clear;

/*
WANT total obs=10

Obs    ACCOUNT1    TICKER       DATE       SHARES1    PRICE1

  1       X          A       01/01/2015      100         1
  2       X          A       01/02/2015      100         1
  3       X          A       01/03/2015      100         1
  4       X          A       01/04/2015      100         1
  5       X          A       01/05/2015      200         2
  6       X          B       01/01/2015      300         3
  7       X          B       01/02/2015      300         3
  8       X          B       01/03/2015      300         3
  9       X          B       01/04/2015      300         3
 10       X          B       01/05/2015      600         6
*/


                                                                                                            
