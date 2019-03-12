# utl-fill-in-data-between-two-dates-within-by-group-with-non-missing-values-timeseries
Fill in data between two dates within by group with non-missing values timeseries 
    Fill in data between two dates within by group with non-missing values timeseries                                              
                                                                                                                                   
       Four Solutions                                                                                                              
                                                                                                                                   
            1. Datastep                                                                                                            
            2. Proc Expand                                                                                                         
            3. HASH                                                                                                                
            4. R                                                                                                                   
                                                                                                                                   
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
                                                                                                                                   
    ===========                                                                                                                    
    1. Datastep                                                                                                                    
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
    2. Proc Expand                                                                                                                 
    ===============                                                                                                                
                                                                                                                                   
    proc expand data=have out=want to=day;                                                                                         
    by account ticker;                                                                                                             
    id date;                                                                                                                       
    convert shares price / method=step observed=beginning;                                                                         
    run;                                                                                                                           
                                                                                                                                   
                                                                                                                                   
    =======                                                                                                                        
    3. HASH                                                                                                                        
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
    4. R                                                                                                                           
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
                                                                                                                                   
